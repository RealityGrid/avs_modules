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

bool ReGSteerMod::getSecurityInfo(reg_security_info* sec, char* regEPR) {
  int status;
  bool have_ssl;

  // clean out what we have
  Wipe_security_info(sec);

  (strncmp(regEPR, "https", 5) == 0) ? have_ssl = true : have_ssl = false;

  if(!(parent->configuration.security_info.initialized.valid_obj() &&
       ((int) parent->configuration.security_info.initialized == 1))) {
    // need to get security info from a file...
    fprintf(stderr, "get from file\n");

    // do we have SSL?
    if(have_ssl) {
      // yes
      char* sec_file;

      // get security stuff from file...
      if(parent->configuration.security_info.filename.valid_obj())
	parent->configuration.security_info.filename.get_str_val(&sec_file);
      else
	sec_file = "~/.realitygrid/security.conf";

      status = Get_security_config(sec_file, sec);
      if(status != REG_SUCCESS) {
	error = "Could not get security configuration.";
	return false;
      }

      // set SSL flag
      sec->use_ssl = REG_TRUE;

      parent->configuration.security_info.ca_cert_path.set_str_val(sec->caCertsPath);
      parent->configuration.security_info.user_cert_path.set_str_val(sec->myKeyCertFile);
      parent->configuration.security_info.user_dn.set_str_val(sec->userDN);
    }
    else {
      // no

      // set SSL flag
      sec->use_ssl = REG_FALSE;
    } // SSL?

    parent->configuration.security_info.use_ssl = sec->use_ssl;
    parent->configuration.security_info.initialized = 1;
  }
  else {
    // have security info...
    fprintf(stderr, "get from xp\n");

    // do we have SSL?
    if(have_ssl) {
      // yes
      char* cert_path;
      char* user_cert;
      char* user_dn;

      parent->configuration.security_info.ca_cert_path.get_str_val(&cert_path);
      strncpy(sec->caCertsPath, cert_path, REG_MAX_STRING_LENGTH);
      parent->configuration.security_info.user_cert_path.get_str_val(&user_cert);
      strncpy(sec->myKeyCertFile, user_cert, REG_MAX_STRING_LENGTH);
      parent->configuration.security_info.user_dn.get_str_val(&user_dn);
      strncpy(sec->userDN, user_dn, REG_MAX_STRING_LENGTH);

      sec->use_ssl = REG_TRUE;
    }
    else {
      // no

      sec->use_ssl = REG_FALSE;
    }
  }

  return true;
}

int ReGSteerMod::readPassword(OMXptr* ptr, char** passwd) {
  int len = 0;
  int status;
  
  status = OMget_ptr_val(ptr->obj_id(), (void**) passwd, 0);
  if(status == OM_STAT_SUCCESS)
    len = strlen(*passwd);
  else
    passwd = NULL;

  return len;
}

bool ReGSteerMod::getRegistryInfo(char* registryEPR) {
  int status;
  int num_service_groups;
  registry_contents reg_contents;
  reg_security_info reg_security;
  char* current_time;
  char summary[REG_MAX_STRING_LENGTH];

  // get current date and time for SWS...
  current_time = Get_current_time_string();
  parent->configuration.job_info.start_time.set_str_val(current_time);

  fprintf(stderr, "EPR: %s\n", registryEPR);

  // get security info...
  if(!getSecurityInfo(&reg_security, registryEPR)) {
    error = "Could not get security configuration.";
    return false;
  }

  // get user cert passphrase...
  char* passwd;
  status = readPassword(&(parent->configuration.security_info.user_password), &passwd);
  if(status == 0) {
    error = "Could not get user certificate password.";
    return false;
  }
  else {
    strncpy(reg_security.passphrase, passwd, status + 1);
  }

  // get entire list of SWS's in the registry...
  status = Get_registry_entries_secure(registryEPR, &reg_security, &reg_contents);
  if(status != REG_SUCCESS) {
    error = "Could not get registry entries.";
    return false;
  }

  // get the containers...
  num_service_groups = 0;
  parent->configuration.registry_info.num_containers = 0;
  for(int i = 0; i < reg_contents.numEntries; i++) {
    if(strncmp(reg_contents.entries[i].service_type, "ServiceGroup", 12) == 0) {

      // need to ignore these later...
      num_service_groups++;

      // only want container lists...
      if(strncmp(reg_contents.entries[i].job_description, "Container registry", 18) == 0) {
	registry_contents containers;

	status = Get_registry_entries_secure(reg_contents.entries[i].gsh, &reg_security, &containers);
	if(status != REG_SUCCESS) {
	  error = "Could not get containers.";
	  return false;
	}

	parent->configuration.registry_info.num_containers += containers.numEntries;
	for(int j = 0; j < containers.numEntries; j++) {
	  parent->configuration.registry_info.containers.set_str_array_val(j, containers.entries[j].gsh);
	}

	Delete_registry_table(&containers);
      }
    }
  }

  // populate the internal registry info...
  parent->configuration.registry_info.num_entries = (reg_contents.numEntries - num_service_groups);

  int j = 0;
  for(int i = 0; i < reg_contents.numEntries; i++) {
    if(strncmp(reg_contents.entries[i].service_type, "SWS", 3) == 0) {
      parent->configuration.registry_info.gsh.set_str_array_val(j, reg_contents.entries[i].gsh);
      parent->configuration.registry_info.entry_gsh.set_str_array_val(j, reg_contents.entries[i].entry_gsh);
      parent->configuration.registry_info.app_name.set_str_array_val(j, reg_contents.entries[i].application);
      parent->configuration.registry_info.user_name.set_str_array_val(j, reg_contents.entries[i].user);
      parent->configuration.registry_info.org_name.set_str_array_val(j, reg_contents.entries[i].group);
      parent->configuration.registry_info.start_time.set_str_array_val(j, reg_contents.entries[i].start_date_time);
      parent->configuration.registry_info.description.set_str_array_val(j, reg_contents.entries[i].job_description);

      // generate summary descriptions of the SWS's...
      sprintf(summary, "%s, %s, %s, %s", reg_contents.entries[i].application,
	      reg_contents.entries[i].user,
	      reg_contents.entries[i].job_description,
	      reg_contents.entries[i].start_date_time);
      parent->configuration.registry_info.summary.set_str_array_val(j, summary);

      j++;
    }
  }

  // clean up...
  Delete_registry_table(&reg_contents);

  return true;
}

bool ReGSteerMod::createSWS(bool vis, char* dataSource, char* container,
			    char* registry, char* username, char* group,
			    char* application, char* purpose, int lifetime) {
  int status;
  char* EPR;
  char iodef_label[REG_MAX_STRING_LENGTH];
  soap mySoap;
  wsrp__SetResourcePropertiesResponse response;
  reg_security_info reg_security;
  reg_job_details reg_job;
  reg_iotype_list iotypelist;

  // get security info...
  if(!getSecurityInfo(&reg_security, registry)) {
    error = "Could not get security configuration.";
    return false;
  }

  // sort out iotypes for connecting to sim here if necessary...
  if(vis) {
    if(dataSource != NULL) {
      Get_IOTypes(dataSource, &reg_security, &iotypelist);

      if(iotypelist.numEntries < 1) {
	error = "No IOType definitions to connect to.";
	return false;
      }

      // <HACK>
      // just use first output iotype for now
      // </HACK>
      for(int i = 0; i < iotypelist.numEntries; i++) {
	if(iotypelist.iotype[i].direction == REG_IO_OUT) {
	  //fprintf(stderr, "  %d: %s\n", i, iotypelist.iotype[i].label);
	  strncpy(iodef_label, iotypelist.iotype[i].label, REG_MAX_STRING_LENGTH);
	  break;
	}
      }

      Delete_iotype_list(&iotypelist);
    }
    else {
      error = "No SWS provided to connect to.";
      return false;
    }
  }

  // fill in job details
  reg_job.lifetimeMinutes = lifetime;
  strncpy(reg_job.software, application, REG_MAX_STRING_LENGTH);
  strncpy(reg_job.purpose, purpose, REG_MAX_STRING_LENGTH);
  strncpy(reg_job.userName, username, REG_MAX_STRING_LENGTH);
  strncpy(reg_job.group, group, REG_MAX_STRING_LENGTH);
  reg_job.inputFilename[0] = '\0';
  reg_job.checkpointAddress[0] = '\0';

  // get passphrase for job...
  char* passwd;
  status = readPassword(&(parent->configuration.job_info.passphrase), &passwd);
  if(status == 0) {
    error = "Could not get job password.";
    return false;
  }
  else {
    strncpy(reg_job.passphrase, passwd, status + 1);

#ifdef __sgi
    char env[REG_MAX_STRING_LENGTH];
    snprintf(env, "REG_PASSPHRASE=%s", passwd, REG_MAX_STRING_LENGTH);
    putenv(env);
#else
    setenv("REG_PASSPHRASE", passwd, 1);
#endif
  }

  // get passphrase for user cert...
  status = readPassword(&(parent->configuration.security_info.user_password), &passwd);
  if(status == 0) {
    error = "Could not get user certificate passphrase.";
    return false;
  }
  else {
    strncpy(reg_security.passphrase, passwd, status + 1);
  }

  // create the SWS...
  EPR = Create_steering_service(&reg_job, container, registry, &reg_security);

  if(!EPR) {
    error = "Failed to create SWS.";
    return false;
  }
  else
    fprintf(stderr, "SWS: %s\n\n", EPR);

  // set data source on SWS if necessary...
  if(vis) {
    char message[REG_MAX_STRING_LENGTH];

    snprintf(message, REG_MAX_STRING_LENGTH,
	     "<dataSource><sourceEPR>%s</sourceEPR>"
	     "<sourceLabel>%s</sourceLabel></dataSource>",
	     dataSource, iodef_label);

    soap_init(&mySoap);
    if(Set_resource_property(&mySoap, EPR, reg_job.userName,
			     reg_job.passphrase, message) != REG_SUCCESS) {
      if(Destroy_steering_service(EPR, &reg_security) == REG_SUCCESS)
	error = "Failed to initialize SWS with data source, so have destroyed SWS.";
      else
	error = "Failed to initialize SWS with data source and have failed to destroy SWS.";

      soap_end(&mySoap);
      soap_done(&mySoap);
      return false;
    }

    soap_end(&mySoap);
    soap_done(&mySoap);
  }

  // save to the network...
  parent->configuration.job_info.sws_address.set_str_val(EPR);

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
