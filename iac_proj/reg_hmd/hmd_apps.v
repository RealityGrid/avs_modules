/* ----------------------------------------------------------------------------
  This file is part of the RealityGrid AVS/Express HMD Module.
 
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

flibrary RealityGridHMDApps {
   APPS.MultiWindowApp RealityGridHydroExample<NEdisplayMode="maximized"> {
      UI {
	 Modules {
	    IUI {
	       optionList {
		  cmdList => {
		     <-.<-.<-.<-.RealityGridSteerer.RealityGridSteererUI.UImod_panel.option,
		     <-.<-.<-.<-.isosurface.UIpanel.option,
		     <-.<-.<-.<-.Vector.panel.option,
		     <-.<-.<-.<-.bounds.UIpanel.option,
		     <-.<-.<-.<-.glyph.UIpanel.option,
		     <-.<-.<-.<-.Box.box_ui.panel.option
		  };
		  selectedItem = 0;
	       };
	       mod_panel {
		  x = 0;
		  y = 0;
	       };
	    };
	 };
      };
      GDM.Uviewer3D Uviewer3D {
	 Scene {
	    Top {
	       child_objs => {
		  <-.<-.<-.isosurface.out_obj,
		  <-.<-.<-.Vector.out_obj,
		  <-.<-.<-.bounds.out_obj,
		  <-.<-.<-.glyph.out_obj
	       };
	    };
	    Lights {
	       Lights = {
		  {
		     type="BiDirectional"
		  },,,
	       };
	    };
	    Camera {
	       Camera {
		  perspec = 1;
		  front = 1.;
	       };
	    };
	    View {
	       View {
		  trigger = 1;
	       };
	    };
	 };
	 Scene_Editor {
	    Camera_Editor {
	       GDcamera_edit {
		  front = 1.;
	       };
	    };
	 };
      };
      IAC_PROJ.RealityGrid.RealityGridMacs.RealityGridSteerer RealityGridSteerer {
	 RealityGridSteeringParams {
	    pollInterval = 4.;
	 };
      };
      
      FLD_MAP.uniform_scalar_field uniform_scalar_field {
	 mesh {
	    in_dims => <-.<-.RealityGridSteerer.outData[0].data;
	 };
	 data {
	    in_data => <-.<-.RealityGridSteerer.outData[2].data;
	    out {
	       node_data = {
		  {
		     labels="density",,
		  }
	       };
	    };
	 };
      };
      MODS.isosurface isosurface {
	 in_field => <-.uniform_scalar_field.out;
	 
	 DVcell_data_labels {
	    labels[];
	 };
	 DVnode_data_labels {
	    labels[];
	 };
	 IsoUI {
	    UIradioBoxLabel {
	       label_cmd {
		  cmd[];
	       };
	    };
	    UIoptionBoxLabel {
	       label_cmd {
		  cmd[];
	       };
	    };
	    UIoptionBoxLabel_cell {
	       label_cmd {
		  cmd[];
		  outItem = ;
	       };
	    };
	 };
      };
      FLD_MAP.uniform_vector_field uniform_vector_field {
	 mesh {
	    in_dims => <-.<-.RealityGridSteerer.outData[0].data;
	 };
	 data {
	    in_data[(<-.<-.RealityGridSteerer.outData[1].size/3)][3] => <-.<-.RealityGridSteerer.outData[1].data;
	    out {
	       node_data = {
		  {
		     labels="momentum",,
		  }
	       };
	    };
	 };
      };
      HLM.Vector Vector {
	 glyph {
	    GlyphParam {
	       scale = 1.;
	       normalize = 1;
	    };
	    GlyphUI {
	       UIradioBoxLabel_type {
		  selectedItem = 3;
	       };
	       UIradioBoxLabel_glyph {
		  label_cmd {
		     cmd[];
		  };
	       };
	       DVnode_data_labels {
		  labels[];
	       };
	       UIradioBoxLabel_map {
		  label_cmd {
		     cmd[];
		  };
	       };
	       UIradioBoxLabel_scale {
		  label_cmd {
		     cmd[];
		  };
	       };
	    };
	 };
	 in_field => <-.uniform_vector_field.out;
      };

      MODS.bounds bounds {
	 in_field => <-.uniform_vector_field.out;
	 BoundsUI {
	    DVnode_data_labels {
	       labels[];
	    };
	    UIradioBoxLabel {
	       label_cmd {
		  cmd[];
	       };
	    };
	 };
      };
      
      MODS.glyph glyph {
	 in_field => <-.uniform_vector_field.out;
	 in_glyph => <-.Box.out_fld;
	 GlyphParam {
	    vector = 0;
	    scale = 2.0;
	    scale_x = 1;
	    scale_y = 1;
	    scale_z = 0;
	    normalize = 1;
	 };
	 obj {
	    Modes {
	       mode = {0,2,1,0,0};
	    };
	 };
      };

      GEOMS.Box Box {
	 box {
	    xform {
	       xlate = {-0.5,-0.5,-0.5};
	    };
	 };
	 box_ui {
	    probe_edit {
	       GDxform_editor {
		  x_trans = -0.5;
		  y_trans = -0.5;
		  z_trans = -0.5;
		  x_cent = 0.;
		  y_cent = 0.;
		  z_cent = 0.;
		  abs_x_cent = 0.;
		  abs_y_cent = 0.;
		  abs_z_cent = 0.;
		  abs_x_trans = -0.5;
		  abs_y_trans = -0.5;
		  abs_scale = 1.;
		  abs_z_trans = -0.5;
	       };
	    };
	 };
	 dim1 = 2;
	 dim2 = 2;
	 dim3 = 2;
      };
      
   };  // RealityGridHydroExample
};  // flibrary
