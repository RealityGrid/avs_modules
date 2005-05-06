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

flibrary RealityGridFEAMods <
   build_dir="iac_proj/reg_fea",
   out_hdr_file="fea_gen.hxx",
   out_src_file="fea_gen.cxx",
   cxx_hdr_files="../reg_steer/reg_gen.hxx fld/Xfld.h",
   cxx_name="" > {

   // define the low-level mod
   module RealityGridFEAReaderMod<
      src_file="RealityGridFEAReaderMod.cxx",
      cxx_members="      ~RealityGridFEA_RealityGridFEAReaderMod();\n"
      > {
	 cxxmethod update(
	    inData+notify+read+req,
	    elementConnectivity+read,
	    numSlices+read,
	    gotElements+read+write,
	    outData+write
	 );

	 // inputs
	 IAC_PROJ.RealityGrid.RealityGridMods.RealityGridDataSlice &inData<NEportLevels={2,0}>[];

	 // the connectivity of the elements
	 int elementConnectivity[];
	 
	 // the number of data slices
	 int numSlices => array_size(inData);

	 // have we already got our element data?
	 int gotElements;
	 
	 // outputs
	 Field outData<NEportLevels={0,2}>;
	 
   }; // RealityGridFEAReaderMod
};
