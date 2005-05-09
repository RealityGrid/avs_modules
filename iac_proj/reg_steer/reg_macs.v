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

flibrary RealityGridMacs {
   macro RealityGridSteerer {
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringParams RealityGridSteeringParams {
	 reg_sgs_name = "AVS/Express Sink";
	 connected = 0;
	 pollInterval = 1;
	 numSlices = 0;
      };
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 slices => configuration.numSlices;
	 outData.size = 0;
      };

      olink outData => RealityGridSteeringMod.outData;

      macro RealityGridSteererUI {
	 UImod_panel UImod_panel {
	    title = "RealityGrid Steerer";
	    width = 250;
	 };

	 UIlabel config_title {
	    parent => <-.UImod_panel;
	    label = "Configuration";
	    width => parent.clientWidth;
	    color {
	       foregroundColor = "white";
	       backgroundColor = "blue";
	    };
	 };	 
	 
	 UIlabel name_label {
	    parent => <-.UImod_panel;
	    label = "SGS name:";
	    width = 85;
	    alignment = 2;
	 };
	 UItext name_text {
	    parent => <-.UImod_panel;
	    text => <-.<-.RealityGridSteeringParams.reg_sgs_name;
	    width = 160;
	    x => <-.name_label.x + <-.name_label.width;
	    y => <-.name_label.y;
	 };

	 UIlabel sgs_label {
	    parent => <-.UImod_panel;
	    label = "SGS address:";
	    width = 85;
	    alignment = 2;
	 };
	 UItext sgs_text {
	    parent => <-.UImod_panel;
	    text => <-.<-.RealityGridSteeringParams.reg_sgs_address;
	    width = 160;
	    x => <-.sgs_label.x + <-.sgs_label.width;
	    y => <-.sgs_label.y;
	 };

	 UIlabel control_title {
	    parent => <-.UImod_panel;
	    label = "Control";
	    width => parent.clientWidth;
	    color {
	       foregroundColor = "white";
	       backgroundColor = "blue";
	    };
	 };
	 
	 UIslider poll_slider {
	    parent => <-.UImod_panel;
	    title = "Data polling interval (secs)";
	    mode = "real";
	    decimalPoints = 1;
	    min = 0.1;
	    max = 15.0;
	    width = 245;
	    value => <-.<-.RealityGridSteeringParams.pollInterval;
	 };
	 
	 UItoggle start_toggle {
	    parent => <-.UImod_panel;
	    label = "Connect";
	    set => <-.<-.RealityGridSteeringMod.start;
	 };
	 
	 UItoggle poll_toggle {
	    parent => <-.UImod_panel;
	    label = "Poll for data";
	    set => <-.<-.RealityGridSteeringMod.nudge;
	 };
      }; // RealityGridSteererUI
   }; // RealityGridSteerer

   macro RealityGridDataSliceCompositor {

      ilink inData;
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridDataSliceCompositorMod RealityGridDataSliceCompositorMod {
	 inData => <-.inData;
      };

      olink outCharData => RealityGridDataSliceCompositorMod.outCharData;
      olink outIntData => RealityGridDataSliceCompositorMod.outIntData;
      olink outFloatData => RealityGridDataSliceCompositorMod.outFloatData;
      olink outDoubleData => RealityGridDataSliceCompositorMod.outDoubleData;
      
   }; // RealityGridDataSliceCompositor

}; // RealityGridMacs
