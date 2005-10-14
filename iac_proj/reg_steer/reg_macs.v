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
	 reg_sgs_name = "AVS/Express Visualization";
	 reg_sgs_user => getenv("USER");
	 reg_sgs_address => getenv("REG_SGS_ADDRESS");
	 reg_io_direction = 0;
	 iotype_label = "AVS/Express_Data_Consumer";
	 connected = 0;
	 pollInterval = 1;
	 numSlices = 0;
	 registry_info {
	    address = "http://bala.mvc.mcc.ac.uk:50005/Session/myServiceGroup/myServiceGroup/4116153071052241078568";
	    num_containers = 0;
	    num_entries = 0;
	 };
	 reg_sgs_source => registry_info.gsh[reg_sgs_source_index];
      };
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 get_sgs = 0;
	 make_sgs = 0;
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
	 
// 	 UIlabel name_label {
// 	    parent => <-.UImod_panel;
// 	    label = "SWS name:";
// 	    width = 85;
// 	    alignment = 2;
// 	 };
// 	 UItext name_text {
// 	    parent => <-.UImod_panel;
// 	    text => <-.<-.RealityGridSteeringParams.reg_sgs_name;
// 	    width = 160;
// 	    x => <-.name_label.x + <-.name_label.width;
// 	    y => <-.name_label.y;
// 	 };

	 UIlabel sgs_label {
	    parent => <-.UImod_panel;
	    label = "SWS address:";
	    width = 85;
	    alignment = 2;
	 };
	 UIbutton sgs_button {
	    parent => <-.UImod_panel;
	    label = "Generate SWS...";
	    x => <-.sgs_label.x + <-.sgs_label.width;
	    y => <-.sgs_label.y;
	    width = 120;
	    do => <-.<-.RealityGridSteeringMod.get_sgs;
	 };
	 UItext sgs_text {
	    parent => <-.UImod_panel;
	    text => <-.<-.RealityGridSteeringParams.reg_sgs_address;
	    width = 160;
	    x => <-.sgs_label.x + <-.sgs_label.width;
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
	 
         macro RealityGridSWSDialog {
	    UItemplateDialog UItemplateDialog {
	       parent<NEportLevels={3,0}>;
	       title = "Generate SWS...";
	       x = 76;
	       y = 225;
	       width = 300;
	       height = 570;
	       visible => <-.<-.<-.RealityGridSteeringMod.get_sgs;
	       ok => <-.<-.<-.RealityGridSteeringMod.make_sgs;
	    };
	    
	    UIpanel UIpanel {
	       parent => <-.UItemplateDialog;
	       y = 0;
	       width => parent.width;
	       x = 5;
	       height => parent.height;
	    };
	    
	    UIlabel app_title {
	       parent => <-.UIpanel;
	       label = "Application Details";
	       x = 3;
	       y = 4;
	       width => (parent.width - 8);
	       color {
		  foregroundColor = "white";
		  backgroundColor = "blue";
	       };
	    };
	    
	    UIlabel app_label {
	       parent => <-.UIpanel;
	       y => (<-.app_title.y + <-.app_title.height + 4);
	       width = 85;
	       label = "App name:";
	       alignment = "right";
	    };
	    UItext app_name {
	       parent => <-.UIpanel;
	       x => (<-.app_label.x + <-.app_label.width);
	       y => <-.app_label.y;
	       width => (parent.width - <-.app_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_name;
	    };
	    
	    UIlabel user_label {
	       parent => <-.UIpanel;
	       y => (<-.app_label.y + <-.app_label.height + 6);
	       width = 85;
	       label = "User name:";
	       alignment = "right";
	    };
	    UItext user_name {
	       parent => <-.UIpanel;
	       y => <-.user_label.y;
	       x => (<-.user_label.x + <-.user_label.width);
	       width => (parent.width - <-.user_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_user;
	    };
	    
	    UIlabel org_label {
	       parent => <-.UIpanel;
	       y => (<-.user_label.y + <-.user_label.height + 6);
	       width = 85;
	       label = "Organisation:";
	       alignment = "right";
	    };
	    UItext org_name {
	       parent => <-.UIpanel;
	       y => <-.org_label.y;
	       x => (<-.org_label.x + <-.org_label.width);
	       width => (parent.width - <-.org_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_organisation;
	    };
	    
	    UIlabel desc_label {
	       parent => <-.UIpanel;
	       y => (<-.org_label.y + <-.org_label.height + 6);
	       width = 85;
	       label = "Description:";
	       alignment = "right";
	    };
	    UItext desc_text {
	       parent => <-.UIpanel;
	       y => <-.desc_label.y;
	       x => (<-.desc_label.x + <-.desc_label.width);
	       width => (parent.width - <-.desc_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_description;
	    };
	    
	    UIlabel time_label {
	       parent => <-.UIpanel;
	       y => (<-.desc_label.y + <-.desc_label.height + 6);
	       width = 85;
	       label = "Timestamp:";
	       alignment = "right";
	    };
	    UItext time_text {
	       parent => <-.UIpanel;
	       y => <-.time_label.y;
	       x => (<-.time_label.x + <-.time_label.width);
	       width => (parent.width - <-.time_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_start_time;
	    };
	    
	    UIlabel con_title {
	       parent => <-.UIpanel;
	       x = 3;
	       y => (<-.time_label.y + <-.time_label.height + 8);
	       label => "Connection Details";
	       width => (parent.width - 8);
	       color {
		  foregroundColor = "white";
		  backgroundColor = "blue";
	       };
	    };
	    
	    UIlabel lifetime_label {
	       parent => <-.UIpanel;
	       y => (<-.con_title.y + <-.con_title.height + 4);
	       width = 85;
	       label = "Lifetime:";
	       alignment = "right";
	    };
	    UIfield lifetime_text {
	       parent => <-.UIpanel;
	       y => <-.lifetime_label.y;
	       x => (<-.lifetime_label.x + <-.lifetime_label.width);
	       width => (parent.width - <-.lifetime_label.width - 3);
	       mode = "integer";
	       min = 0;
	       nullString = "";
	       value => <-.<-.<-.RealityGridSteeringParams.reg_sgs_lifetime;
	    };

	    UIoptionMenu io_dir {
	       parent => <-.UIpanel;
	       x = 8;
	       y => (<-.lifetime_label.y + <-.lifetime_label.height + 6);
	       cmdList => {
		  <-.io_opt_0,
	          <-.io_opt_1,
	          <-.io_opt_2
	       };
	       selectedItem => <-.<-.<-.RealityGridSteeringParams.reg_io_direction;
	       label = "IO Direction:";
	    };
	    UIoption io_opt_0 {
	       label = "IN";
	       set = 1;
	    };
	    UIoption io_opt_1 {
	       label = "OUT";
	    };
	    UIoption io_opt_2 {
	       label = "INOUT";
	    };
	    
	    UIlabel connect_label {
	       parent => <-.UIpanel;
	       y => (<-.io_dir.y + <-.io_dir.height);
	       width = 85;
	       label = "Connect to:";
	       alignment = "right";
	       active => switch((<-.io_dir.selectedItem + 1), 1, 0, 1);
	    };
	    UIlist connect_list {
	       parent => <-.UIpanel;
	       x = 3;
	       y => (<-.connect_label.y + <-.connect_label.height);
	       width => (parent.width - 8);
	       active => switch((<-.io_dir.selectedItem + 1), 1, 0, 1);
	       stringdims => <-.<-.<-.RealityGridSteeringParams.registry_info.num_entries;
	       strings => <-.<-.<-.RealityGridSteeringParams.registry_info.summary;
	       selectedItem => <-.<-.<-.RealityGridSteeringParams.reg_sgs_source_index;
	    };
	    
	    UIlabel container_label {
	       parent => <-.UIpanel;
	       y => (<-.connect_list.y + <-.connect_list.height);
	       width = 85;
	       label = "Container:";
	       alignment = "right";
	    };
	    UIlist container_list {
	       parent => <-.UIpanel;
	       x = 3;
	       y => (<-.container_label.y + <-.container_label.height);
	       width => (parent.width  - 8);
	       stringdims => <-.<-.<-.RealityGridSteeringParams.registry_info.num_containers;
	       strings => <-.<-.<-.RealityGridSteeringParams.registry_info.containers;
	       selectedText => <-.<-.<-.RealityGridSteeringParams.use_container;
	    };
	 }; // RealityGridSWSDialog
	 
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
