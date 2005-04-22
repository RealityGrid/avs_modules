/*-----------------------------------------------------------------------

  This file is part of the RealityGrid AVS Access Grid Broadcast Module.

  (C) Copyright 2004, University of Manchester, United Kingdom,
  all rights reserved.

  This software is produced by the Supercomputing, Visualization and
  e-Science Group, Manchester Computing, University of Manchester
  as part of the RealityGrid project (http://www.realitygrid.org),
  funded by the EPSRC under grants GR/R67699/01 and GR/R67699/02.

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

flibrary AccessGridMods <
   build_dir="iac_proj/accessgrid",
   out_hdr_file="ag_gen.hxx",
   out_src_file="ag_gen.cxx",
   link_files="-L$(FLX_DIR) -L$(ACE_DIR)/ace -lFLX -lACE",
   cxx_src_files="AGBroadcastMod.cxx",
   cxx_hdr_files="AGBroadcastMod.hxx fld/Xfld.h",
   hdr_dirs="$(FLX_DIR) $(ACE_DIR)",
   cxx_name="" > {

   // define the config parameters group
   group AccessGridParams<NEportLevels={0,1}> {
      string name;
      string ipaddress;
      int port;
      int ttl;
      enum encoder {
	 choices = {"h261", "jpeg"};
      };
      int maxfps;
      int maxbandwidth;
      int quality;
      enum format {
	 choices = {"ARGB", "RGBA"};
      };
      int border;
      int updateInterval;
   };

   // define the low-level module
   module AccessGridBroadcast<
      src_file="AccessGridBroadcast.cxx",
      cxx_class="AGBroadcastMod"
      > {
	 cxxmethod init(
	    configuration+read+req,
	    connected+read,
	    start+notify+read+write
	 );
	 cxxmethod update(
	    configuration+notify+read+req,
	    view_output+read+write,
	    start+notify+read,
	    fliph+notify+read,
	    flipv+notify+read
	 );
	 cxxmethod broadcast(
	    configuration+read+req,
	    framebuffer+notify+read+req,
	    start+read,
	    frame+read+write,
	    connected+read,
	    refresh+notify+read
	 );
	 Mesh_Unif+Node_Data &framebuffer<NEportLevels={2,0}>;
	 AccessGridParams &configuration <NEportLevels={2,0}>;
	 int fliph;
	 int flipv;
	 int start;
	 int connected;
	 int frame;
	 int refresh;
	 int view_output;
   };
};
