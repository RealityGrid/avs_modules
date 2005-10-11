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
  if((int) initialized && (int) start) {
    // stop poller
    EVdel_select(EV_TIMEOUT, 0, (void (*)(char*)) poller, NULL, (char*) this, (int) (oldPollInterval * 1000));
    delete modInst;
  }
}

int RealityGrid_RealityGridSteeringMod::pre_init(OMevent_mask event_mask, int seq_num) {

    // get the ReGSteerMod instance...
    modInst = new ReGSteerMod();
    modInst->setParent(this);

    initialized = 1;

   // return 1 for success
   return 1;
}

int RealityGrid_RealityGridSteeringMod::init(OMevent_mask event_mask, int seq_num) {
  if(((int) initialized) && ((int) start)) {
    char* sgs_name;
    char* sgs_address;
    char* io_label;
    
    // check SGS name
    if(configuration.reg_sgs_name.valid_obj())
      configuration.reg_sgs_name.get_str_val(&sgs_name);
    else
      sgs_name = "AVS/Express Visualisation";
    
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
    
    // check IOType label
    if(configuration.iotype_label.valid_obj()) 
      configuration.iotype_label.get_str_val(&io_label);
    else
      io_label = "AVS/Express_Data_Consumer"; 

    if(modInst->init(sgs_name, sgs_address, io_label)) {
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

  } // initialised && start
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

int RealityGrid_RealityGridSteeringMod::read_registry(OMevent_mask event_mask, int seq_num) {

  // get registry info...
  if((int) initialized && (int) get_sgs) {
    if(configuration.registry_info.address.valid_obj()) {
      char* reg_address;

      configuration.registry_info.address.get_str_val(&reg_address);
      if(!modInst->getRegistryInfo(reg_address)) {
	ERRverror("RealityGridSteerer", ERR_WARNING, modInst->getError());
	return 0;
      }
    }
    else {
      ERRverror("RealityGridSteerer", ERR_WARNING, "Invalid registry address.");
      return 0;
    }
  }
  // make SWS...
  else if((int) initialized && !((int) get_sgs) && (int) make_sgs) {
    char* container;
    char* registry;
    char* username;
    char* group;
    char* application;
    char* purpose;
    char* connectSGS;
    int lifetime;
    int direction;
    bool vis;

    if(configuration.registry_info.address.valid_obj()) 
      configuration.registry_info.address.get_str_val(&registry);
    else {
      ERRverror("RealityGridSteerer", ERR_WARNING, "Invalid registry address.");
      make_sgs = 0;
      return 0;
    }

    if(configuration.use_container.valid_obj())
      configuration.use_container.get_str_val(&container);
    else {
      ERRverror("RealityGridSteerer", ERR_WARNING, "Invalid container address.");
      make_sgs = 0;
      return 0;
    }

    if(configuration.reg_sgs_user.valid_obj())
      configuration.reg_sgs_user.get_str_val(&username);
    else
      username = "<none>";

    if(configuration.reg_sgs_organisation.valid_obj())
      configuration.reg_sgs_organisation.get_str_val(&group);
    else
      group = "<none>";

    if(configuration.reg_sgs_name.valid_obj())
      configuration.reg_sgs_name.get_str_val(&application);
    else
      application = "AVS/Express Visualization";

    if(configuration.reg_sgs_description.valid_obj())
      configuration.reg_sgs_description.get_str_val(&purpose);
    else
      purpose = "<none>";

    if(configuration.reg_sgs_lifetime.valid_obj())
      lifetime = (int) configuration.reg_sgs_lifetime;
    else
      lifetime = 720;

    // check to see if we need to connect to a vis...
    vis = false;
    connectSGS = NULL;
    if(configuration.reg_io_direction.valid_obj())
      direction = (int) configuration.reg_io_direction;
    else
      direction = 1;

    if(direction != 1) {
      if(configuration.reg_sgs_source.valid_obj()) {
	configuration.reg_sgs_source.get_str_val(&connectSGS);
	vis = true;
      }
      else {
	ERRverror("RealityGridSteerer", ERR_WARNING, "No SWS to connect to.");

	// reset "ok" button on dialogue box...
	make_sgs = 0;
	
	return 0;
      }
    }

    // try and create the SWS...
    if(!modInst->createSWS(vis, connectSGS, container, registry, username, group,
			   application, purpose, lifetime)) {

      ERRverror("RealityGridSteerer", ERR_WARNING, modInst->getError());

      // reset "ok" button on dialogue box...
      make_sgs = 0;

      return 0;
    }

    // reset "ok" button on dialogue box...
    make_sgs = 0;
  }

  // return 1 for success
  return 1;
}

