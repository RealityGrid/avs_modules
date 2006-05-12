
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
	 string+read+notify display_char = "*";
	 int showLastPosition<NEvisible=0>=0;
	 omethod+notify_inst+notify update<NEvisible=0, interruptable=0, lang="cxx", use_src_file=0> =
	    "UIpasswordUpdate";
      }; // UIpassword
}; // UIpasswordMods
