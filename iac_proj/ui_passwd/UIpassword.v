
flibrary UIpasswordMod <
   build_dir="iac_proj/ui_passwd",
   hdr_dirs="$(XP_PATH0)/tutor/UIimport/ui $(XP_PATH0)/motif_ui/ui",
   cxx_name="" > {

   UIprimitive UIpassword<
      src_file="UIpassword.cxx"
      > {
	 width = 100;
	 height = 30;	
	 string text;
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
      UI {
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
      UImod_panel UImod_panel {
	 option {
	    set = 1;
	 };
      };
      IAC_PROJ.UIpasswordMod.UIpassword UIpassword {
	 parent => <-.UImod_panel;
	 y = 0;
	 text = "";
      };
      IAC_PROJ.UIpasswordMod.UIpasswordTest UIpasswordTest {
	 parent => <-.UImod_panel;
	 text = "";
	 password => <-.UIpassword.password;
	 y = 0;
	 x = 120;
      };
      UIlabel UIlabel {
	 parent => <-.UImod_panel;
	 label => "->";
	 x = 100;
	 y = 0;
	 width = 20;
      };
   }; // UIpasswordExample
   
}; // UIpasswordMod
