
#include "UIpassword.hxx"

#ifdef RHDEBUG
#define DBPRINT(string) fprintf(stderr, string)
#else
#define DBPRINT(string)
#endif

UI_UPDATE(UIpassword)

UIpassword::UIpassword(OMobj_id obj) : UIimport(obj) {
  _classType = "UIpassword";
  password = NULL;
  display_char = '*';
}

UIpassword::~UIpassword() {
  if(password) XtFree(password);
}

Boolean UIpassword::instanceObject() {
  Widget parent;
  Widget passwd;
  int x, y;
  int width, height;
  int status;
  OMobj_name obj_name;

  DBPRINT("UIpassword::instanceObject\n");

  // get parent widget, x and y and autoplace if needs be
  if(!(parent = getParentWidget())) return False;
  autoPlacementManager(parent, &x, &y);

  OMget_obj_name(ObjId, &obj_name);

  // get width and height
  status = GetIntVal(ObjId, "width", &width);
  if(status == OM_STAT_SUCCESS) {
    if(width < 1)
      width = 100;
  }
  else {
    width = 100;
    UIsetOMWindowWidth(ObjId, width);
  }

  status = GetIntVal(ObjId, "height", &height);
  if(status == OM_STAT_SUCCESS) {
    if(height < 1)
      height = 30;
  }
  else {
    height = 30;
    UIsetOMWindowHeight(ObjId, height);
  }

  // create widget
  passwd = XtVaCreateManagedWidget(OMname_to_str(obj_name),
				   xmTextWidgetClass,
				   parent,
				   XmNx, x,
				   XmNy, y,
				   XmNwidth, width,
				   XmNheight, height,
				   XmNuserData, this,
				   XmNrows, 1,
				   XmNeditMode, XmSINGLE_LINE_EDIT,
				   NULL);

  DragAndDropDisable(passwd);

  updateResources(passwd, -1);

  // attach callbacks
  XtAddCallback(passwd, XmNactivateCallback,
		(XtCallbackProc) UIpassword::callback, this);

  XtAddCallback(passwd, XmNmodifyVerifyCallback,
  		(XtCallbackProc) UIpassword::callback, this);

  onObjectCreate(passwd);

  return True;
}

void UIpassword::updateObject(int seq_num) {
  DBPRINT("UIpassword::updateObject\n");
  // get widget id
  Widget passwd;
  if((passwd = handle.widget()) == NULL) return;

  // set resources
  updateResources(passwd, seq_num);

  // update widget size, position, parent and visibility
  UIimport::updateObject(seq_num);
}

void UIpassword::destroyObject() {
  DBPRINT("UIpassword::destroyObject\n");
#ifdef __linux__
  Widget passwd = handle.widget();
  if(passwd) {
    XmTextSetString(passwd, NULL);
  }
#endif

  UIimport::destroyObject();
}

void UIpassword::updateResources(Widget passwd, int seq_num) {
  OMobj_id sub_id;
  char* disp_str;

  DBPRINT("UIpassword::updateResources\n");

  // update showLastPosition
  sub_id = OMfind_subobj(ObjId, OMstr_to_name("showLastPosition"), OM_OBJ_RD);
  if(OMget_obj_seq(sub_id, OMnull_obj, OM_SEQ_VAL) > seq_num) {
    if(GetIntVal(ObjId, "showLastPosition", &show_last_pos) != OM_STAT_SUCCESS )
      show_last_pos = 0;
  }
#if 0
  // update display_char
  sub_id = OMfind_subobj(ObjId, OMstr_to_name("display"), OM_OBJ_RD);
  if(OMget_obj_seq(sub_id, OMnull_obj, OM_SEQ_VAL) > seq_num) {
    if(GetStrVal(ObjId, "display_char", &disp_str, 0) != OM_STAT_SUCCESS)
      display_char = '*';
    else {
      display_char = disp_str[0];
    }
    if(disp_str) free(disp_str);
  }
#endif
  // update core resources
  UIcore::setResources(passwd, seq_num);
  
#if (XmVERSION >= 2)
  DBPRINT("XmVERSION >= 2\n");
  // Setting the font list in UIcore::initFontSet
  // can result in the XmText resizing.
  int om_h, om_w;
  Boolean resizeH = False, resizeW = False;
  Dimension x_w, x_h;
  XtVaGetValues(passwd, XmNresizeHeight, &resizeH,
		XmNresizeWidth,  &resizeW, NULL);

  if(!resizeH && GetIntVal(ObjId, "height", &om_h) == OM_STAT_SUCCESS) {
    if(om_h > 0) {
      XtVaGetValues(passwd, XmNheight, &x_h, NULL);
      if(x_h != om_h)
	XtVaSetValues(passwd, XmNheight, om_h, NULL);
    }
  }

  if(!resizeW && GetIntVal(ObjId, "width", &om_w) == OM_STAT_SUCCESS) {
    if(om_w > 0) {
      XtVaGetValues(passwd, XmNwidth, &x_w, NULL);
      if(x_w != om_w)
	XtVaSetValues(passwd, XmNwidth, om_w, NULL);
    }
  }
#endif

}

void UIpassword::callback(Widget w, UIpassword* pw, XmTextVerifyCallbackStruct* cbs) {
  if(!pw) return;

  DBPRINT("UIpassword::callback\n");

  char* new_pw;

  if(cbs->reason == XmCR_ACTIVATE) {
    DBPRINT("Activate!\n");
    // can only be here on activate callback!
    OMobj_id sub_id;
    
    sub_id = OMfind_subobj(pw->ObjId,  OMstr_to_name("text"), OM_OBJ_RW);
    
    OMpush_ctx(pw->ObjId, OM_STATE_USR, 0, 0);
    OMset_str_val(sub_id, pw->password);
    OMpop_ctx(pw->ObjId);
    return;
  }

  // handle backspace
  if(*(cbs->text->ptr) == 0) {
    DBPRINT("Delete!\n");
    cbs->endPos = strlen(pw->password);
    pw->password[cbs->startPos] = '\0';

    DBPRINT(pw->password);
    DBPRINT("\n");
    return;
  }

  // no backspacing or typing in the middle of the password!
  int len = XmTextGetLastPosition(w);
  if(cbs->currInsert < len) {
    DBPRINT("No inserting!\n");
    cbs->doit = False;
    return;
  }

  // don't allow paste!
  if(cbs->text->length > 1) {
    DBPRINT("No pasting!\n");
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
  DBPRINT(pw->password);
  DBPRINT("\n");
}

// numpty wrapper functions...
Boolean UIpassword::instanceObject(OMobj_id obj) {
  return instanceObject();
}

void UIpassword::updateObject(OMobj_id obj) {
  return updateObject(GetMaxSeqNum(obj, "update"));
}

void UIpassword::destroyObject(OMobj_id obj) {
  return destroyObject();
}
