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

#include "iac_proj/accessgrid/ag_gen.hxx"

int AccessGrid_AccessGridBroadcast::init(OMevent_mask event_mask, int seq_num) {

  // get the AGBroadcastMod instance...
  AGBroadcastMod* modInst = (AGBroadcastMod*) ret_class_ptr("AGBroadcastMod");

  if(!connected && start) {
    char dest[64];
    char* ip;
    char* name;
    int port;
    int ttl;
    int encoder;
    int fps;
    int quality;

    // defaults for the stream size and tiling layout
    int stream_w = 352;
    int stream_h = 288;
    int tile_x = 1;
    int tile_y = 1;

    modInst->setParent(this);

    // check ipaddress
    if(configuration.ipaddress.valid_obj())
      configuration.ipaddress.get_str_val(&ip);
    else {
      ERRverror("AccessGridBroadcast", ERR_WARNING, "Broadcast address not set!");
      start = 0;
      return 0;
    }

    // check port
    if(configuration.port.valid_obj()) {
      port = (int) configuration.port;
    }
    else {
      ERRverror("AccessGridBroadcast", ERR_WARNING, "Broadcast port not set!");
      start = 0;
      return 0;
    }

    // check ttl
    if(configuration.ttl.valid_obj()) {
      ttl = (int) configuration.ttl;
    }
    else {
      ttl = 127;
    }

    // check encoder
    if(configuration.encoder.valid_obj()) 
      encoder = (int) configuration.encoder;
    else {
      ERRverror("AccessGridBroadcast", ERR_WARNING, "Encoder type not set!");
      start = 0;
      return 0;
    }

    // check name
    if(configuration.name.valid_obj())
      configuration.name.get_str_val(&name);
    else {
      ERRverror("AccessGridBroadcast", ERR_WARNING, "Stream name not set!");
      start = 0;
      return 0;
    }

    // check fps
    if(configuration.maxfps.valid_obj())
      fps = (int) configuration.maxfps;
    else {
      fps = 24;
      configuration.maxfps = 24;
    }

    // check quality
    if(configuration.quality.valid_obj())
      quality = (int) configuration.quality;
    else {
      quality = 50;
      configuration.quality = 50;
    }

    // check stream_dims
    if(configuration.stream_dims.valid_obj()) {
      int* streamSize = 0;
      streamSize = (int*) configuration.stream_dims.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      if(streamSize) {
	stream_w = streamSize[0];
	stream_h = streamSize[1];
	ARRfree(streamSize);
      }
    }

    // check tile_dims
    if(configuration.tile_dims.valid_obj()) {
      int* tiles = 0;
      tiles = (int*) configuration.tile_dims.ret_array_ptr(OM_GET_ARRAY_RD, NULL, NULL);
      if(tiles) {
	tile_x = tiles[0];
	tile_y = tiles[1];
	ARRfree(tiles);
      }
    }

    // build full address: ip/port/ttl
    sprintf(dest, "%s/%d/%d", ip, port, ttl);

    // init streams memory
    modInst->initStreams(stream_w, stream_h, tile_x, tile_y);

    // start network
    modInst->initNetwork(dest, name, encoder, fps, quality);
  }
  else if(connected && !start) {
    modInst->stopTransmitter();
  }
  else if(connected && start) {
    modInst->startTransmitter();
  }

  // return 1 for success
  return 1;
}

int AccessGrid_AccessGridBroadcast::update(OMevent_mask event_mask, int seq_num) {

  AGBroadcastMod* modInst = (AGBroadcastMod*) ret_class_ptr("AGBroadcastMod");

  if(start.changed(seq_num)) {
    view_output = (int) start;
  }

  if(configuration.encoder.changed(seq_num)) {
    modInst->setEncoder((int) configuration.encoder);
    // emit to show change...
    modInst->emit();
  }

  if(configuration.format.changed(seq_num)) {
    modInst->setFormat((int) configuration.format);
    // emit to show change...
    modInst->emit();
  }

  if(configuration.quality.changed(seq_num)) {
    modInst->setQuality((int) configuration.quality);
    // emit to show change...
    modInst->emit();
  }

  if(configuration.border.changed(seq_num)) {
    modInst->setBorder((int) configuration.border);
    // emit to show change...
    modInst->emit();
  }

  // doesn't seem to do ought...
  if(configuration.maxbandwidth.changed(seq_num)) {
    modInst->setBandwidth((int) configuration.maxbandwidth);
  }

  if(configuration.maxfps.changed(seq_num)) {
    modInst->setFramerate((int) configuration.maxfps);
  }

  if(fliph.changed(seq_num)) {
    modInst->setFlipH((int) fliph);
    // emit to show change...
    modInst->emit();
  }

  if(flipv.changed(seq_num)) {
    modInst->setFlipV((int) flipv);
    // emit to show change...
    modInst->emit();
  }

  // return 1 for success
  return 1;
}

int AccessGrid_AccessGridBroadcast::broadcast(OMevent_mask event_mask, int seq_num) {
  // check we actually have some data and a connection!
  if(((int) framebuffer.nnodes == 0) || !connected || !start) return 0;

  // if we're here because of a user refresh request we'd better allow that...
  if(refresh.changed(seq_num)) frame = 1000;

  //if we do have data, do we really want to emit?
  frame = (int) frame + 1;
  if((int) frame >= (int) configuration.updateInterval) frame = 0;
  if((int) frame != 0) return 0;

  // get the AGBroadcastMod instance...
  AGBroadcastMod* modInst = (AGBroadcastMod*) ret_class_ptr("AGBroadcastMod");

  // better start transmitting if we haven't already...
  if(!modInst->isRunning()) modInst->startTransmitter();

  // emit framebuffer
  modInst->emit();

  // return 1 for success
  return 1;
}
