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

flibrary RealityGridFEAMacs {
   macro RealityGridFEAReader {
      
      IAC_PROJ.RealityGrid.RealityGridMacs.RealityGridSteerer RealityGridSteerer {
	 RealityGridSteeringParams {
	    reg_sgs_name = "AVS/Express FEA Reader";
	    connected = 0;
	    pollInterval = 1.0;
	    numSlices = 0;
	 };

	 RealityGridSteeringMod {
	    initialized = 0;
	    connected => configuration.connected;
	    slices => configuration.numSlices;
	    outData.size = 0;
	 };

	 RealityGridSteererUI {
	    UImod_panel {
	       title = "RealityGrid FEA Reader";
	    };
	 };
	 
      };

      IAC_PROJ.RealityGridFEA.RealityGridFEAMods.RealityGridFEAReaderMod RealityGridFEAReaderMod {
	 inData => <-.RealityGridSteerer.outData;
	 elementConnectivity[8] = {4, 0, 1, 5, 7, 3, 2, 6};
	 gotElements = 0;
      };

      olink outData => RealityGridFEAReaderMod.outData;
      
   }; // RealityGridFEAReader
}; // RealityGridFEAMacs
