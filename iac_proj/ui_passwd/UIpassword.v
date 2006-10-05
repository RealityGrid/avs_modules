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

flibrary UIpasswordMod <
   build_dir="iac_proj/ui_passwd",
   hdr_dirs="$(XP_PATH0)/motif_ui/ui",
   cxx_name="" > {

   UIprimitive UIpassword<
      src_file="UIpassword.cxx"
      > {
	 width = 100;
	 height = 30;
	 ptr+OPort2+nosave password;
	 string+read+notify display_char = "*";
	 omethod+notify_inst+notify update<NEvisible=0, interruptable=0, lang="cxx", use_src_file=0> =
	    "UIpasswordUpdate";
      }; // UIpassword

   UItext UIpasswordTest<
      src_file="UIpassword.cxx"
      > {
	 outputOnly = 1;
	 ptr+IPort2+read+notify+nosave &password;
	 omethod+notify display<NEvisible=0, interruptable=0, lang="cxx"> =
	    "UIpasswordDisplay";
      }; // UIpasswordTest

   APPS.MultiWindowApp UIpasswordExample {
      UImod_panel UImod_panel {
	 title = "UIpasswordExample";
	 option {
	    set = 1;
	 };
      };
      
      UIlabel passwd_title {
	 parent => <-.UImod_panel;
	 label = "UIpassword Tester";
	 width => parent.clientWidth;
	 color {
	    foregroundColor = "white";
	    backgroundColor = "blue";
	 };
      };

      UIlabel char_label {
	 parent => <-.UImod_panel;
	 y => <-.passwd_title.y + 30;
	 label = "Display char:";
      };

      UItext char_input {
	 parent => <-.UImod_panel;
	 x => <-.char_label.x + <-.char_label.width;
	 y => <-.char_label.y;
	 rows = 1;
	 columns = 1;
	 text = "*";
      };
      
      IAC_PROJ.UIpasswordMod.UIpassword password {
	 parent => <-.UImod_panel;
	 display_char => <-.char_input.text;
      };
      
      UIlabel arrow {
	 parent => <-.UImod_panel;
	 label = "->";
	 x => <-.password.x + <-.password.width;
	 y => <-.password.y;
	 width = 20;
      };
      
      IAC_PROJ.UIpasswordMod.UIpasswordTest clear_text {
	 parent => <-.UImod_panel;
	 password => <-.password.password;
	 x => <-.arrow.x + <-.arrow.width;
	 y => <-.password.y;
      };
   }; // UIpasswordExample
   
}; // UIpasswordMod
