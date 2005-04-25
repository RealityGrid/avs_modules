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

#include "AGBroadcastMod.hxx"
#include "ag_gen.hxx"

AGBroadcastMod::AGBroadcastMod() {
  cerr << "*** In AGBroadcastMod constructor." << endl;
  initialized = false;
  running = false;
  flixError = false;

  frameSize[0] = 352;
  frameSize[1] = 288;
  format = 0;           // ARGB is default
  border = 150;

  flipH = false;
  flipV = false;

  flix = 0;
  outputBuffer = new byte_t[frameSize[0] * frameSize[1] * 3];
}

AGBroadcastMod::~AGBroadcastMod() {
  cerr << "*** In ~AGBroadcastMod destructor." << endl;
  stopTransmitter();
  if(flix) {
    delete flix;
  }
  if(outputBuffer) {
    delete[] outputBuffer;
  }
}

AccessGrid_AccessGridBroadcast* AGBroadcastMod::getParent() {
  return parent;
}

void AGBroadcastMod::setParent(AccessGrid_AccessGridBroadcast* p) {
  parent = p;
}

void AGBroadcastMod::initNetwork(char* dest, char* name, int enc) {
  initNetwork(dest, name, enc, 24, 512, 50);
}

void AGBroadcastMod::initNetwork(char* dest, char* name, int enc, int fps, int bw, int quality) {

  encoder = enc;

  char* encoderstr = new char[5];
  switch(enc) {
  case 0:
    // h261
    encoderstr = "h261";
    break;
  case 1:
    // jpeg
    encoderstr = "jpeg";
    break;
  default:
    cerr << "Invalid encoder specified - defaulting to h261." << endl;
    encoderstr = "h261";
    encoder = 0;
  }
  char fpsstr[10];
  sprintf(fpsstr, "%d", fps);
  char maxbwstr[10];
  sprintf(maxbwstr, "d%", bw);
  char qualitystr[10];
  sprintf(qualitystr, "d%", quality);

  // create and initialise flxmitter instance
  flix = new flxmitter();
  flix->resize_pool(frameSize[0], frameSize[1], 24);
  flix->start();
  flix->set_option("destination", dest);
  flix->set_option("encoder", encoderstr);
  flix->set_option("sdes_name", name);
  flix->set_option("fps", fpsstr);
  //flix->set_option("maxbw", maxbwstr);
  flix->set_option("quality", qualitystr);

  running = true;
  flixError = false;

  initialized = true;
  parent->connected = 1;

  delete[] encoderstr;
}

int AGBroadcastMod::startTransmitter() {
  if(!running) {
    flix->start();
    running = true;
  }
  return 1;
}

int AGBroadcastMod::stopTransmitter() {
  if(running) {
    flix->stop();
    running = false;
  }
  return 1;
}

int AGBroadcastMod::commandValue(char* cmd, char* val) {
  if(initialized && !flixError) {
    flix->set_option(cmd, val);
    return 1;
  }
  return 0;
}

bool AGBroadcastMod::isRunning() {
  return running;
}

int AGBroadcastMod::getFormat() {
  return format;
}

void AGBroadcastMod::setFormat(int f) {
  if((f == 0) || (f == 1)) {
    format = f;
  }
}

void AGBroadcastMod::setFlipH(int h) {
  if(h == 0) flipH = false;
  else flipH = true;
}

void AGBroadcastMod::setFlipV(int v) {
  if(v == 0) flipV = false;
  else flipV = true;
}

void AGBroadcastMod::setBorder(int b) {
  if(border >= 0 && border <= 255) {
    border = b;
  }
}

int AGBroadcastMod::getEncoder() {
  return encoder;
}

void AGBroadcastMod::setEncoder(int e) {
  switch(e) {
  case 0:
    // h261
    commandValue("encoder", "h262");
    encoder = e;
    break;
  case 1:
    //jpeg
    commandValue("encoder", "jpeg");
    encoder = e;
    break;
  default:
    cerr << "Unknown encoder - ignoring." << endl;
    break;
  }
}

int AGBroadcastMod::getQuality() {
  return quality;
}

void AGBroadcastMod::setQuality(int q) {
  if(q < 1 || q > 100) {
    cerr << "Bad value for quality - ignoring." << endl;
    return;
  }

  char qualitystr[10];

  switch(encoder) {
  case 0:
    // h261
    q = 101 - q;
  }

  sprintf(qualitystr, "%d", q);
  commandValue("quality", qualitystr);
}

void AGBroadcastMod::emit() {
  // do nothing if not set up or if we've had an error
  if(!initialized || !running || flixError) return;

  int stride;
  int depth = 3;

  // get the size of the framebuffer...
  int *framebufferSize = (int *) parent->framebuffer.dims.ret_array_ptr(OM_GET_ARRAY_RD);

  // need to check that the number of nodes and the dimensions of the framebuffer
  // are consistent. AVS really buggers this up, so bail if there's a discrepancy!
  if((int) parent->framebuffer.nnodes != (framebufferSize[0] * framebufferSize[1])) return;

  stride = depth;

  int  framebuffer_data_comp;
  int  framebuffer_data_size, framebuffer_data_type;
  for (framebuffer_data_comp = 0; framebuffer_data_comp < parent->framebuffer.nnode_data; framebuffer_data_comp++) { 
    unsigned char* dataFrom = (unsigned char*) parent->framebuffer.node_data[framebuffer_data_comp].values.ret_array_ptr(OM_GET_ARRAY_RD, &framebuffer_data_size, &framebuffer_data_type);

    int dataFromStride = parent->framebuffer.node_data[framebuffer_data_comp].veclen;

    // need to check that there is actually some data to be copied. For some reason,
    // between framebuffer size changes, there is no data at all!
    if(framebuffer_data_size == 0) return;

    int j = 0;                               // index into destination image
    int i = 0;                               // index into source image
    int rowSize = framebufferSize[0] * dataFromStride;
    int sx, sy;                              // x and y indicies into source image
    int w = 352;                             // width of scaled image
    int h = 288;                             // height of scaled image
    int flipx, flipy;                        // flipped indices into the dest image
    int offx = 0;                            // x offset of scaled image
    int offy = 0;                            // y offset of scaled image

    // Calculate the scaling factors if needs be while preserving
    // the aspect ratio of the image
    if(((framebufferSize[0] != 352) || (framebufferSize[1] != 288))) {
      // calculate aspect ratio of source image
      float r = (float) framebufferSize[0] / (float) framebufferSize[1];

      if((framebufferSize[0] - 352) > (framebufferSize[1] - 288)) {
	// scale to width
	w = 352;
	h = (int) (w / r);
	offy = (int) ((288 - h) / 2);
      }
      else {
	// scale to height
	h = 288;
	w = (int) (r * h);
	offx = (int) ((352 - w) / 2);
      }

      // blank out destinaton image
      memset((void*) outputBuffer, border, 304128);
    }

    // Copy and scale the framebuffer into the Access Grid stream
    // taking into account the required output format.
    for(int dy = 0; dy < h; dy++) {
      if(flipV) flipy = h - dy - 1;
      else flipy = dy;
      sy = ((flipy * framebufferSize[1]) / h);
      for(int dx = 0; dx < w; dx++) {
	if(flipH) flipx = w - dx - 1;
	else flipx = dx;
	sx = ((flipx * framebufferSize[0]) / w);
	i = (sy * rowSize) + (sx * dataFromStride) + (1 - format);
	j = ((dy + offy) * (352 * 3)) + ((dx + offx) * 3);
	memcpy((void*) &(outputBuffer[j]), (void*) &(dataFrom[i]), stride);
      }
    }
    
    if (dataFrom)
      ARRfree(dataFrom);
  }

  // give the buffer to the flxmitter
  flix->insert_data(outputBuffer);
}
