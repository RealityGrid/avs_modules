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

flibrary RealityGridMods <
   build_dir="iac_proj/reg_steer",
   out_hdr_file="reg_gen.hxx",
   out_src_file="reg_gen.cxx",
   link_files="-L$(REG_XML_LIBDIR) -L$(REG_STEER_LIB) -lReG_Steer -lxml2",
   cxx_src_files="ReGSteerMod.cxx",
   cxx_hdr_files="ReGSteerMod.hxx avs/event.h fld/Xfld.h",
   hdr_dirs="$(REG_STEER_HOME)/include",
   cxx_name="" > {

   // define the config parameters group
   group RealityGridSteeringParams<NEportLevels={0,1}> {
      string reg_sgs_name;
      string reg_sgs_address;
      string iotype_label;
      int connected;
      float pollInterval;
      int numSlices;
   };

   // define the data slice group
   group RealityGridDataSlice<NEportLevels={0,1},NEcolor0=16711680,NEcolor1=65280,NEnumColors=2> {
      enum type {
	 choices = {"char", "int", "float", "double"};
      };
      int size;
      prim data[size];
   };
   
   // define the low level steering module
   module RealityGridSteeringMod<
      src_file="RealityGridSteeringMod.cxx",
      cxx_members="      ReGSteerMod* modInst;
      float oldPollInterval;
      friend void poller(RealityGrid_RealityGridSteeringMod*);
      ~RealityGrid_RealityGridSteeringMod();\n"
      > {
	 cxxmethod init(
	    configuration+read+write+req,
	    start+notify+read
	 );
	 cxxmethod update(
	    configuration+notify+read+req
	 );
	 RealityGridSteeringParams &configuration<NEportLevels={2,0}>;
	 int initialized;
	 int start;
	 int connected;
	 int nudge;
	 int slices;
	 
	 // data output array
	 RealityGridDataSlice outData<NEportLevels={0,2}>[slices];
   }; // RealityGridSteeringMod

   // define the low level slice compositor module
   module RealityGridDataSliceCompositorMod<
      src_file="RealityGridDataSliceCompositorMod.cxx"
      > {
	 cxxmethod join(
	    inData+notify+read+req,
	    numSlices+read,
	    outCharData+write,
	    outIntData+write,
	    outFloatData+write,
	    outDoubleData+write
	 );

	 // input data
	 RealityGridDataSlice &inData<NEportLevels={2,0}>[];

	 // the number of data slices of data
	 int numSlices => array_size(inData);
	 
	 // output data
	 char outCharData<NEportLevels={0,2}>[];
	 int outIntData<NEportLevels={0,2}>[];
	 float outFloatData<NEportLevels={0,2}>[];
	 double outDoubleData<NEportLevels={0,2}>[];
   }; // RealityGridDataSliceCompositorMod
};
