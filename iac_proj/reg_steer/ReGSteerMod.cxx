
#include <iostream>

#include "ReG_Steer_Appside.h"
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

bool ReGSteerMod::init(char* name, char* sgs_address) {
  int status;

  // Enable and initialize the steering library...
  Steering_enable(TRUE);
  status = Steering_initialize(name, 0, NULL);
  if(status != REG_SUCCESS) {
    error = "Failed to initialise Steering Module.";
    return false;
  }

  // register the input IO channel
  iotype_labels[0] = "AVS_Data_Consumer";
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
