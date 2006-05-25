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
   link_files="-L$(REG_XML_LIBDIR) -L$(REG_STEER_LIB) -lReG_Steer -lReG_Steer_Utils -lxml2 -lssl -lcrypto",
   cxx_src_files="ReGSteerMod.cxx",
   cxx_hdr_files="ReGSteerMod.hxx avs/event.h fld/Xfld.h",
   hdr_dirs="$(REG_XML_INCDIR) $(REG_STEER_HOME)/include",
   cxx_name="" > {

   // define the registry info group
   group RealityGridRegistryInfo<NEportLevels={0,1}> {
      string address;
      int+nosave num_containers;
      string+nosave containers[num_containers];
      int+nosave num_entries;
      string+nosave gsh[num_entries];
      string+nosave entry_gsh[num_entries];
      string+nosave app_name[num_entries];
      string+nosave user_name[num_entries];
      string+nosave org_name[num_entries];
      string+nosave start_time[num_entries];
      string+nosave description[num_entries];
      string+nosave summary[num_entries];
   };

   // define the security info group
   group RealityGridSecurityInfo<NEportLevels={0,1}> {
      int+nosave initialized;
      string filename;
      string+nosave ca_cert_path;
      string+nosave user_cert_path;
      string+nosave user_dn;        // for SSL
      string+nosave user_name;      // for no SSL
      ptr+nosave user_password;
      int+nosave use_ssl;
   };

   // define the job info group
   group RealityGridJobInfo<NEportLevels={0,1}> {
      string+nosave name;       // == software
      string+nosave user;
      string+nosave org;        // == group
      string+nosave start_time;
      string+nosave purpose;
      ptr+nosave passphrase;
      int+nosave lifetime;
      string+nosave sws_address;
      int+nosave io_direction;
      string+nosave iotype_label;
   };
   
   // define the config parameters group
   group RealityGridSteeringParams<NEportLevels={0,1}> {
      int+nosave connected;
      float+nosave pollInterval;
      int+nosave numSlices;
      RealityGridSecurityInfo security_info;
      RealityGridRegistryInfo registry_info;
      RealityGridJobInfo job_info;
      int+nosave reg_sws_source_index;
      string reg_sws_source;
      string+nosave use_container;
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
	 cxxmethod+notify_inst pre_init<NEvisible=0>(
	    initialized+read+write
	 );
	 cxxmethod init(
	    initialized+read,
	    configuration+read+write+req,
	    start+notify+read
	 );
	 cxxmethod update(
	    initialized+read,
	    configuration+notify+read+req
	 );
	 cxxmethod wsrf_ops(
	    initialized+read,
	    get_sws+notify+read+write,
	    make_sws+read+write,
	    configuration+read+write+req
	 );
	 RealityGridSteeringParams &configuration<NEportLevels={2,0}>;
	 int+nosave initialized;
	 int+nosave start;
	 int+nosave connected;
	 int+nosave nudge;
	 int+nosave get_sws;
	 int+nosave make_sws;
	 int+nosave slices;
	 
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
