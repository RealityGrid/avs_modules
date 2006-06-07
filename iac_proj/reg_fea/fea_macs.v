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

flibrary RealityGridFEAMacs {
   macro ReG_coord_maths {
      ilink in_data;
      
      DVcoord_math DVcoord_math {
	 in1 => <-.in_data;
	 operation_x => <-.X;
	 operation_y => <-.Y;
	 operation_z => <-.Z;
      };

      float scale<NEportLevels={0,1}>;
      
      string X<NEportLevels={0,1}>;
      string Y<NEportLevels={0,1}>;
      string Z<NEportLevels={0,1}>;

      olink out_data => DVcoord_math.out;
   };
   
   macro RealityGridFEAReader {
      
      IAC_PROJ.RealityGrid.RealityGridMacs.RealityGridSteerer RealityGridSteerer {
	 RealityGridSteeringParams {
	    job_info.name = "AVS/Express FEA Reader";
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
	       title = "RealityGrid FEA Reader";
	    };

	    UIlabel disps_title {
	       parent => <-.UImod_panel;
	       label = "Displacements";
	       width => parent.clientWidth;
	       color {
		  foregroundColor = "white";
		  backgroundColor = "blue";
	       };
	    };	 

	    UIslider disps_slider {
	       parent => <-.UImod_panel;
	       title = "Displacement scaling";
	       mode = "real";
	       decimalPoints = 1;
	       min = 0.1;
	       max = 50.0;
	       width = 245;
	       value => <-.<-.<-.ReG_coord_maths.scale;
	    };

	    /*
	    UIlabel stress_title {
	       parent => <-.UImod_panel;
	       label = "Stresses";
	       width => parent.clientWidth;
	       color {
		  foregroundColor = "white";
		  backgroundColor = "blue";
	       };
	    };
	    */

	 }; // RealityGridSteererUI
      };

      IAC_PROJ.RealityGridFEA.RealityGridFEAMods.RealityGridFEAReaderMod RealityGridFEAReaderMod {
	 inData => <-.RealityGridSteerer.outData;
	 elementConnectivity[8] = {4, 0, 1, 5, 7, 3, 2, 6};
	 gotElements = 0;
      };

      IAC_PROJ.RealityGridFEA.RealityGridFEAMacs.ReG_coord_maths ReG_coord_maths {
	 in_data => RealityGridFEAReaderMod.outData;
	 scale = 1.0;
	 X = "#1x + (in_data.node_data[0].values[][0] * scale)";
	 Y = "#1y + (in_data.node_data[0].values[][1] * scale)";
	 Z = "#1z + (in_data.node_data[0].values[][2] * scale)";
      };
      
      olink outData => RealityGridFEAReaderMod.outData;
      olink outDataDisps => ReG_coord_maths.out_data;
      
   }; // RealityGridFEAReader
}; // RealityGridFEAMacs
