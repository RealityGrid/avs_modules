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

#ifndef __AGBROADCASTMOD_HXX__

#include <cstring>

#include "FLXmitter.h"
#include "FLImagePool.h"

class AccessGrid_AccessGridBroadcast;

class AGBroadcastMod {
private:
  bool initialized;
  AccessGrid_AccessGridBroadcast *parent;

  FLXmitter* flix;
  bool running;
  bool flixError;

  int format;   // 0 = ARGB, 1 = RGBA
  int border;
  bool flipH;
  bool flipV;

  FLImagePool* imagePool;
  int lastImage;
  int lastSerial;
  int frameSize[2];

public:

  AGBroadcastMod();
  ~AGBroadcastMod();

  // get and set the parent of this instance
  AccessGrid_AccessGridBroadcast* getParent();
  void setParent(AccessGrid_AccessGridBroadcast* p);

  // accessors
  bool isRunning();
  int getFormat();
  void setFormat(int f);
  void setFlipH(int h);
  void setFlipV(int v);
  void setBorder(int b);

  // set up the video transmitter
  void initNetwork(char* dest, char* enc, char* name, int fps, int bw, int quality);
  // wrap previous method for just the vital info
  void initNetwork(char* dest, char* enc, char* name);

  // interface methods to the FLXmitter object
  int startTransmitter();
  int stopTransmitter();
  int commandValue(char* cmd, char* val);

  // emit a new framebuffer
  void emit();

};

#define __AGBROADCASTMOD_HXX__
#endif // __AGBROADCASTMOD_HXX__
