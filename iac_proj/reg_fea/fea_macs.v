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
   macro RealityGridFEAReader {

      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringParams RealityGridSteeringParams {
	 reg_sgs_name = "AVS/Express FEA Reader";
	 connected = 0;
	 pollInterval = 2;
	 numSlices = 0;
      };
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 slices => configuration.numSlices;
	 outData.size = 0;
      };

      IAC_PROJ.RealityGridFEA.RealityGridFEAMods.RealityGridFEAReaderMod RealityGridFEAReaderMod {
	 inData => <-.RealityGridSteeringMod.outData;
	 elementConnectivity[8] = {4, 0, 1, 5, 7, 3, 2, 6};
	 gotElements = 0;
      };

      olink outData => RealityGridFEAReaderMod.outData;

      macro RealityGridFEAReaderUI {
	 UImod_panel UImod_panel {
	    title = "RealityGrid FEA Reader";
	    width = 250;
	 };

	 macro ConfigUI {
	    UIframe config_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 90;
	    };
	    UIlabel config_label {
	       parent => <-.config_frame;
	       label = "Configuration";
	       width = 250;
	       alignment = 1;
	    };
	    
	    UIlabel name_label {
	       parent => <-.config_frame;
	       label = "SGS name:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext name_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_name;
	       width = 160;
	       x => <-.name_label.x + <-.name_label.width;
	       y => <-.name_label.y;
	    };

	    UIlabel sgs_label {
	       parent => <-.config_frame;
	       label = "SGS address:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext sgs_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_address;
	       width = 160;
	       x => <-.sgs_label.x + <-.sgs_label.width;
	       y => <-.sgs_label.y;
	    };
	 }; // ConfigUI

	 macro ControlUI {
	    UIframe control_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 138;
	    };
	    UIlabel control_label {
	       parent => <-.control_frame;
	       label = "Control";
	       width = 250;
	       alignment = 1;
	    };

	    UIslider poll_slider {
	       parent => <-.control_frame;
	       title = "Data polling interval (secs)";
	       mode = "integer";
	       min = 1.0;
	       max = 15.0;
	       width = 245;
	       value => <-.<-.<-.RealityGridSteeringParams.pollInterval;
	    };
	    
	    UItoggle start_toggle {
	       parent => <-.control_frame;
	       label = "Connect";
	       set => <-.<-.<-.RealityGridSteeringMod.start;
	    };

	    UItoggle poll_toggle {
	       parent => <-.control_frame;
	       label = "Poll for data";
	       set => <-.<-.<-.RealityGridSteeringMod.nudge;
	    };
	 }; // ControlUI


      }; // RealityGridFEAReaderUI
      
   }; // RealityGridFEAReader
}; // RealityGridFEAMacs
