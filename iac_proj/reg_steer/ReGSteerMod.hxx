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

#ifndef __REGSTEERMOD_HXX__

#include "ReG_Steer_Appside.h"
#include <cstring>

class RealityGrid_RealityGridSteeringMod;

class ReGSteerMod {
private:

  // Internal stuff
  bool initialized;
  char* error;
  int pollCount;
  RealityGrid_RealityGridSteeringMod *parent;

  // For registering IOType
  int num_iotypes;
  int* iotype_handle;
  char** iotype_labels;
  int* iotype_dir;
  int* iotype_frequency;

  // For receiving data
  char* charData;
  int* intData;
  float* floatData;
  double* doubleData;

  // For calling Steering_control
  int num_recvd_cmds;
  int* recvd_cmds;
  char** recvd_cmd_params;
  int num_params_changed;
  char** changed_param_labels;

public:
  ReGSteerMod();
  ~ReGSteerMod();

  // get and set the parent of this instance
  RealityGrid_RealityGridSteeringMod* getParent();
  void setParent(RealityGrid_RealityGridSteeringMod* p);

  // accessors
  bool isRunning();
  char* getError();

  // set up the steering mod
  bool init(char* name, char* sgs_address);

  // interface methods to the steering library
  bool poll(int* numCommands);
  bool getData();
};

#define __REGSTEERMOD_HXX__
#endif // __REGSTEERMOD_HXX__
