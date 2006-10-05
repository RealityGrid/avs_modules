/*-----------------------------------------------------------------------

  This file is part of the UIpassword module.

  (C) Copyright 2006, University of Manchester, United Kingdom,
  all rights reserved.

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

#ifndef __UIPASSWORD_H__

#include "wind.h"

#include <Xm/Text.h>

class UIpassword : public UIwindow {
public:
  UIpassword(OMobj_id);
  ~UIpassword();

  virtual Boolean instanceObject();
  virtual void updateObject(int);
  virtual void destroyObject();

private:
  static void obscure(Widget, UIpassword*, XmTextVerifyCallbackStruct*);
  static void activate(Widget, UIpassword*, XtPointer);
  void setResources(Widget, int);
  char* password;
  char display_char;
};

#define __UIPASSWORD_H__
#endif // __UIPASSWORD_H__
