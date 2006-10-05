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

#include "UIpassword.hxx"

// set RHDEBUG to turn on debug statements
// THIS WILL PRINT THE PASSWORD TO THE CONSOLE!
#ifdef RHDEBUG
#define DBPRINT(string) fprintf(stderr, string)
#else
#define DBPRINT(string)
#endif

// use wide APIs
#define XP_WIDE_API

// generate the update method automatically
UI_UPDATE(UIpassword)

UIpassword::UIpassword(OMobj_id obj) : UIwindow(obj) {
  _classType = "UIpassword";
  password = NULL;
  display_char = '*';
}

UIpassword::~UIpassword() {
  if(password) XtFree(password);
}

Boolean UIpassword::instanceObject() {
  Widget passwd;
  int x, y;
  int width = 0, height = 0;
  int rows = 0, columns = 0;
  int status;
  OMobj_name obj_name;

  DBPRINT("UIpassword::instanceObject\n");

  // get parent widget, name, x and y and autoplace if needs be
  if(!(ParentWnd = getParentWidget())) return False;
  autoPlacementManager(ParentWnd, &x, &y);
  OMget_obj_name(ObjId, &obj_name);

  // get width and height
  status = GetIntVal(ObjId, "width", &width);
  if(status == OM_STAT_SUCCESS) {
    if(width < 1)
      width = 100;
  }
  else {
    width = 100;
  }

  status = GetIntVal(ObjId, "height", &height);
  if(status == OM_STAT_SUCCESS) {
    if(height < 1)
      height = 30;
  }
  else {
    height = 30;
  }

  // create widget
  passwd = XtVaCreateManagedWidget(OMname_to_str(obj_name),
				   xmTextWidgetClass,
				   ParentWnd,
				   XmNx, x,
				   XmNy, y,
				   XmNuserData, this,
				   XmNwidth, width,
				   XmNheight, height,
				   XmNeditMode, XmSINGLE_LINE_EDIT,
				   NULL);

  DragAndDropDisable(passwd);

#ifndef irix4
  XmDropSiteUnregister(passwd);
#endif

  setResources(passwd, -1);

  // attach callbacks
  XtAddCallback(passwd, XmNactivateCallback,
		(XtCallbackProc) UIpassword::activate, this);

  XtAddCallback(passwd, XmNmodifyVerifyCallback,
  		(XtCallbackProc) UIpassword::obscure, this);

  onObjectCreate(passwd);

  return True;
}

void UIpassword::updateObject(int seq_num) {
  DBPRINT("UIpassword::updateObject\n");
  // get widget id
  Widget passwd;
  if((passwd = handle.widget()) == NULL) return;

  // set resources
  setResources(passwd, seq_num);

  // update widget size, position, parent and visibility
  UIwindow::updateObject(seq_num);
}

void UIpassword::destroyObject() {
  DBPRINT("UIpassword::destroyObject\n");
#ifdef __linux__
  Widget passwd = handle.widget();
  if(passwd) {
    XmTextSetString(passwd, NULL);
  }
#endif

  UIwindow::destroyObject();
}

void UIpassword::setResources(Widget passwd, int seq_num) {
  OMobj_id sub_id;
  char* disp_str = NULL;

  DBPRINT("UIpassword::setResources\n");

  // update display_char
  char old_disp_char = display_char;
  sub_id = OMfind_subobj(ObjId, OMstr_to_name("display_char"), OM_OBJ_RD);
  if(OMget_obj_seq(sub_id, OMnull_obj, OM_SEQ_VAL) > seq_num) {
    if(GetStrVal(ObjId, "display_char", &disp_str, 0) != OM_STAT_SUCCESS)
      display_char = '*';
    else {
      if(disp_str && (strlen(disp_str) > 0) && (disp_str[0] != '\0'))
	display_char = disp_str[0];
    }
    if(disp_str) free(disp_str);
  }

  if((display_char != old_disp_char) && password && (strlen(password) > 0)) {
    // reset the current password
    DBPRINT("New display char!\n");
  
    XmTextSetString(passwd, NULL);

    // and update the pointer in the network editor
    sub_id = OMfind_subobj(ObjId, OMstr_to_name("password"), OM_OBJ_RW);
    OMpush_ctx(ObjId, OM_STATE_USR, 0, 0);
    OMset_ptr_val(sub_id, (void*) password, 0);
    OMpop_ctx(ObjId);

#ifdef RHDEBUG
    fprintf(stderr, "Password: %s, pointer: 0x%x\n", password, password);
#endif
  }

  // update core resources
  UIcore::setResources(passwd, seq_num);
  
#if (XmVERSION >= 2)
  // Setting the font list in UIcore::initFontSet
  // can result in the XmText resizing.
  int om_w, om_h;
  Dimension x_w, x_h;
  Boolean resizeH = False, resizeW = False;
  XtVaGetValues(passwd, XmNresizeHeight, &resizeH,
		XmNresizeWidth,  &resizeW, NULL);

  if(!resizeH && GetIntVal(ObjId, "height", &om_h) == OM_STAT_SUCCESS) {
    if(om_h > 0) {
      XtVaGetValues(passwd, XmNheight, &x_h, NULL);
      if(x_h != om_h) {
	XtVaSetValues(passwd, XmNheight, om_h, NULL);
      }
    }
  }

  if(!resizeW && GetIntVal(ObjId, "width", &om_w) == OM_STAT_SUCCESS) {
    if(om_w > 0) {
      XtVaGetValues(passwd, XmNwidth, &x_w, NULL);
      if(x_w != om_w) {
	XtVaSetValues(passwd, XmNwidth, om_w, NULL);
      }
    }
  }
#endif
}

void UIpassword::obscure(Widget w, UIpassword* pw, XmTextVerifyCallbackStruct* cbs) {
  if(!pw) return;

  DBPRINT("UIpassword::obscure\n");

  char* new_pw;

  // handle backspace
  if((*(cbs->text->ptr) == 0) && (cbs->endPos > cbs->startPos)) {
    DBPRINT("Delete!\n");
    cbs->endPos = strlen(pw->password);
    pw->password[cbs->startPos] = '\0';
    return;
  }

  // no backspacing or typing in the middle of the password!
  int len = XmTextGetLastPosition(w);
  if(cbs->currInsert < len) {
    DBPRINT("No inserting!\n");
    cbs->doit = False;
    return;
  }

  new_pw = XtMalloc(cbs->endPos + 2); // new char + NULL
  if(pw->password) {
    strcpy(new_pw, pw->password);
    XtFree(pw->password);
    pw->password = NULL;
  }
  else
    new_pw[0] = '\0';

  pw->password = new_pw;
  strncat(pw->password, cbs->text->ptr, cbs->text->length);
  pw->password[cbs->endPos + cbs->text->length] = '\0';

  for(int i = 0; i < cbs->text->length; i++) {
    cbs->text->ptr[i] = pw->display_char;
  }
#ifdef RHDEBUG
    fprintf(stderr, "Password: %s, pointer: 0x%x\n", pw->password, pw->password);
#endif
}

void UIpassword::activate(Widget passwd, UIpassword* pw, XtPointer cbd) {
  if(!pw) return;
  
  DBPRINT("Activate!\n");
#ifdef RHDEBUG
  fprintf(stderr, "Password: %s, pointer: 0x%x\n", pw->password, pw->password);
#endif

  // can only be here on activate callback (ie. RETURN key)!
  OMobj_id sub_id;
    
  sub_id = OMfind_subobj(pw->ObjId, OMstr_to_name("password"), OM_OBJ_RW);
    
  OMpush_ctx(pw->ObjId, OM_STATE_USR, 0, 0);
  OMset_ptr_val(sub_id, (void*) pw->password, 0);
  OMpop_ctx(pw->ObjId);
  return;
}

//
// Test code
//
int UIpasswordDisplay(OMobj_id id, OMevent_mask event_mask, int seq_num) {
  OMobj_id sub_id;
  char* passwd;
  int status;

  sub_id = OMfind_subobj(id, OMstr_to_name("password"), OM_OBJ_RW);
  status = OMget_ptr_val(sub_id, (void**) &passwd, 0);

  if(status == OM_STAT_SUCCESS) {
#ifdef RHDEBUG
    fprintf(stderr, "Password: %s, pointer: 0x%x\n", passwd, passwd);
#endif

    sub_id = OMfind_subobj(id, OMstr_to_name("text"), OM_OBJ_RW);
    OMpush_ctx(id, OM_STATE_USR, OM_CTX_ALL_NOTIFIES, 0);
    OMset_str_val(sub_id, passwd);
    OMpop_ctx(id);
  };

  return 1;
}
