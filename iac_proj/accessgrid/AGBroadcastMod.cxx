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
  flixError = false;

  frameSize[0] = 352;
  frameSize[1] = 288;
  format = 0;           // ARGB is default
  border = 150;

  flipH = false;
  flipV = false;

  flix = 0;
  imagePool = 0;
}

AGBroadcastMod::~AGBroadcastMod() {
  //cerr << "*** In ~AGBroadcastMod destructor." << endl;
  stopTransmitter();
  if(flix) {
    delete flix;
  }
  if(imagePool) {
    delete imagePool;
  }
}

AccessGrid_AccessGridBroadcast* AGBroadcastMod::getParent() {
  return parent;
}

void AGBroadcastMod::setParent(AccessGrid_AccessGridBroadcast* p) {
  parent = p;
}

void AGBroadcastMod::initNetwork(char* dest, char* enc, char* name) {
  initNetwork(dest, enc, name, 24, 512, 75);
}

void AGBroadcastMod::initNetwork(char* dest, char* enc, char* name, int fps, int bw, int quality) {
  int argc = 14;
  char** argv = new char*[argc];

  argv[0] = "source";
  argv[1] = "flip";
  argv[2]  = "destination";
  argv[3]  = dest;
  argv[4]  = "encoder";
  argv[5]  = enc;
  argv[6]  = "name";
  argv[7]  = name;
  argv[8]  = "maxfps";
  argv[9]  = new char[10];
  sprintf(argv[9], "%d", fps);
  argv[10] = "maxbw";
  argv[11] = new char[10];
  sprintf(argv[11], "%d", bw);
  argv[12] = "quality";
  argv[13] = new char[10];
  sprintf(argv[13], "%d", quality);

  // create the image pool which is going to hold our frames
  imagePool = new FLImagePool;
  imagePool->_nImages = 10;
  imagePool->_totalPoolSize = sizeof(FLImagePool);
  imagePool->_nextImage = imagePool->_currentSerial = -1;
  imagePool->Resize(frameSize[0], frameSize[1], 3);

  // create FLXmitter
  flix = FLXmitter::New(argc, argv);
  flix->SetSource(this->imagePool);
  running = false;
  flixError = false;

  initialized = true;
  parent->connected = 1;

  delete argv[9];
  delete argv[11];
  delete argv[13];
  delete argv;
}

int AGBroadcastMod::startTransmitter() {
  if(!running) {
    if(!flix->Start()) {
      cerr << "Error starting the FLXmitter." << endl;
      flixError = true;
      return 0;
    }
    else running = true;
  }
  return 1;
}

int AGBroadcastMod::stopTransmitter() {
  if(running) {
    if(!flix->Stop()) {
      cerr << "Error stopping FLXmitter." << endl;
      flixError = true;
      return 0;
    }
    else running = false;
  }
  return 1;
}

int AGBroadcastMod::commandValue(char* cmd, char* val) {
  if(initialized && !flixError) {

    // not allowed to change source!
    if(!strcmp(cmd, "source")) return 1;

    flix->CommandValue(cmd, val);
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
  border = b;
}

void AGBroadcastMod::emit() {
  // do nothing if not set up or if we've had an error
  if(!initialized || !running || flixError) return;

  int stride, nextImage;
  int depth = 3;

  volatile unsigned char* dataTo;

  // get the size of the framebuffer...
  int *framebufferSize = (int *) parent->framebuffer.dims.ret_array_ptr(OM_GET_ARRAY_RD);

  // need to check that the number of nodes and the dimensions of the framebuffer
  // are consistent. AVS really buggers this up, so bail if there's a discrepancy!
  if((int) parent->framebuffer.nnodes != (framebufferSize[0] * framebufferSize[1])) return;

  stride = depth;
  nextImage = (imagePool->_nextImage + 1) % imagePool->_nImages;
  dataTo = imagePool->_images[nextImage].GetData();

  int  framebuffer_data_comp;
  int  framebuffer_data_size, framebuffer_data_type;
  for (framebuffer_data_comp = 0; framebuffer_data_comp < parent->framebuffer.nnode_data; framebuffer_data_comp++) { 
    // framebuffer.node_data[framebuffer_data_comp].veclen (int) 
    // framebuffer.node_data[framebuffer_data_comp].values (char [])
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
      memset((void*) &(dataTo[0]), border, 304128);
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
	memcpy((void*) &(dataTo[j]), (void*) &(dataFrom[i]), stride);
      }
    }
    
    if (dataFrom)
      ARRfree(dataFrom);
  }

  // update the next image index and serial number.
  imagePool->_nextImage = nextImage;
  imagePool->_currentSerial++;
}
