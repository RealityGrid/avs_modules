/* ----------------------------------------------------------------------------
  This file is part of the RealityGrid AVS/Express FEA Module.
 
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
---------------------------------------------------------------------------- */

#include "iac_proj/reg_fea/fea_gen.hxx"


int RealityGridFEA_RealityGridFEAReaderMod::update(OMevent_mask event_mask, int seq_num) {

  // only do anything if we actually have any data!
  if(inData.changed(seq_num)) {

    // ensure we have a valid number of slices
    int slices = 0;
    if(numSlices.valid_obj())
      slices = (int) numSlices;
    else {
      ERRverror("RealityGridFEAReader", ERR_WARNING, "Number of data slices is undefined!");
      return 0;
    }

    // check to see if we already have our elements setup
    int elementsInit = 0;
    if(gotElements.valid_obj())
      elementsInit = (int) gotElements;

    // grab the element connectivity list
    int* corners = (int*) elementConnectivity.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
    if(!corners) {
      ERRverror("RealityGridFEAReader", ERR_WARNING, "Could not get the element connectivity!");
      return 0;
    }

    // first time through we should get three data slices:
    // * coordinates
    // * element data
    // * displacements for the coordinates
    if(slices == 3 && !elementsInit) {
      // initial pass
      int numCoords = (int) inData[0].size / 3;
      int numElements = (int) inData[1].size / 12;

      outData.nspace = 3;
      outData.nnodes = numCoords;

      // allocate memory for storing coordinates
      oldCoords = (float*) malloc(numCoords * 3 * sizeof(float));

      // read in and copy coordinates and initial displacements
      double* inCoords = (double*) inData[0].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      double* displacements = (double*) inData[0].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      float* outCoords = (float*) outData.coordinates.values.ret_array_ptr(OM_GET_ARRAY_WR);

      if(inCoords && outCoords && oldCoords && displacements) {
	for(int i = 0; i < (numCoords * 3); i++) {
	  outCoords[i] = (float) (inCoords[i] + displacements[i]);
	  oldCoords[i] = (float) inCoords[i];
	}

	ARRfree(inCoords);
	ARRfree(displacements);
	ARRfree(outCoords);
      }
      else {
	ERRverror("RealityGridFEAReader", ERR_WARNING, "Could not allocate memory for coordinates!");
	return 0;
      }

      // read in and build cells
      OMobj_id outDataID = find_subobj("outData", OM_OBJ_RW);
      outData.ncell_sets = 0;
      FLDadd_cell_set(outDataID, "Hex");
      outData.cell_set[0].ncells = numElements;

      // cell data stuff
      outData.cell_set[0].ncell_data=1;
      outData.cell_set[0].cell_data[0].veclen = 1;
      int* cellData = (int*) outData.cell_set[0].cell_data[0].values.ret_typed_array_ptr(OM_GET_ARRAY_WR, DTYPE_INT, &numElements);

      // connect lists
      int* inConnectList = (int*) inData[1].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      int* outConnectList = (int*) outData.cell_set[0].node_connect_list.ret_array_ptr(OM_GET_ARRAY_WR);

      if(inConnectList && outConnectList && cellData) {
	for(int i = 0; i < numElements; i++) {
	  for(int j = 0; j < 8; j++) {
	    outConnectList[(i * 8) + j] = (inConnectList[(i * 12) + corners[j] + 3] - 1);
	  }
	  cellData[i] = inConnectList[(i * 12) + 11];
	}

	ARRfree(inConnectList);
	ARRfree(outConnectList);
	ARRfree(cellData);
      }
      else {
	ERRverror("RealityGridFEAReader", ERR_WARNING, "Could not allocate memory for the node connectivity list or cell data!");
	return 0;
      }

      // set the elements setup flag
      gotElements = 1;

      //printf("Got initial data: %d coords, %d elements.\n", numCoords, numElements);
    }

    // on subsequent iterations we should only get one data slice:
    // * coordinate displacements.
    else if(slices == 1 && elementsInit) {
      // updated pass
      int numCoords = (int) inData[0].size / 3;

      float* updateCoords = (float*) outData.coordinates.values.ret_array_ptr(OM_GET_ARRAY_WR, NULL, NULL);
      double* displacements = (double*) inData[0].data.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);

      if(updateCoords && displacements && oldCoords) {
	for(int i = 0; i < (numCoords * 3); i++) {
	  updateCoords[i] = oldCoords[i] + (float) displacements[i];
	}

	ARRfree(updateCoords);
	ARRfree(displacements);
      }
      else {
	ERRverror("RealityGridFEAReader", ERR_WARNING, "Memory allocation failure during displacement updates!");
	return 0;
      }

      //printf("Got updated data: %d displacements\n", numCoords);
    }
    else {
	ERRverror("RealityGridFEAReader", ERR_WARNING, "Received unrecognised data!");
	return 0;
    }

    if(corners)
      ARRfree(corners);
  }

  // return 1 for success
  return 1;
}

RealityGridFEA_RealityGridFEAReaderMod::~RealityGridFEA_RealityGridFEAReaderMod() {
  if(oldCoords)
    free(oldCoords);
}
