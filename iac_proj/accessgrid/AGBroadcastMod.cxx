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
  //cerr << "*** In AGBroadcastMod constructor." << endl;
  initialized = false;
  running = false;

  format = 0;           // ARGB is default
  border = 150;

  flipH = false;
  flipV = false;

  // initialise array pointers to zero...
  flix = 0;
  outputBuffers = 0;
  frameSize = 0;
  tileDims = 0;
}

AGBroadcastMod::~AGBroadcastMod() {
  //cerr << "*** In ~AGBroadcastMod destructor." << endl;
  stopTransmitter();

  if(flix) {
    for(int i = 0; i < numTiles; i++)
      delete flix[i];
    delete[] flix;
  }

  if(outputBuffers) {
    for(int x = 0; x < tileDims[0]; x++) {
      for(int y = 0; y < tileDims[1]; y++) 
	delete[] outputBuffers[x][y];
      delete[] outputBuffers[x];
    }
    delete[] outputBuffers;
  }

  if(frameSize)
    delete[] frameSize;

  if(tileDims)
    delete[] tileDims;
}

AccessGrid_AccessGridBroadcast* AGBroadcastMod::getParent() {
  return parent;
}

void AGBroadcastMod::setParent(AccessGrid_AccessGridBroadcast* p) {
  parent = p;
}

void AGBroadcastMod::initStreams(int sw, int sh, int tw, int th) {
  //cerr << "*** In AGBroadcastMod initStreams." << endl;
  frameSize = new int[2];
  frameSize[0] = sw;
  frameSize[1] = sh;

  tileDims = new int[2];
  tileDims[0] = tw;
  tileDims[1] = th;
  numTiles = tw * th;

  // create flxmitter instances and output buffers
  flix = new flxmitter*[numTiles];
  for(int i = 0; i < numTiles; i++) {
    flix[i] = new flxmitter();
  }

  outputBuffers = new byte_t**[tileDims[0]];
  for(int x = 0; x < tileDims[0]; x++) {
    outputBuffers[x] = new byte_t*[tileDims[1]];
    for(int y = 0; y < tileDims[1]; y++)
      outputBuffers[x][y] = new byte_t[frameSize[0] * frameSize[1] * 3];
  } 
}

void AGBroadcastMod::initNetwork(char* dest, char* name, int enc) {
  initNetwork(dest, name, enc, 24, 80);
}

void AGBroadcastMod::initNetwork(char* dest, char* name, int enc, int fps, int quality) {

  // initialise flxmitter instances
  for(int i = 0; i < numTiles; i++) {
    flix[i]->resize_pool(frameSize[0], frameSize[1], 24);
    flix[i]->start();
    flix[i]->set_option("destination", dest);
    flix[i]->set_option("sdes_name", name);
    setEncoder(enc);
    setFramerate(fps);
    setQuality(quality);
  }

  running = true;
  initialized = true;
  parent->connected = 1;
}

int AGBroadcastMod::startTransmitter() {
  if(!running) {
    for(int i = 0; i < numTiles; i++)
      flix[i]->start();
    running = true;
  }
  return 1;
}

int AGBroadcastMod::stopTransmitter() {
  if(running) {
    for(int i = 0; i < numTiles; i++)
      flix[i]->stop();
    running = false;
  }
  return 1;
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
    for(int i = 0; i < numTiles; i++)
      flix[i]->set_option("encoder", "h261");
    encoder = e;
    break;
  case 1:
    //jpeg
    for(int i = 0; i < numTiles; i++)
      flix[i]->set_option("encoder", "jpeg");
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
    cerr << "Bad value for quality (1 <= q <= 100) - ignoring." << endl;
    return;
  }

  char qualitystr[10];

  switch(encoder) {
  case 0:
    // h261
    q = 101 - q;
  }

  sprintf(qualitystr, "%d", q);
  for(int i = 0; i < numTiles; i++)
    flix[i]->set_option("quality", qualitystr);
}

int AGBroadcastMod::getFramerate() {
  return framerate;
}

void AGBroadcastMod::setFramerate(int fps) {
  if(fps < 1 || fps > 30) {
    cerr << "Bad value for framerate (1 <= fps <= 30) - ignoring." << endl;
    return;
  }

  char fpsstr[10];
  sprintf(fpsstr, "%d", fps);
  for(int i = 0; i < numTiles; i++)
    flix[i]->set_option("fps", fpsstr);

  framerate = fps;
}

int AGBroadcastMod::getBandwidth() {
  return bandwidth;
}

void AGBroadcastMod::setBandwidth(int bw) {
  char bwstr[10];
  sprintf(bwstr, "%d", bw);
  for(int i = 0; i < numTiles; i++)
    flix[i]->set_option("maxbw", bwstr);

  bandwidth = bw;
}

void AGBroadcastMod::emit() {
  // do nothing if not set up or if we've had an error
  if(!initialized || !running) return;

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

    int j = 0;                                    // index into destination image
    int i = 0;                                    // index into source image
    int tx = 0;
    int ty = 0;
    int rowSize = framebufferSize[0] * dataFromStride;
    int sx, sy;                                   // x and y indicies into source image
    int totalWidth = frameSize[0] * tileDims[0];  // total frame width
    int totalHeight = frameSize[1] * tileDims[1]; // total frame height
    int w = totalWidth;                           // width of scaled image
    int h = totalHeight;                          // height of scaled image
    int flipx, flipy;                             // flipped indices into the dest image
    int offx = 0;                                 // x offset of scaled image
    int offy = 0;                                 // y offset of scaled image


    // Calculate the scaling factors if needs be while preserving
    // the aspect ratio of the image
    if(((framebufferSize[0] != totalWidth) || (framebufferSize[1] != totalHeight))) {
      // calculate aspect ratio of source image
      float r = (float) framebufferSize[0] / (float) framebufferSize[1];

      if((framebufferSize[0] - totalWidth) > (framebufferSize[1] - totalHeight)) {
	// scale to width
	w = totalWidth;
	h = (int) (w / r);
	offy = (int) ((totalHeight - h) / 2);
      }
      else {
	// scale to height
	h = totalHeight;
	w = (int) (r * h);
	offx = (int) ((totalWidth - w) / 2);
      }

      // blank out destination images
      for(int x = 0; x < tileDims[0]; x++)
	for(int y = 0; y < tileDims[1]; y++)
	  memset((void*) outputBuffers[x][y], border, (frameSize[0] * frameSize[1] * stride));
    }

    // Copy and scale the framebuffer into the Access Grid streams
    // taking into account the required output format.
    for(int dy = offy; dy < (h + offy); dy++) {
      if(flipV) flipy = h - dy - offy - 1;
      else flipy = (dy - offy);
      sy = ((flipy * framebufferSize[1]) / h);
      ty = (int) floor((double) (dy / frameSize[1]));
      for(int dx = offx; dx < (w + offx); dx++) {
	if(flipH) flipx = w - dx - offx - 1;
	else flipx = (dx - offx);
	sx = ((flipx * framebufferSize[0]) / w);
	tx = (int) floor((double) (dx / frameSize[0]));
	i = (sy * rowSize) + (sx * dataFromStride) + (1 - format);
	j = ((dy - (frameSize[1] * ty)) * frameSize[0] * 3) + ((dx - (frameSize[0] * tx)) * 3);
	memcpy((void*) &(outputBuffers[tx][ty][j]), (void*) &(dataFrom[i]), stride);
      }
    }
    
    if (dataFrom)
      ARRfree(dataFrom);
  }

  int f = 0;
  // give the buffers to the flxmitters
  for(int x = 0; x < tileDims[0]; x++)
    for(int y = 0; y < tileDims[1]; y++)
      flix[f++]->insert_data(outputBuffers[x][y]);
      
}
