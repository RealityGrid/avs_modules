
#include "iac_proj/reg_lb3d/lb3d_gen.hxx"

/*
 * Read a set of data slices from the RealityGridSteerer and re-compose the data.
 */
int RealityGridLB3D_RealityGridLB3DReaderMod::read(OMevent_mask event_mask, int seq_num) {

  if(inData.changed(seq_num)) {
    int totalDataSize = 0;
    int slices = 0;
    int dims[3];

    if(numSlices.valid_obj())
      slices = (int) numSlices;
    else {
      ERRverror("RealityGridLBE3DReader", ERR_WARNING, "Number of data slices is undefined");
      return 0;
    }

    for(int i = 0; i < slices; i++) {
      if((int) inData[i].type == 3)
	totalDataSize += (int) inData[i].size;
    }

    double* data = NULL;
    if(totalDataSize > 0)
      data = new double[totalDataSize];
    else {
      // no data!
      return 0;
    }

    // check vtk header (could be more rigorous!)
    if((int) inData[0].type != 0) {
      ERRverror("RealityGridLBE3DReader", ERR_WARNING, "This doesn't look like LBE3D data: missing vtk header!");
      return 0;
    }

    // loop over chunk headers and data
    for(int i = 1; i < slices; i+=2) {
      int dataIndex = 0;
      int dataOrigin[3];
      int dataTotalExtent[3];
      int dataChunkExtent[3];
      int isF90 = 0;

      // chunk header
      if((int) inData[i].type != 0) {
	ERRverror("RealityGridLBE3DReader", ERR_WARNING, "This doesn't look like LBE3D data: missing chunk header!");
	return 0;
      }
      char* headerSlice = (char*) inData[i].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      if(headerSlice) {
	if(strstr(headerSlice, "CHUNK_HDR")) {
	  if(sscanf(headerSlice, 
		    "CHUNK_HDR\n"
		    "ARRAY  %d %d %d\n"
		    "ORIGIN %d %d %d\n"
		    "EXTENT %d %d %d\n"
		    "FROM_FORTRAN %d\n"
		    "END_CHUNK_HDR\n", 
		    &(dataTotalExtent[0]), &(dataTotalExtent[1]), &(dataTotalExtent[2]),
		    &(dataOrigin[0]),  &(dataOrigin[1]),  &(dataOrigin[2]), 
		    &(dataChunkExtent[0]), &(dataChunkExtent[1]), &(dataChunkExtent[2]),
		    &isF90) != 10) {
	    ERRverror("RealityGridLBE3DReader", ERR_WARNING, "This doesn't look like LBE3D data: malformed chunk header!");
	    ARRfree(headerSlice);
	  }
	  else {
	    // calculate index of this chunk in whole array
	    dataIndex = (dataOrigin[0]*dataTotalExtent[2]*dataTotalExtent[1]) \
	      + (dataOrigin[1]*dataTotalExtent[2]) + dataOrigin[2];

	    dims[0] = dataTotalExtent[0];
	    dims[1] = dataTotalExtent[1];
	    dims[2] = dataTotalExtent[2];
	    ARRfree(headerSlice);
	  }
	}
	else {
	  ERRverror("RealityGridLBE3DReader", ERR_WARNING, "This doesn't look like LBE3D data: missing chunk header!");
	  ARRfree(headerSlice);
	  return 0;
	} // end strstr
      } // end headerSlice

      // data
      if((int) inData[i+1].type != 3) {
	ERRverror("RealityGridLBE3DReader", ERR_WARNING, "This doesn't look like LBE3D data: missing data slice!");
	return 0;
      }

      double* dataSlice = (double*) inData[i+1].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      if(dataSlice) {
	int dataSize = (int) inData[i+1].size * sizeof(double);

	if(isF90) {
	  Reorder_array(3, dataTotalExtent, dataChunkExtent, dataOrigin,
			REG_DBL,
			dataSlice,
			data,
			FALSE);
	}
	else {
	  memcpy(&(((int*) data)[dataIndex]), dataSlice, dataSize);
	}

    	ARRfree(dataSlice);
      } // end dataSlice

    } // end loop over header and data slices

    // output data and finish off
    if(totalDataSize > 0) 
      outData.set_array(OM_TYPE_DOUBLE, data, totalDataSize, OM_SET_ARRAY_FREE);

    if(dims)
      outDims.set_array(OM_TYPE_INT, dims, 3, OM_SET_ARRAY_COPY);

    // produce volume renderable output
    if((int) volOutput != 0) {
      volumeOutput(data, totalDataSize);
    }
  }
  
  // return 1 for success
  return 1;
}

/*
 * Read a lb3d dataset from a Read_Field module.
 */
int RealityGridLB3D_RealityGridLB3DReaderMod::readField(OMevent_mask event_mask, int seq_num) {
  if((inField.nnode_data > 0) && ((int) configuration.connected == 0)) {
    //printf("\nIN: RealityGrid_RealityGridLBE3DReaderMod::readField\n\n");
    
    // set the output dims...
    OMobj_id dimsID = inField.dims.obj_id();
    outDims.set_obj_ref(dimsID);

    // inField.nnodes (int)
    // inField.nnode_data (int)
    int  inField_data_comp;
    int  inField_data_size, inField_data_type;
    for (inField_data_comp = 0; inField_data_comp < inField.nnode_data; inField_data_comp++) { 
      // inField.node_data[inField_data_comp].veclen (int) 
      // inField.node_data[inField_data_comp].values (char [])
      float* inField_node_data = (float*) inField.node_data[inField_data_comp].values.ret_array_ptr(OM_GET_ARRAY_RD, &inField_data_size, &inField_data_type);
      if(inField_node_data) {
	double* inField_tmpData = new double[inField_data_size];
	for(int i = 0; i < inField_data_size; i++) {
	  inField_tmpData[i] = (double) inField_node_data[i];
	}
	outData.set_array(OM_TYPE_DOUBLE, inField_tmpData, inField_data_size, OM_SET_ARRAY_FREE);
	
	// produce volume renderable output
	if((int) volOutput != 0) {
	  volumeOutput(inField_tmpData, inField_data_size);
	}
	
	ARRfree(inField_node_data);
      }
    }

  } // if((inField.nnode_data > 0) && ...
  
  // return 1 for success
  return 1;
}

/*
 * Produce short and byte output for volume rendering.
 */
void RealityGridLB3D_RealityGridLB3DReaderMod::volumeOutput(double* data, int totalDataSize) {

  //printf("\nIN: RealityGrid_RealityGridLBE3DReaderMod::volumeOutput\n\n");

  double dataMin = data[0];
  double dataMax = data[0];
  
  for(int i = 1; i < totalDataSize; i++) {
    if(data[i] > dataMax) dataMax = data[i];
    if(data[i] < dataMin) dataMin = data[i];
  }
  double dataRangeMultShort = (1.0 / (dataMax - dataMin) * 65535.0);
  double dataRangeMultByte = (1.0 / (dataMax - dataMin) * 255.0);
  
  double tmpData;
  short* shortData = new short[totalDataSize];
  unsigned char* byteData = new unsigned char[totalDataSize];
  
  for(int i = 0; i < totalDataSize; i++) {
    tmpData = ((data[i] - dataMin) * dataRangeMultShort) - 32767.0;
    shortData[i] = (short) tmpData;
    
    tmpData = ((data[i] - dataMin) * dataRangeMultByte);
    byteData[i] = (unsigned char) tmpData;
  }
  
  outShortData.set_array(OM_TYPE_SHORT, shortData, totalDataSize, OM_SET_ARRAY_FREE);
  outByteData.set_array(OM_TYPE_BYTE, byteData, totalDataSize, OM_SET_ARRAY_FREE);
  
  // set labels for the colormap editor...
  minLabel = dataMin;
  maxLabel = dataMax;
  
  return;
}
