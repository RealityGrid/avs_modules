
flibrary UIpasswordMod <
   build_dir="iac_proj/ui_passwd",
   hdr_dirs="$(XP_PATH0)/tutor/UIimport/ui $(XP_PATH0)/motif_ui/ui",
   cxx_name="" > {

   UIprimitive UIpassword<
      src_file="UIpassword.cxx"
      > {
	 width = 100;
	 height = 30;	
	 ptr+OPort2+nosave password;
	 string+read+notify display_char = "*";
	 int showLastPosition<NEvisible=0> = 0;
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
/*      UI {
	 Modules {
	    IUI {
	       optionList {
		  selectedItem = 0;
	       };
	       mod_panel {
		  x = 0;
		  y = 0;
	       };
	    };
	 };
      };
  */    
      UImod_panel UImod_panel {
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
      
      IAC_PROJ.UIpasswordMod.UIpassword Password {
	 parent => <-.UImod_panel;
	 display_char => <-.char_input.text;
      };
      
      UIlabel arrow {
	 parent => <-.UImod_panel;
	 label = "->";
	 x = <-.Password.x + <-.Password.width;
	 y => <-.Password.y;
	 width = 20;
      };
      
      IAC_PROJ.UIpasswordMod.UIpasswordTest Clear_text {
	 parent => <-.UImod_panel;
	 password => <-.Password.password;
	 x = <-.arrow.x + <-.arrow.width;
	 y => <-.Password.y;
      };
   }; // UIpasswordExample
   
}; // UIpasswordMod
