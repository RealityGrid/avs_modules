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
	 maxfps = 10;
	 maxbandwidth = 512;
	 quality = 75;
	 format = 0;
	 border = 150;
	 updateInterval = 1;
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
	 };
	 
	 macro ConfigUI {
	    UIframe config_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 190;
	    };
	    UIlabel config_label {
	       parent => <-.config_frame;
	       label = "Configuration";
	       width = 250;
	       alignment = 1;
	    };
	 	 
	    UIlabel name_label {
	       parent => <-.config_frame;
	       label = "Stream name:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext name_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.AccessGridParams.name;
	       width = 160;
	       x => <-.name_label.x + <-.name_label.width;
	       y => <-.name_label.y;
	    };

	    UIlabel address_label {
	       parent => <-.config_frame;
	       label = "Address:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext address_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.AccessGridParams.ipaddress;
	       x => <-.address_label.x + <-.address_label.width;
	       y => <-.address_label.y;
	    };
	    
	    UIlabel port_label {
	       parent => <-.config_frame;
	       label = "Port:";
	       width = 85;
	       alignment = 2;
	    };
	    UIfield port_field {
	       parent => <-.config_frame;
	       value => <-.<-.<-.AccessGridParams.port;
	       width = 55;
	       mode = "integer";
	       x => <-.port_label.x + <-.port_label.width;
	       y => <-.port_label.y;
	    };
	 
	    UIlabel ttl_label {
	       parent => <-.config_frame;
	       label = "TTL:";
	       width = 85;
	       alignment = 2;
	    };
	    UIfield ttl_field {
	       parent => <-.config_frame;
	       value => <-.<-.<-.AccessGridParams.ttl;
	       width = 40;
	       mode = "integer";
	       x => <-.ttl_label.x + <-.ttl_label.width;
	       y => <-.ttl_label.y;
	    }; 

	    UIoptionMenu encoder_menu {
	       parent => <-.config_frame;
	       cmdList => {
		  <-.src0, <-.src1
	       };
	       selectedItem => <-.<-.<-.AccessGridParams.encoder;
	       label => "Encoder";
	    };
	    UIoption src0 {
	       label => "h261";
	    };
	    UIoption src1 {
	       label => "jpeg";
	    };
	 }; // ConfigUI

	 macro ControlUI {
	    UIframe control_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 345;
	    };
	    UIlabel control_label {
	       parent => <-.control_frame;
	       label = "Control";
	       width = 250;
	       alignment = 1;
	    };

	    UItoggle start_toggle {
	       parent => <-.control_frame;
	       label = "Connect";
	       set => <-.<-.<-.AccessGridBroadcast.start;
	    };
	 
	    UIslider update_slider {
	       parent => <-.control_frame;
	       title = "Update Interval (frames)";
	       mode = "integer";
	       min = 1.0;
	       max = 15.0;
	       width = 245;
	       value => <-.<-.<-.AccessGridParams.updateInterval;
	    };
	 
	    /* Crashes FLXmitter at present!
	    UIslider fps_slider {
	       parent => <-.control_frame;
	       title = "Max FPS";
	       mode = "integer";
	       min = 5.0;
	       max = 24.0;
	       width = 250;
	       value => <-.<-.<-.AccessGridParams.maxfps;
	    };
	    */
	    
	    /* Doesn't seem to do anything!
	    UIslider bw_slider {
	       parent => <-.control_frame;
	       title = "Max Bandwidth (kb/s)";
	       mode = "integer";
	       min = 128.0;
	       max = 2048.0;
	       width = 245;
	       value => <-.<-.<-.AccessGridParams.maxbandwidth;
	    };
	    */
	    
	    UIslider quality_slider {
	       parent => <-.control_frame;
	       title = "Stream Quality";
	       mode = "integer";
	       active => <-.<-.<-.AccessGridParams.encoder;
	       min = 2.0;
	       max = 100.0;
	       width = 245;
	       value => <-.<-.<-.AccessGridParams.quality;
	    };
	    
	    UIslider colour_slider {
	       parent => <-.control_frame;
	       title = "Border Colour";
	       mode = "integer";
	       min = 0.0;
	       max = 255.0;
	       width = 245;
	       value => <-.<-.<-.AccessGridParams.border;
	    };
	    
	    UIoptionMenu format_menu {
	       parent => <-.control_frame;
	       cmdList => {
		  <-.form0, <-.form1
	       };
	       selectedItem => <-.<-.<-.AccessGridParams.format;
	       label => "Output Format";
	    };
	    UIoption form0 {
	       label => "ARGB";
	    };
	    UIoption form1 {
	       label => "RGBA";
	    };

	    UItoggle flip_h_toggle {
	       parent => <-.control_frame;
	       label = "Flip horizontally";
	       width = 150;
	       set => <-.<-.<-.AccessGridBroadcast.fliph;
	    };
	 
	    UItoggle flip_v_toggle {
	       parent => <-.control_frame;
	       label = "Flip vertically";
	       width = 150;
	       set => <-.<-.<-.AccessGridBroadcast.flipv;
	    };
	 
	    UIbutton refresh_button {
	       parent => <-.control_frame;
	       label = "Refresh";
	       do => <-.<-.<-.AccessGridBroadcast.refresh;
	    };
	 }; // ControlUI
      }; // UI   
   }; // AccessGridEmitter

   GDM.Uviewer3D AccessGridViewer3D {
      Scene {
	 View {
	    View {
	       output_enabled = 1;
	    };
	    FieldOutput {
	       output<NEportLevels={0,4}>;
	    };
	    PickCtrl;
	    ViewUI {
	       ViewPanel {
		  UI {
		     panel {
			defaultWidth = 358;
			defaultHeight = 294;
		     };
		  };
	       };
	    };
	    VirtPal;
	 };
      };
      AccessGridEmitter AccessGridEmitter {
	 AccessGridBroadcast {
	    framebuffer => <-.<-.Scene.View.FieldOutput.output;
	 };
      };
   }; // AccessGridViewer3D

   GDM.Uviewer2D AccessGridViewer2D {
      Scene {
	 View {
	    View {
	       output_enabled = 1;
	    };
	    FieldOutput {
	       output<NEportLevels={0,4}>;
	    };
	    PickCtrl;
	    ViewUI {
	       ViewPanel {
		  UI {
		     panel {
			defaultWidth = 358;
			defaultHeight = 294;
		     };
		  };
	       };
	    };
	    VirtPal;
	 };
      };
      AccessGridEmitter AccessGridEmitter {
	 AccessGridBroadcast {
	    framebuffer => <-.<-.Scene.View.FieldOutput.output;
	 };
      };
   }; // AccessGridViewer2D
   
}; // flibrary
