/*-----------------------------------------------------------------------

  This file is part of the RealityGrid AVS/Express Steerer Module.

  (C) Copyright 2005, University of Manchester, United Kingdom,
  all rights reserved.

  This software was developed by the RealityGrid project
  (http://www.realitygrid.org), funded by the EPSRC under grants
  GR/R67699/01 and GR/R67699/02.

  LICENCE TERMS

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

  THIS MATERIAL IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. THE ENTIRE RISK AS TO THE QUALITY
  AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE
  DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
  CORRECTION.

  Author........: Robert Haines

-----------------------------------------------------------------------*/

#include <iostream>

#include "ReG_Steer_Appside.h"
#include "ReG_Steer_types.h"
#include "ReG_Steer_Browser.h"
#include "ReG_Steer_Common.h"
#include "ReG_Steer_Utils.h"
#include "ReG_Steer_Utils_WSRF.h"
#include "ReG_Steer_XML.h"
#include "ReG_Steer_Steerside_WSRF.h"
#include "soapH.h"
#include "ReGSteerMod.hxx"
#include "reg_gen.hxx"

using std::cerr;
using std::endl;

ReGSteerMod::ReGSteerMod() {
  initialized = false;
  error="";
  pollCount = 0;

  iotype_handle = new int[REG_INITIAL_NUM_IOTYPES];
  iotype_labels = new char*[REG_INITIAL_NUM_IOTYPES];
  iotype_dir = new int[REG_INITIAL_NUM_IOTYPES];
  iotype_frequency = new int[REG_INITIAL_NUM_IOTYPES];

  num_recvd_cmds = 0;
  num_params_changed = 0;
  recvd_cmds = new int[REG_MAX_NUM_STR_CMDS];
  recvd_cmd_params = new char*[REG_MAX_NUM_STR_CMDS];
  for(int i = 0; i < REG_MAX_NUM_STR_CMDS; i++)
    recvd_cmd_params[i] = new char[REG_MAX_STRING_LENGTH];
  changed_param_labels = new char*[REG_MAX_NUM_STR_PARAMS];
  for(int i = 0; i < REG_MAX_NUM_STR_PARAMS; i++)
    changed_param_labels[i] = new char[REG_MAX_STRING_LENGTH];
}

ReGSteerMod::~ReGSteerMod() {
  if(initialized) {
    Steering_finalize();
  }

  delete[] iotype_handle;
  delete[] iotype_labels;
  delete[] iotype_dir;
  delete[] iotype_frequency;

  delete[] recvd_cmds;
  for(int i = 0; i < REG_MAX_NUM_STR_CMDS; i++)
    delete[] recvd_cmd_params[i];
  delete[] recvd_cmd_params;
  for(int i = 0; i < REG_MAX_NUM_STR_PARAMS; i++)
    delete[] changed_param_labels[i];
  delete[] changed_param_labels;
}

RealityGrid_RealityGridSteeringMod* ReGSteerMod::getParent() {
  return parent;
}

void ReGSteerMod::setParent(RealityGrid_RealityGridSteeringMod* p) {
  parent = p;
}

char* ReGSteerMod::getError() {
  return error;
}

bool ReGSteerMod::init(char* name, char* sgs_address, char* iotype_label) {
  int status;

  // Enable and initialize the steering library...
  Steering_enable(TRUE);
  status = Steering_initialize(name, 0, NULL);
  if(status != REG_SUCCESS) {
    error = "Failed to initialise Steering Module.";
    return false;
  }

  // register the input IO channel
  iotype_labels[0] = iotype_label;
  iotype_dir[0] = REG_IO_IN;
  iotype_frequency[0] = 1; // Attempt to consume data at every step
  num_iotypes = 1;
  status = Register_IOTypes(num_iotypes, iotype_labels, iotype_dir, iotype_frequency, iotype_handle);
  if(status != REG_SUCCESS) {
    error = "Failed to register IO channel.";
    return false;
  }

  initialized = true;
  return true;
}

bool ReGSteerMod::getRegistryInfo(char* registryEPR) {
  int status;
  int num_reg_entries;
  int num_service_groups;
  registry_entry* reg_entries = NULL;
  char* current_time;
  char summary[REG_MAX_STRING_LENGTH];

  // get current date and time for SWS...
  current_time = Get_current_time_string();
  parent->configuration.reg_sgs_start_time.set_str_val(current_time);

  // get entire list of SWS's in the registry...
  status = Get_registry_entries(registryEPR, &num_reg_entries, &reg_entries);
  if(status != REG_SUCCESS) {
    error = "Could not get registry entries.";
    return false;
  }

  // get the containers...
  num_service_groups = 0;
  parent->configuration.registry_info.num_containers = 0;
  for(int i = 0; i < num_reg_entries; i++) {
    if(strncmp(reg_entries[i].service_type, "ServiceGroup", 12) == 0) {

      // need to ignore these later...
      num_service_groups++;

      // only want container lists...
      if(strncmp(reg_entries[i].job_description, "Container registry", 18) == 0) {
	int num_containers;
	registry_entry* containers = NULL;

	status = Get_registry_entries(reg_entries[i].gsh, &num_containers, &containers);
	if(status != REG_SUCCESS) {
	  error = "Could not get containers.";
	  return false;
	}

	parent->configuration.registry_info.num_containers += num_containers;
	for(int j = 0; j < num_containers; j++) {
	  parent->configuration.registry_info.containers.set_str_array_val(j, containers[j].gsh);
	}

	if(containers)
	  free(containers);
      }
    }
  }

  // populate the internal registry info...
  parent->configuration.registry_info.num_entries = (num_reg_entries - num_service_groups);

  int j = 0;
  for(int i = 0; i < num_reg_entries; i++) {
    if(strncmp(reg_entries[i].service_type, "SWS", 3) == 0) {
      parent->configuration.registry_info.gsh.set_str_array_val(j, reg_entries[i].gsh);
      parent->configuration.registry_info.entry_gsh.set_str_array_val(j, reg_entries[i].entry_gsh);
      parent->configuration.registry_info.app_name.set_str_array_val(j, reg_entries[i].application);
      parent->configuration.registry_info.user_name.set_str_array_val(j, reg_entries[i].user);
      parent->configuration.registry_info.org_name.set_str_array_val(j, reg_entries[i].group);
      parent->configuration.registry_info.start_time.set_str_array_val(j, reg_entries[i].start_date_time);
      parent->configuration.registry_info.description.set_str_array_val(j, reg_entries[i].job_description);

      // generate summary descriptions of the SWS's...
      sprintf(summary, "%s, %s, %s, %s", reg_entries[i].application,
	      reg_entries[i].user,
	      reg_entries[i].job_description,
	      reg_entries[i].start_date_time);
      parent->configuration.registry_info.summary.set_str_array_val(j, summary);

      j++;
    }
  }

  // clean up...
  if(num_reg_entries > 0)
    free(reg_entries);

  return true;
}

bool ReGSteerMod::createSWS(bool vis, char* dataSource, char* container,
			    char* registry, char* username, char* group,
			    char* application, char* purpose, int lifetime) {
  char* EPR;
  char iodef_label[REG_MAX_STRING_LENGTH];
  soap mySoap;
  wsrp__SetResourcePropertiesResponse response;

  // sort out iotypes for connecting to sim here if necessary...
  if(vis && dataSource != NULL) {
    msg_struct* msg;
    xmlDocPtr doc;
    xmlNsPtr   ns;
    xmlNodePtr cur;
    io_struct* ioPtr;
    char* ioTypes;

    // get IOTypes from the data source...
    soap_init(&mySoap);
    if(Get_resource_property(&mySoap,
			     dataSource,
			     "ioTypeDefinitions",
			     &ioTypes) != REG_SUCCESS) {
      error = "Call to get ioTypeDefinitions ResourceProperty failed.";
      printf("%s\n", dataSource);
      soap_end(&mySoap);
      soap_done(&mySoap);
      return false;
    }

    // parse IOTypes...
    if(!(doc = xmlParseMemory(ioTypes, strlen(ioTypes))) ||
       !(cur = xmlDocGetRootElement(doc))) {
      error = "Hit error parsing IOTypes.";
      xmlFreeDoc(doc);
      xmlCleanupParser();
      soap_end(&mySoap);
      soap_done(&mySoap);
      return false;
    }

    ns = xmlSearchNsByHref(doc, cur,
                  (const xmlChar*) "http://www.realitygrid.org/xml/steering");

    if(xmlStrcmp(cur->name, (const xmlChar*) "ioTypeDefinitions")) {
      error = "ioTypeDefinitions not the root element.";
      xmlFreeDoc(doc);
      xmlCleanupParser();
      soap_end(&mySoap);
      soap_done(&mySoap);
      return false;
    }

    // Step down to ReG_steer_message and then to IOType_defs
    cur = cur->xmlChildrenNode->xmlChildrenNode;

    msg = New_msg_struct();
    msg->io_def = New_io_def_struct();
    parseIOTypeDef(doc, ns, cur, msg->io_def);
    Print_msg(msg);

    if(!(ioPtr = msg->io_def->first_io)) {
      error = "Got no IOType definitions from data source.";
      xmlFreeDoc(doc);
      xmlCleanupParser();
      soap_end(&mySoap);
      soap_done(&mySoap);
      return false;
    }

    // HACK: just grab first "OUT" IOType...
    while(ioPtr) {
      if(!xmlStrcmp(ioPtr->direction, (const xmlChar*) "OUT")) {
	strncpy(iodef_label, (char*)(ioPtr->label), REG_MAX_STRING_LENGTH);
	break;
      }
      ioPtr = ioPtr->next;
    }

    // clean up...
    Delete_msg_struct(&msg);
    xmlFreeDoc(doc);
    xmlCleanupParser();
  }
  else if(vis && dataSource == NULL) {
    error = "No SWS provided to connect to.";
    return false;
  }

  // create the SWS...
  EPR = Create_steering_service(lifetime, container, registry, username,
				group, application, purpose, "", "");

  if(!EPR) {
    error = "Failed to create SWS.";
    return false;
  }
  else
    printf("SWS: %s\n\n", EPR);

  // set data source on SWS if necessary...
  if(vis) {
    char message[REG_MAX_STRING_LENGTH];

    snprintf(message, REG_MAX_STRING_LENGTH,
	     "<dataSource><sourceEPR>%s</sourceEPR>"
	     "<sourceLabel>%s</sourceLabel></dataSource>",
	     dataSource, iodef_label);

    if(soap_call_wsrp__SetResourceProperties(&mySoap, EPR, "", message,
					     &response) != SOAP_OK) {
      error = "soap call went bad.";
      soap_end(&mySoap);
      soap_done(&mySoap);
      return false;
    }

    // clean up soap...
    soap_end(&mySoap);
    soap_done(&mySoap);
  }

  // save to the network...
  parent->configuration.reg_sgs_address.set_str_val(EPR);

  return true;
}

bool ReGSteerMod::poll(int* numCommands) {
  int status;
  *numCommands = 0;

  status = Steering_control(pollCount++,
			    &num_params_changed,
			    changed_param_labels,
			    &num_recvd_cmds,
			    recvd_cmds,
			    recvd_cmd_params);

  if(status != REG_SUCCESS) {
    error = "Steering control failure.";
    return false;
  }

  *numCommands = num_recvd_cmds;
  return true;
}

bool ReGSteerMod::getData() {
  int status;
  int dataType;
  int dataCount;
  int slices = 0;
  int currentNumSlices = (int) parent->slices;
  REG_IOHandleType iohandle;

  if(num_recvd_cmds > 0) {
    for(int i = 0; i < num_recvd_cmds; i++) {
      if(recvd_cmds[i] == iotype_handle[0]) {
	
	// 'Open' the channel to consume data
	status = Consume_start(iotype_handle[0], &iohandle);
	
	if(status == REG_SUCCESS) {
	  
	  // Data is available to read...get header describing it
	  status = Consume_data_slice_header(iohandle, &dataType, &dataCount);

	  while(status == REG_SUCCESS) {

	    // make room in the dataslice array for the data
	    if(slices >= currentNumSlices) {
	      parent->slices = ((int) parent->slices) + 1;
	      currentNumSlices++;
	    }

	    // Read the data itself
	    switch(dataType) {
	    case REG_CHAR:
		charData = (char*) malloc(dataCount * sizeof(char));
		status = Consume_data_slice(iohandle, dataType, dataCount, charData);
				
	      if(slices < (int) parent->slices) {
		parent->outData[slices].type = 0;
		parent->outData[slices].size = dataCount;
		parent->outData[slices].data.set_array(OM_TYPE_CHAR, charData, dataCount, OM_SET_ARRAY_FREE);
		slices++;
	      }
	      break;

	    case REG_INT:
		intData = (int*) malloc(dataCount * sizeof(int));
		status = Consume_data_slice(iohandle, dataType, dataCount, intData);
				
	      if(slices < (int) parent->slices) {
		parent->outData[slices].type = 1;
		parent->outData[slices].size = dataCount;
		parent->outData[slices].data.set_array(OM_TYPE_INT, intData, dataCount, OM_SET_ARRAY_FREE);
		slices++;
	      }
	      break;

	    case REG_FLOAT:
		floatData = (float*) malloc(dataCount * sizeof(float));
		status = Consume_data_slice(iohandle, dataType, dataCount, floatData);
				
	      if(slices < (int) parent->slices) {
		parent->outData[slices].type = 2;
		parent->outData[slices].size = dataCount;
		parent->outData[slices].data.set_array(OM_TYPE_FLOAT, floatData, dataCount, OM_SET_ARRAY_FREE);
		slices++;
	      }
	      break;

	    case REG_DBL:
		doubleData = (double*) malloc(dataCount * sizeof(double));
		status = Consume_data_slice(iohandle, dataType, dataCount, doubleData);
				
	      if(slices < (int) parent->slices) {
		parent->outData[slices].type = 3;
		parent->outData[slices].size = dataCount;
		parent->outData[slices].data.set_array(OM_TYPE_DOUBLE, doubleData, dataCount, OM_SET_ARRAY_FREE);
		slices++;
	      }
	      break;

	    default:
	      break;
	    } // end switch(dataType)

	    status = Consume_data_slice_header(iohandle, &dataType, &dataCount);

	  } // end while

	  // Reached the end of this data set; 'close' the channel
	  status = Consume_stop(&iohandle);

	  //set the array length
	  parent->slices = slices;

	} // end if
      }
    }
  }

  return true;
}
