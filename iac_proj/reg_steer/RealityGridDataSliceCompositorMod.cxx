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

#include "iac_proj/reg_steer/reg_gen.hxx"


int
RealityGrid_RealityGridDataSliceCompositorMod::join(OMevent_mask event_mask, int seq_num)
{
    
  if(inData.changed(seq_num)) {
    int charDataSizeTotal = 0;
    int intDataSizeTotal = 0;
    int floatDataSizeTotal = 0;
    int doubleDataSizeTotal = 0;

    for(int i = 0; i < (int) numSlices; i++) {
      switch(inData[i].type) {
      case 0:
	charDataSizeTotal += (int) inData[i].size;
	break;
      case 1:
	intDataSizeTotal += (int) inData[i].size;
	break;
      case 2:
	floatDataSizeTotal += (int) inData[i].size;
	break;
      case 3:
	doubleDataSizeTotal += (int) inData[i].size;
	break;
      }
    }

    char* charData = NULL;
    int* intData = NULL;
    float* floatData = NULL;
    double* doubleData = NULL;
    int charDataSize = 0;
    int intDataSize = 0;
    int floatDataSize = 0;
    int doubleDataSize = 0;
 
    if(charDataSizeTotal > 0) charData = new char[charDataSizeTotal];
    if(intDataSizeTotal > 0) intData = new int[intDataSizeTotal];
    if(floatDataSizeTotal > 0) floatData = new float[floatDataSizeTotal];
    if(doubleDataSizeTotal > 0) doubleData = new double[doubleDataSizeTotal];
    
    for(int i = 0; i < (int) numSlices; i++) {
      unsigned char* dataSlice = (unsigned char*) inData[i].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      
      if(dataSlice) {
	switch((int) inData[i].type) {
	case 0:
	  // OM_TYPE_CHAR:
	  memcpy(&charData[charDataSize], dataSlice, ((int) inData[i].size * sizeof(char)));
	  charDataSize += (int) inData[i].size;
	  break;
	case 1:
	  // OM_TYPE_INT:
	  memcpy(&intData[intDataSize], dataSlice, ((int) inData[i].size * sizeof(int)));
	  intDataSize += (int) inData[i].size;
	  break;
	case 2:
	  // OM_TYPE_FLOAT:
	  memcpy(&floatData[floatDataSize], dataSlice, ((int) inData[i].size * sizeof(float)));
	  floatDataSize += (int) inData[i].size;
	  break;
	case 3:
	  // OM_TYPE_DOUBLE:
	  memcpy(&doubleData[doubleDataSize], dataSlice, ((int) inData[i].size * sizeof(double)));
	  doubleDataSize += (int) inData[i].size;
	  break;
	}
	
	ARRfree(dataSlice);
      }
    }
    
    if(charDataSizeTotal > 0 && charDataSize == charDataSizeTotal)
      outCharData.set_array(OM_TYPE_CHAR, charData, charDataSize, OM_SET_ARRAY_COPY);
    if(intDataSizeTotal > 0 && intDataSize == intDataSizeTotal)
      outIntData.set_array(OM_TYPE_INT, intData, intDataSize, OM_SET_ARRAY_COPY);
    if(floatDataSizeTotal > 0 && floatDataSize == floatDataSizeTotal)
      outFloatData.set_array(OM_TYPE_FLOAT, floatData, floatDataSize, OM_SET_ARRAY_COPY);
    if(doubleDataSizeTotal > 0 && doubleDataSize == doubleDataSizeTotal)
      outDoubleData.set_array(OM_TYPE_DOUBLE, doubleData, doubleDataSize, OM_SET_ARRAY_COPY);

    if(charData) delete[] charData;
    if(intData) delete[] intData;
    if(floatData) delete[] floatData;
    if(doubleData) delete[] doubleData;
  }

  // return 1 for success
  return 1;
}
