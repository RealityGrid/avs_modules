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
	 connected = 0;
	 pollInterval = 1;
	 numSlices = 0;
	 security_info {
	    initialized = 0;
	    filename = "~/.realitygrid/security.conf";
	    user_name => getenv("USER");
	 };
	 registry_info {
	    address = "https://garfield.mvc.mcc.ac.uk:50010/Session/regServiceGroup/regServiceGroup/228162631063115064971";
	    num_containers = 0;
	    num_entries = 0;
	 };
	 job_info {
	    name = "AVS/Express Visualization";
	    user => switch((<-.security_info.use_ssl + 1), <-.security_info.user_name, <-.security_info.user_dn);
	    sws_address => getenv("REG_SGS_ADDRESS");
	    io_direction = 0;
	    iotype_label = "AVS/Express_Data_Consumer";
	 };
	 reg_sws_source => registry_info.gsh[reg_sws_source_index];
      };
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 get_sws = 0;
	 make_sws = 0;
	 slices => configuration.numSlices;
	 outData.size = 0;
      };

      olink outData => RealityGridSteeringMod.outData;

      macro RealityGridSteererUI {
	 // parent panel
	 UImod_panel UImod_panel {
	    title = "RealityGrid Steerer";
	    width = 250;
	 };

	 // security configuration
	 UIlabel sec_conf_title {
	    parent => <-.UImod_panel;
	    label = "Security configuration";
	    width => parent.clientWidth;
	    color {
	       foregroundColor = "white";
	       backgroundColor = "blue";
	    };
	 };	 

	 UIlabel sec_file_label {
	    parent => <-.UImod_panel;
	    label = "Security file:";
	    width = 120;
	    alignment = 0;
	 };
	 UItext sec_file_text {
	    parent => <-.UImod_panel;
	    width => parent.clientWidth;
	    text => <-.<-.RealityGridSteeringParams.security_info.filename;
	 };

	 UIlabel user_cert_pass_label {
	    parent => <-.UImod_panel;
	    width = 120;
	    label = "Cert password:";
	    alignment = 2;
	 };
	 IAC_PROJ.UIpasswordMod.UIpassword user_cert_pass_text {
	    parent => <-.UImod_panel;
	    x => <-.user_cert_pass_label.x + <-.user_cert_pass_label.width;
	    y => <-.user_cert_pass_label.y;
	    width => parent.clientWidth - <-.user_cert_pass_label.width;
	    password => <-.<-.RealityGridSteeringParams.security_info.user_password;
	 };

	 // registry configuration
	 UIlabel reg_conf_title {
	    parent => <-.UImod_panel;
	    label = "Registry configuration";
	    width => parent.clientWidth;
	    color {
	       foregroundColor = "white";
	       backgroundColor = "blue";
	    };
	 };	 
	 
 	 UIlabel reg_label {
 	    parent => <-.UImod_panel;
 	    label = "Registry address:";
 	    width = 120;
 	    alignment = 0;
	 };
 	 UItext reg_text {
 	    parent => <-.UImod_panel;
 	    width => parent.clientWidth;
 	    text => <-.<-.RealityGridSteeringParams.registry_info.address;
 	 };

 	 UIlabel reg_pass_label {
 	    parent => <-.UImod_panel;
 	    label = "Registry password:";
 	    width = 120;
 	    alignment = 2;
	    int sw_i = 1;
	    switch sw {
	       int index => sw_i;
	       int val1 = 1;
	       int val2 = 0;
	    };
	    active => sw;
	 };
 	 IAC_PROJ.UIpasswordMod.UIpassword reg_pass_text {
 	    parent => <-.UImod_panel;
	    x => <-.reg_pass_label.x + <-.reg_pass_label.width;
	    y => <-.reg_pass_label.y;
	    width => parent.clientWidth - <-.reg_pass_label.width;
	    password => <-.<-.RealityGridSteeringParams.job_info.passphrase;
	    active => <-.reg_pass_label.active;
	 };
	 
	 // sws configuration
	 UIlabel sws_conf_title {
	    parent => <-.UImod_panel;
	    label = "SWS configuration";
	    width => parent.clientWidth;
	    color {
	       foregroundColor = "white";
	       backgroundColor = "blue";
	    };
	 };	 

	 UIlabel sws_label {
	    parent => <-.UImod_panel;
	    label = "SWS address:";
	    width = 85;
	    alignment = 2;
	 };
	 UIbutton sws_button {
	    parent => <-.UImod_panel;
	    label = "Generate SWS...";
	    x => parent.clientWidth - width;
	    y => <-.sws_label.y;
	    width = 120;
	    do => <-.<-.RealityGridSteeringMod.get_sws;
	 };
	 UItext sws_text {
	    parent => <-.UImod_panel;
	    text => <-.<-.RealityGridSteeringParams.job_info.sws_address;
	    width => parent.clientWidth;
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
	       height = 588;
	       visible => <-.<-.<-.RealityGridSteeringMod.get_sws;
	       ok => <-.<-.<-.RealityGridSteeringMod.make_sws;
	    };
	    
	    UIpanel UIpanel {
	       parent => <-.UItemplateDialog;
	       y = 0;
	       x = 5;
	       width => parent.width;
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
	       text => <-.<-.<-.RealityGridSteeringParams.job_info.name;
	    };
	    
	    UIlabel user_label {
	       parent => <-.UIpanel;
	       y => (<-.app_label.y + <-.app_label.height + 6);
	       width = 85;
	       label => switch((<-.<-.<-.RealityGridSteeringParams.security_info.use_ssl + 1), "User name:", "User DN:");
	       alignment = "right";
	    };
	    UItext user_name {
	       parent => <-.UIpanel;
	       y => <-.user_label.y;
	       x => (<-.user_label.x + <-.user_label.width);
	       width => (parent.width - <-.user_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.job_info.user;
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
	       text => <-.<-.<-.RealityGridSteeringParams.job_info.org;
	    };
	    
	    UIlabel desc_label {
	       parent => <-.UIpanel;
	       y => (<-.org_label.y + <-.org_label.height + 6);
	       width = 85;
	       label = "Purpose:";
	       alignment = "right";
	    };
	    UItext desc_text {
	       parent => <-.UIpanel;
	       y => <-.desc_label.y;
	       x => (<-.desc_label.x + <-.desc_label.width);
	       width => (parent.width - <-.desc_label.width - 3);
	       text => <-.<-.<-.RealityGridSteeringParams.job_info.purpose;
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
	       text => <-.<-.<-.RealityGridSteeringParams.job_info.start_time;
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
	       value => <-.<-.<-.RealityGridSteeringParams.job_info.lifetime;
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
	       selectedItem => <-.<-.<-.RealityGridSteeringParams.job_info.io_direction;
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
	       active => <-.connect_label.active;
	       stringdims => <-.<-.<-.RealityGridSteeringParams.registry_info.num_entries;
	       strings => <-.<-.<-.RealityGridSteeringParams.registry_info.summary;
	       selectedItem => <-.<-.<-.RealityGridSteeringParams.reg_sws_source_index;
	    };

	    UIlabel job_pass_label {
	       parent => <-.UIpanel;
	       y => (<-.connect_list.y + <-.connect_list.height);
	       width = 105;
	       label = "Job passphrase:";
	       alignment = "right";
	    };
	    IAC_PROJ.UIpasswordMod.UIpassword job_pass_text {
	       parent => <-.UIpanel;
	       x => <-.job_pass_label.width;
	       y => <-.job_pass_label.y;
	       width => parent.clientWidth - <-.job_pass_label.width;
	       password => <-.<-.<-.RealityGridSteeringParams.job_info.passphrase;
	    };
	    
	    UIlabel container_label {
	       parent => <-.UIpanel;
	       y => (<-.job_pass_label.y + <-.job_pass_label.height);
	       //y => (<-.connect_list.y + <-.connect_list.height);
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
