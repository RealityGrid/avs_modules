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

flibrary RealityGridFEAApps {
   APPS.MultiWindowApp RealityGridFEAReaderExample<NEdisplayMode="maximized"> {
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
	       <-.<-.<-.external_faces.out_obj,<-.<-.<-.external_edges.out_obj};
	    };
	 };
      };
      IAC_PROJ.RealityGridFEA.RealityGridFEAMacs.RealityGridFEAReader RealityGridFEAReader {
	 RealityGridSteerer {
	    RealityGridSteererUI {
	       UImod_panel {
		  option {
		     set = 1;
		  };
	       };
	    };
	 };
      };
      MODS.external_edges external_edges {
	 in_field => <-.RealityGridFEAReader.outData;
      };
      MODS.external_faces external_faces {
	 in_field => <-.RealityGridFEAReader.outData;
      };
   }; // RealityGridFEAReaderExample
}; // RealityGridFEAApps
