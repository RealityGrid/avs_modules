/*-----------------------------------------------------------------------

  This file is part of the RealityGrid Access Grid Broadcast Module.

  (C) Copyright 2004, 2005, University of Manchester, United Kingdom,
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

flibrary AccessGridApps {
   APPS.MultiWindowApp AccessGridEmitterExample3D<NEdisplayMode="maximized"> {
      UI {
	 Modules {
	    IUI {
	       optionList {
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
		  <-.<-.<-.Read_Geom.geom
	       };
	       Xform {
		  ocenter = {0.,-0.231161,-0.0594285};
		  dcenter = {0.,-0.924644,-0.237714};
		  mat = {
		     3.56568,-1.3214,-1.24089,0.,1.49547,0.596911,3.66159,0.,
		     -1.02443,-3.72795,1.02613,0.,0.,0.,0.,1.
		  };
		  xlate = {
		     0.,0.924644,0.237714
		  };
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
      
      IAC_PROJ.AccessGrid.AccessGridMacs.AccessGridEmitter AccessGridEmitter {
	 view_in => <-.Uviewer3D.Scene_Selector.curr_view;
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
   }; // AccessGridEmitter3DExample

   APPS.SingleWindowApp AccessGridEmitterExample2D<NEdisplayMode="maximized"> {
      UI {
	 Modules {
	    IUI {
	       optionList {
		  selectedItem = 1;
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
	 view_in => <-.Uviewer2D.Scene_Selector.curr_view; 
      };
   }; // AccessGridEmitterExample
}; // AccessGridApps
