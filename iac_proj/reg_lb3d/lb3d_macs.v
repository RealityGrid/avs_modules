/* ----------------------------------------------------------------------------
  This file is part of the RealityGrid AVS/Express LB3D Module.
 
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

flibrary RealityGridLB3DMacs {
   macro RealityGridLB3DReader {

      ilink inField;

      IAC_PROJ.RealityGrid.RealityGridMacs.RealityGridSteerer RealityGridSteerer {
	 RealityGridSteeringParams {
	    reg_sgs_name = "AVS/Express LB3D Reader";
	    connected = 0;
	    pollInterval = 1.0;
	    numSlices = 0;
	 };

	 RealityGridSteeringMod {
	    initialized = 0;
	    connected => configuration.connected;
	    slices => configuration.numSlices;
	    outData.size = 0;
	 };

	 RealityGridSteererUI {
	    UImod_panel {
	       title = "RealityGrid LB3D Reader";
	    };
	 };
      };

      IAC_PROJ.RealityGridLB3D.RealityGridLB3DMods.RealityGridLB3DReaderMod RealityGridLB3DReaderMod {
	 configuration => <-.RealityGridSteerer.RealityGridSteeringParams;
	 inData => <-.RealityGridSteerer.outData;
	 inField => <-.inField;
	 volOutput = 1;
	 minLabel = 0.0;
	 maxLabel = 0.0;
      };

      FLD_MAP.Mesh_Mappers.uniform_mesh uniform_mesh {
	 in_dims => <-.RealityGridLB3DReaderMod.outDims;
      };

      FLD_MAP.Data_Mappers.node_scalar node_scalar {
	 in_data => <-.RealityGridLB3DReaderMod.outData;
      };

      FLD_MAP.Data_Mappers.node_scalar node_scalar_short {
	 in_data => <-.RealityGridLB3DReaderMod.outShortData;
      };
      
      FLD_MAP.Data_Mappers.node_scalar node_scalar_byte {
	 in_data => <-.RealityGridLB3DReaderMod.outByteData;
      };
      
      FLD_MAP.Combiners.combine_mesh_data combine_mesh_data {
	 in_mesh => <-.uniform_mesh.out;
	 in_nd => <-.node_scalar.out;
      };
      
      FLD_MAP.Combiners.combine_mesh_data combine_mesh_data_short {
	 in_mesh => <-.uniform_mesh.out;
	 in_nd => <-.node_scalar_short.out;
      };
      
      FLD_MAP.Combiners.combine_mesh_data combine_mesh_data_byte {
	 in_mesh => <-.uniform_mesh.out;
	 in_nd => <-.node_scalar_byte.out;
      };
      
      olink outData => combine_mesh_data.out;
      olink outShortData => combine_mesh_data_short.out;
      olink outByteData => combine_mesh_data_byte.out;

   }; // RealityGridLBE3DReader
};
