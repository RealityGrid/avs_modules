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

flibrary AccessGridApps {
   APPS.MultiWindowApp AccessGridViewerExample<NEdisplayMode="maximized"> {
      UI {
	 shell {
	    x = 10;
	    y = 27;
	 };
	 Modules {
	    IUI {
	       optionList {
		  selectedItem = 0;
		  cmdList => {
		     <-.<-.<-.<-.AccessGridViewer3D.AccessGridEmitter.AccessGridEmitterUI.UImod_panel.option,
		  <-.<-.<-.<-.Read_Geom.read_geom_ui.panel.option};
	       };
	       mod_panel {
		  x = 0;
		  y = 0;
	       };
	    };
	 };
      };
      GDM.Uviewer3D AccessGridViewer3D {
	 Scene<NEx=350.,NEy=66.> {
	    View {
	       FieldOutput {
		  output<NEportLevels={0,4}>;
	       };
	       View {
		  trigger = 2;
		  output_enabled = 1;
	       };
	       ViewUI {
		  ViewPanel {
		     UI {
			panel {
			   defaultX = 390;
			   defaultY = 556;
			   defaultWidth = 358;
			   defaultHeight = 294;
			};
		     };
		  };
	       };
	    };
	    Top {
	       child_objs => {
	       <-.<-.<-.Read_Geom.geom};
	       Xform {
		  ocenter = {0.,-0.231161,-0.0594285};
		  dcenter = {0.,-0.924644,-0.237714};
		  mat = {
		     2.86405,1.70183,-3.14844,0.,-1.56859,4.22141,0.854912,0.,
		     3.2169,0.543227,3.21996,0.,0.,0.,0.,1.
		  };
		  xlate = {0.,0.924644,0.237714};
	       };
	    };
	    Camera {
	       Camera {
		  perspec = 1;
		  front = 1.;
	       };
	    };
	 };
	 Scene_Selector<NEx=140.,NEy=228.>;
	 Scene_Editor<NEx=350.,NEy=390.> {
	    Camera_Editor {
	       GDcamera_edit {
		  front = 1.;
	       };
	    };
	 };
	 IAC_PROJ.AccessGrid.AccessGridMacs.AccessGridEmitter AccessGridEmitter {
	    AccessGridBroadcast {
	       framebuffer => <-.<-.Scene.View.FieldOutput.output;
	    };
	    AccessGridEmitterUI {
	       ConfigUI {
		  config_frame {
		     y = 0;
		  };
		  config_label {
		     y = 0;
		  };
		  name_label {
		     y = 24;
		  };
		  address_label {
		     y = 54;
		  };
		  port_label {
		     y = 84;
		  };
		  ttl_label {
		     y = 114;
		  };
		  encoder_menu {
		     x = 0;
		     y = 144;
		  };
		  src0 {
		     set = 1;
		  };
	       };
	       ControlUI {
		  control_frame {
		     y = 190;
		  };
		  control_label {
		     y = 0;
		  };
		  start_toggle {
		     y = 24;
		  };
		  update_slider {
		     y = 48;
		  };
		  quality_slider {
		     y = 108;
		  };
		  format_menu {
		     x = 0;
		     y = 168;
		  };
		  form0 {
		     set = 1;
		  };
		  flip_h_toggle {
		     y = 205;
		  };
		  flip_v_toggle {
		     y = 229;
		  };
		  refresh_button {
		     y = 253;
		  };
		  colour_slider {
		     y = 277;
		  };
	       };
	    };
	 };
      };
      MODS.Read_Geom Read_Geom {
	 read_geom_ui {
	    panel {
	       option {
		  set = 1;
	       };
	    };
	    file_browser {
	       x = 495;
	       y = 259;
	       width = 300;
	       height = 386;
	       ok = 1;
	       dirMaskCache = "$XP_PATH<0>/data/geom/*.geo";
	    };
	    filename = "$XP_PATH<0>/data/geom/crambin.geo";
	 };
      };
   }; // AccessGridViewerExample

   APPS.SingleWindowApp AccessGridEmitterExample<NEdisplayMode="maximized"> {
      UI {
	 Modules {
	    IUI {
	       optionList {
		  selectedItem = 0;
	       };
	    };
	 };
      };
      GDM.Uviewer2D Uviewer2D {
	 Scene {
	    Top {
	       child_objs => {
	       <-.<-.<-.Read_Image.image};
	       Xform {
		  ocenter = {249.5,239.5,0.};
		  dcenter = {4.,3.83968,0.};
	       };
	    };
	    View {
	       View {
		  trigger = 2;
	       };
	    };
	 };
      };
      MODS.Read_Image Read_Image {
	 read_image_ui {
	    panel {
	       option {
		  set = 1;
	       };
	    };
	    file_browser {
	       filename = "$XP_PATH<0>/data/image/mandrill.x";
	       x = 495;
	       y = 259;
	       width = 300;
	       height = 386;
	       ok = 1;
	       dirMaskCache = "$XP_PATH<0>/data/image/*";
	    };
	 };
      };
      IAC_PROJ.AccessGrid.AccessGridMacs.AccessGridEmitter AccessGridEmitter {
	 AccessGridBroadcast {
	    framebuffer => <-.<-.Read_Image.field;
	 };
	 AccessGridEmitterUI {
	    ConfigUI {
	       config_frame {
		  y = 0;
	       };
	       config_label {
		  y = 0;
	       };
	       name_label {
		  y = 24;
	       };
	       address_label {
		  y = 54;
	       };
	       port_label {
		  y = 84;
	       };
	       ttl_label {
		  y = 114;
	       };
	       encoder_menu {
		  x = 0;
		  y = 144;
	       };
	       src0 {
		  set = 1;
	       };
	    };
	    ControlUI {
	       control_frame {
		  y = 190;
	       };
	       control_label {
		  y = 0;
	       };
	       start_toggle {
		  y = 24;
	       };
	       update_slider {
		  y = 48;
	       };
	       quality_slider {
		  y = 108;
	       };
	       colour_slider {
		  y = 168;
	       };
	       format_menu {
		  x = 0;
		  y = 228;
	       };
	       form0 {
		  set = 1;
	       };
	       flip_h_toggle {
		  y = 265;
	       };
	       flip_v_toggle {
		  y = 289;
	       };
	       refresh_button {
		  y = 313;
	       };
	    };
	 };
      };
   }; // AccessGridEmitterExample
}; // AccessGridApps
