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

flibrary RealityGridLB3DApps {
   APPS.MultiWindowApp RealityGridLB3DVolumeViewerExample<NEdisplayMode="maximized"> {
      
      UI {
	 shell {
	    x = 402;
	    y = 50;
	 };
	 Modules {
	    IUI {
	       optionList {
		  selectedItem = 0;
	       };
	    };
	 };
      };
      
      GDM.Uviewer3D Uviewer3D {
	 Scene {
	    Top {
	       child_objs => {
		  <-.<-.<-.DataObject.obj
	       };
	    };
	    View {
	       View {
		  trigger = 1;
		  renderer => "Software";
		  output_enabled = 1;
	       };
	    };
	    Camera {
	       Camera {
		  perspec = 1;
		  front = 1.;
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
      
      IAC_PROJ.RealityGridLB3D.RealityGridLB3DMacs.RealityGridLB3DReader RealityGridLB3DReader {
	 inField => <-.Read_Field.field;

	 RealityGridSteerer {
	    RealityGridSteererUI {
	       UImod_panel {
		  option {
		     set = 1;
		  };
	       };

	       UIlabel vol_title {
		  parent => <-.UImod_panel;
		  label = "Configuration";
		  width => parent.clientWidth;
		  color {
		     foregroundColor = "white";
		     backgroundColor = "blue";
		  };
	       };	 
	       
	       UItoggle fatray_toggle {
		  parent => <-.UImod_panel;
		  label = "Use fat rays";
		  set => <-.<-.<-.<-.DataObject.Props.fat_ray;
	       };
	       
	       UIlabel manip_label {
		  parent => <-.UImod_panel;
		  label = "Volume manipulation:";
		  width = 128;
		  alignment = 2;
	       };
	       UItoggle manip_toggle {
		  parent => <-.UImod_panel;
		  label = "fast...";
		  set => <-.<-.<-.<-.DataObject.Obj.use_altobj;
		  x => <-.manip_label.x + <-.manip_label.width;
		  y => <-.manip_label.y;
	       };
	       UIoptionMenu manip_menu {
		  parent => <-.UImod_panel;
		  cmdList => {
		     <-.opt0, <-.opt1
		  };
		  selectedItem = 0;
		  active => <-.manip_toggle.set;
		  label = "";
		  x => <-.manip_label.x + <-.manip_label.width;
	       };
	       UIoption opt0 {
		  label = "bounds";
	       };
	       UIoption opt1 {
		  label = "fat rays";
	       };
	       
	       int manip_mode[5] => {1,1,1,(1 + (manip_menu.selectedItem * 2)),(2 + manip_menu.selectedItem)};
	    };
	 };
      };
      
      MODS.Read_Field Read_Field {
	 read_field_ui {
	    file_browser {
	       searchPattern = "";
	    };
	 };
      };
      
      DataObject DataObject {
	 in => <-.RealityGridLB3DReader.outShortData;
	 Props {
	    fat_ray = 0;
	    inherit = 0;
	 };
	 Modes {
	    mode = {0,0,0,3,0};
	 };
	 Obj {
	    use_altobj = 1;
	 };
	 AltObject {
	    Props {
	       fat_ray = 1;
	       inherit = 0;
	    };
	    AltModes {
	       mode => <-.<-.<-.RealityGridLB3DReader.RealityGridSteerer.RealityGridSteererUI.manip_mode;
	    };
	 };
      };
      
      CMAP_EDTR.ColorMapEditor ColormapEditor {
	 InObj => <-.DataObject.obj;
	 in_field => <-.RealityGridLB3DReader.outShortData;
	 ColorMapEditorParams {
	    checkerboard = 1;
	 };
	 UIshell {
	    x = 14;
	    y = 141;
	 };
	 TransferFunction {
	    localUI {
	       xMin {
		  label => str_format("%.4g", <-.<-.<-.<-.RealityGridLB3DReader.RealityGridLB3DReaderMod.minLabel);
	       };
	       xMax {
		  label => str_format("%.4g", <-.<-.<-.<-.RealityGridLB3DReader.RealityGridLB3DReaderMod.maxLabel);
	       };
	    };
	 };
	 MenuBar {
	    OpenDialog {
	       dirMaskCache = "iac_proj/reg_lb3d/colourmaps/*.cmp";
	    };
	 };
      };

      HDF5.Wr_HDF5_Field Wr_HDF5_Field {
	 in_field => <-.RealityGridLB3DReader.outData;
	 panel {
	    title = "Save Raw Data";
	 };
	 Wr_HDF5_UI {
	    file_browser {
	       searchPattern = "*.h5";
	    };
	 };
      };

      HDF5.Wr_HDF5_Field Wr_HDF5_Field_Short {
	 in_field => <-.RealityGridLB3DReader.outShortData;
	 panel {
	    title = "Save Short (volume) Data";
	 };
	 Wr_HDF5_UI {
	    file_browser {
	       searchPattern = "*.h5";
	    };
	 };
      };
      
      HDF5.Wr_HDF5_Field Wr_HDF5_Field_Byte {
	 in_field => <-.RealityGridLB3DReader.outByteData;
	 panel {
	    title = "Save Byte (volume) Data";
	 };
	 Wr_HDF5_UI {
	    file_browser {
	       searchPattern = "*.h5";
	    };
	 };
      };

   }; // RealityGridLB3DVolumeViewerExample
}; // RealityGridLB3DApps
