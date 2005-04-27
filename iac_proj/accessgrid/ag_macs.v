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

flibrary AccessGridMacs {
   macro AccessGridEmitter {

      GD.Templates.GDview_templ &view_in<NEportLevels={2,1}>;
      
      IAC_PROJ.AccessGrid.AccessGridMods.AccessGridParams AccessGridParams {
	 name = "AVS/Express Output";
	 ipaddress = "130.88.1.124";
	 port = 40000;
	 ttl = 127;
	 encoder = 0;
	 maxfps = 24;
	 maxbandwidth = 512;
	 quality = 80;
	 format = 0;
	 border = 150;
	 updateInterval = 2;
	 stream_dims = {352, 288};
	 tile_dims = {1, 1};
      };

      IAC_PROJ.AccessGrid.AccessGridMods.AccessGridBroadcast AccessGridBroadcast {
	 configuration => <-.AccessGridParams;
	 framebuffer => view_in.output.buffers.framebuffer;
	 fliph = 0;
	 flipv = 0;
	 start = 0;
	 connected = 0;
	 frame = 0;
	 refresh = 0;
	 view_output => <-.view_in.output_enabled;
      };

      macro AccessGridEmitterUI {
	 UImod_panel UImod_panel {
	    title = "Access Grid Emitter";
	    width = 250;
	    height = 740;
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
	    label = "Stream name:";
	    width = 85;
	    alignment = 2;
	 };
	 UItext name_text {
	    parent => <-.UImod_panel;
	    text => <-.<-.AccessGridParams.name;
	    width = 160;
	    x => <-.name_label.x + <-.name_label.width;
	    y => <-.name_label.y;
	 };
	 
	 UIlabel address_label {
	    parent => <-.UImod_panel;
	    label = "Address:";
	    width = 85;
	    alignment = 2;
	 };
	 UItext address_text {
	    parent => <-.UImod_panel;
	    text => <-.<-.AccessGridParams.ipaddress;
	    x => <-.address_label.x + <-.address_label.width;
	    y => <-.address_label.y;
	 };
	    
	 UIlabel port_label {
	    parent => <-.UImod_panel;
	    label = "Port:";
	    width = 85;
	    alignment = 2;
	 };
	 UIfield port_field {
	    parent => <-.UImod_panel;
	    value => <-.<-.AccessGridParams.port;
	    width = 55;
	    mode = "integer";
	    x => <-.port_label.x + <-.port_label.width;
	    y => <-.port_label.y;
	 };
	 
	 UIlabel ttl_label {
	    parent => <-.UImod_panel;
	    label = "TTL:";
	    width = 85;
	    alignment = 2;
	 };
	 UIfield ttl_field {
	    parent => <-.UImod_panel;
	    value => <-.<-.AccessGridParams.ttl;
	    width = 40;
	    mode = "integer";
	    x => <-.ttl_label.x + <-.ttl_label.width;
	    y => <-.ttl_label.y;
	 }; 
	 
	 UIoptionMenu encoder_menu {
	    parent => <-.UImod_panel;
	    cmdList => {
	       <-.src0, <-.src1
	    };
	    selectedItem => <-.<-.AccessGridParams.encoder;
	    label => "Encoder";
	 };
	 UIoption src0 {
	    label => "h261";
	 };
	 UIoption src1 {
	    label => "jpeg";
	 };
	 
	 UIlabel tiling_title {
	    parent => <-.UImod_panel;
	    label = "Stream Tiling";
	    width => parent.clientWidth;
	    color {
	       foregroundColor = "white";
	       backgroundColor = "blue";
	    };
	 };

	 UIslider tile_y_slider {
	    parent => <-.UImod_panel;
	    title = "Y";
	    mode = "integer";
	    min = 1.0;
	    max = 5.0;
	    horizontal = 0;
	    width = 50;
	    height = 100;
	    processingDirection = "up";
	    value => <-.<-.AccessGridParams.tile_dims[1];
	 };
	 
	 UIslider tile_x_slider {
	    parent => <-.UImod_panel;
	    title = "X";
	    mode = "integer";
	    min = 1.0;
	    max = 5.0;
	    x = 40;
	    y => <-.tile_y_slider.y + 80;
	    value => <-.<-.AccessGridParams.tile_dims[0];
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
	    set => <-.<-.AccessGridBroadcast.start;
	 };
	 
	 UIslider update_slider {
	    parent => <-.UImod_panel;
	    title = "Update Interval (frames)";
	    mode = "integer";
	    min = 1.0;
	    max = 15.0;
	    width = 245;
	    value => <-.<-.AccessGridParams.updateInterval;
	 };
	 
	 UIslider fps_slider {
	    parent => <-.UImod_panel;
	    title = "Max FPS";
	    mode = "integer";
	    min = 1.0;
	    max = 30.0;
	    width = 245;
	    value => <-.<-.AccessGridParams.maxfps;
	 };
	 
	 /* don't usually want to alter this...
	 UIslider bw_slider {
	    parent => <-.UImod_panel;
	    title = "Max Bandwidth (kb/s)";
	    mode = "integer";
	    min = 128.0;
	    max = 2048.0;
	    width = 245;
	    value => <-.<-.AccessGridParams.maxbandwidth;
	 };
	 */
	 
	 UIslider quality_slider {
	    parent => <-.UImod_panel;
	    title = "Stream Quality";
	    mode = "integer";
	    min = 1.0;
	    max = 100.0;
	    width = 245;
	    value => <-.<-.AccessGridParams.quality;
	 };
	 
	 UIslider colour_slider {
	    parent => <-.UImod_panel;
	    title = "Border Colour";
	    mode = "integer";
	    min = 0.0;
	    max = 255.0;
	    width = 245;
	    value => <-.<-.AccessGridParams.border;
	 };
	 
	 UIoptionMenu format_menu {
	    parent => <-.UImod_panel;
	    cmdList => {
	       <-.form0, <-.form1
	    };
	    selectedItem => <-.<-.AccessGridParams.format;
	    label => "Output Format";
	 };
	 UIoption form0 {
	    label => "ARGB";
	 };
	 UIoption form1 {
	    label => "RGBA";
	 };
	 
	 UItoggle flip_h_toggle {
	    parent => <-.UImod_panel;
	    label = "Flip horizontally";
	    width = 150;
	    set => <-.<-.AccessGridBroadcast.fliph;
	 };
	 
	 UItoggle flip_v_toggle {
	    parent => <-.UImod_panel;
	    label = "Flip vertically";
	    width = 150;
	    set => <-.<-.AccessGridBroadcast.flipv;
	 };
	 
	 UIbutton refresh_button {
	    parent => <-.UImod_panel;
	    label = "Refresh";
	    do => <-.<-.AccessGridBroadcast.refresh;
	 };
      }; // UI   
   }; // AccessGridEmitter
}; // flibrary
