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

#include "iac_proj/reg_steer/reg_gen.hxx"

RealityGrid_RealityGridSteeringMod::~RealityGrid_RealityGridSteeringMod() {
  if((int) initialized) {
    // stop poller
    EVdel_select(EV_TIMEOUT, 0, (void (*)(char*)) poller, NULL, (char*) this, (int) (oldPollInterval * 1000));
    delete modInst;
  }
}

int RealityGrid_RealityGridSteeringMod::init(OMevent_mask event_mask, int seq_num) {
  if(!((int) initialized) && ((int) start)) {
    char* sgs_name;
    char* sgs_address;
    
    // get the ReGSteerMod instance...
    modInst = new ReGSteerMod();
    modInst->setParent(this);
    
    // check SGS name
    if(configuration.reg_sgs_name.valid_obj())
      configuration.reg_sgs_name.get_str_val(&sgs_name);
    else {
      sgs_name = "RealityGrid AVS/Express Application";
    }
    
    // check SGS address
    if(configuration.reg_sgs_address.valid_obj()) {
      configuration.reg_sgs_address.get_str_val(&sgs_address);

#ifdef __sgi
      char env[REG_MAX_STRING_LENGTH];
      sprintf(env, "REG_SGS_ADDRESS=%s", sgs_address);
      putenv(env);
#else
      setenv("REG_SGS_ADDRESS", sgs_address, 1);
#endif

    }
    else {
      sgs_address = NULL;
    }
    
    if(modInst->init(sgs_name, sgs_address)) {
      initialized = 1;
      oldPollInterval = 0.0f;

      // setup poller
      if(configuration.pollInterval.valid_obj()) {
	oldPollInterval = (float) configuration.pollInterval;
	if(oldPollInterval <= 0.0f)
	  oldPollInterval = 1.0f;
      }
      else {
	oldPollInterval = 1.0f;
	configuration.pollInterval = oldPollInterval;
      }
      EVadd_select(EV_TIMEOUT, 0, (void (*)(char*)) poller, NULL, (char*) this, (int) (oldPollInterval * 1000));
    }
    else {
      ERRverror("RealityGridSteerer", ERR_WARNING, modInst->getError());
      start = 0;
      return 0;
    }

    connected = 1;

  } // !initialised && start
  else if(((int) initialized) && !((int) start)) {
    // kill things!
    EVdel_select(EV_TIMEOUT, 0, (void (*)(char*)) poller, NULL, (char*) this, (int) (oldPollInterval * 1000));
    delete modInst;
    connected = 0;
    initialized = 0;
    nudge = 0;
  }
  
  // return 1 for success
  return 1;
}

void poller(RealityGrid_RealityGridSteeringMod* steerMod) {
  if(steerMod->nudge) {    
    int commands;

    if(!steerMod->modInst->poll(&commands)) {
      ERRverror("RealityGridSteerer", ERR_WARNING, steerMod->modInst->getError());
      steerMod->start = 0;
      return;
    }
    
    if(commands > 0) {
      if(steerMod->slices.valid_obj()) {
	steerMod->push_ctx();
	steerMod->modInst->getData();
	steerMod->pop_ctx();
      }
      else {
	ERRverror("RealityGridSteerer", ERR_WARNING, "You must define a valid number of data slices to receive.");
	return;
      }
    }
  } // nudge

  return;
}

int RealityGrid_RealityGridSteeringMod::update(OMevent_mask event_mask, int seq_num) {
  if((int) initialized) {
    if(configuration.pollInterval.changed(seq_num) && configuration.pollInterval.valid_obj()) {
      if((float) configuration.pollInterval > 0.0f) {
	EVdel_select(EV_TIMEOUT, 0, (void (*)(char*)) poller, NULL, (char*) this, (int) (oldPollInterval * 1000));
	oldPollInterval = (float) configuration.pollInterval;
	EVadd_select(EV_TIMEOUT, 0, (void (*)(char*)) poller, NULL, (char*) this, (int) (oldPollInterval * 1000));
      } // if > 0.0f
    } 
  } // initialized

  // return 1 for success
  return 1;
}
