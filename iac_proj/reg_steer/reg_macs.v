flibrary RealityGridMacs {
   macro RealityGridSteerer {
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringParams RealityGridSteeringParams {
	 reg_sgs_name = "AVS/Express Sink";
	 connected = 0;
	 pollInterval = 1;
	 numSlices = 0;
      };
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 slices => configuration.numSlices;
	 outData.size = 0;
      };

      olink outData => RealityGridSteeringMod.outData;

      macro RealityGridSteererUI {
	 UImod_panel UImod_panel {
	    title = "RealityGrid Steerer";
	    width = 250;
	 };

	 macro ConfigUI {
	    UIframe config_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 90;
	    };
	    UIlabel config_label {
	       parent => <-.config_frame;
	       label = "Configuration";
	       width = 250;
	       alignment = 1;
	    };
	    
	    UIlabel name_label {
	       parent => <-.config_frame;
	       label = "SGS name:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext name_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_name;
	       width = 160;
	       x => <-.name_label.x + <-.name_label.width;
	       y => <-.name_label.y;
	    };

	    UIlabel sgs_label {
	       parent => <-.config_frame;
	       label = "SGS address:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext sgs_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_address;
	       width = 160;
	       x => <-.sgs_label.x + <-.sgs_label.width;
	       y => <-.sgs_label.y;
	    };
	 }; // ConfigUI

	 macro ControlUI {
	    UIframe control_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 138;
	    };
	    UIlabel control_label {
	       parent => <-.control_frame;
	       label = "Control";
	       width = 250;
	       alignment = 1;
	    };

	    UIslider poll_slider {
	       parent => <-.control_frame;
	       title = "Data polling interval (secs)";
	       mode = "real";
	       decimalPoints = 1;
	       min = 0.1;
	       max = 15.0;
	       width = 245;
	       value => <-.<-.<-.RealityGridSteeringParams.pollInterval;
	    };
	    
	    UItoggle start_toggle {
	       parent => <-.control_frame;
	       label = "Connect";
	       set => <-.<-.<-.RealityGridSteeringMod.start;
	    };
	    
	    UItoggle poll_toggle {
	       parent => <-.control_frame;
	       label = "Poll for data";
	       set => <-.<-.<-.RealityGridSteeringMod.nudge;
	    };

	 }; // ControlUI
      }; // RealityGridSteererUI
   }; // RealityGridSteerer

   macro RealityGridDataSliceCompositor {

      ilink inData;
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridDataSliceCompositorMod RealityGridDataSliceCompositorMod {
	 inData => <-.inData;
      };

      olink outCharData => RealityGridDataSliceCompositorMod.outCharData;
      olink outIntData => RealityGridDataSliceCompositorMod.outIntData;
      olink outFloatData => RealityGridDataSliceCompositorMod.outFloatData;
      olink outDoubleData => RealityGridDataSliceCompositorMod.outDoubleData;
      
   }; // RealityGridDataSliceCompositor
   
   macro RealityGridLBE3DReader {

      ilink inField;
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringParams RealityGridSteeringParams {
	 reg_sgs_name = "AVS/Express LBE3D Reader";
	 connected = 0;
	 pollInterval = 1;
	 numSlices = 0;
      };
      
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 slices => configuration.numSlices;
	 outData.size = 0;
      };

      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridLBE3DReaderMod RealityGridLBE3DReaderMod {
	 configuration => <-.RealityGridSteeringParams;
	 inData => <-.RealityGridSteeringMod.outData;
	 inField => <-.inField;
	 volOutput = 1;
	 minLabel = 0.0;
	 maxLabel = 0.0;
      };

      FLD_MAP.Mesh_Mappers.uniform_mesh uniform_mesh {
	 in_dims => <-.RealityGridLBE3DReaderMod.outDims;
      };

      FLD_MAP.Data_Mappers.node_scalar node_scalar {
	 in_data => <-.RealityGridLBE3DReaderMod.outData;
      };

      FLD_MAP.Data_Mappers.node_scalar node_scalar_short {
	 in_data => <-.RealityGridLBE3DReaderMod.outShortData;
      };
      
      FLD_MAP.Data_Mappers.node_scalar node_scalar_byte {
	 in_data => <-.RealityGridLBE3DReaderMod.outByteData;
      };
      
      FLD_MAP.Combiners.combine_mesh_data combine_mesh_data {
	 in_mesh => <-.uniform_mesh.out;
	 in_nd => <-.node_scalar.out;
      };
      
      FLD_MAP.Combiners.combine_mesh_data combine_mesh_data_short {
	 in_mesh => <-.uniform_mesh.out;
	 in_nd => <-.node_scalar_short.out;
      };
      
      FLD_MAP.Combiners.combine_mesh_data combine_mesh_data_byte {
	 in_mesh => <-.uniform_mesh.out;
	 in_nd => <-.node_scalar_byte.out;
      };
      
      olink outData => combine_mesh_data.out;
      olink outShortData => combine_mesh_data_short.out;
      olink outByteData => combine_mesh_data_byte.out;

      macro RealityGridLBE3DReaderUI {
	 UImod_panel UImod_panel {
	    title = "RealityGrid LBE3D Reader";
	    width = 250;
	 };

	 macro ConfigUI {
	    UIframe config_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 90;
	    };
	    UIlabel config_label {
	       parent => <-.config_frame;
	       label = "Configuration";
	       width = 250;
	       alignment = 1;
	    };
	    
	    UIlabel name_label {
	       parent => <-.config_frame;
	       label = "SGS name:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext name_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_name;
	       width = 160;
	       x => <-.name_label.x + <-.name_label.width;
	       y => <-.name_label.y;
	    };

	    UIlabel sgs_label {
	       parent => <-.config_frame;
	       label = "SGS address:";
	       width = 85;
	       alignment = 2;
	    };
	    UItext sgs_text {
	       parent => <-.config_frame;
	       text => <-.<-.<-.RealityGridSteeringParams.reg_sgs_address;
	       width = 160;
	       x => <-.sgs_label.x + <-.sgs_label.width;
	       y => <-.sgs_label.y;
	    };
	 }; // ConfigUI

	 macro ControlUI {
	    UIframe control_frame {
	       parent => <-.<-.UImod_panel;
	       width = 250;
	       height = 138;
	    };
	    UIlabel control_label {
	       parent => <-.control_frame;
	       label = "Control";
	       width = 250;
	       alignment = 1;
	    };

	    UIslider poll_slider {
	       parent => <-.control_frame;
	       title = "Data polling interval (secs)";
	       mode = "integer";
	       min = 1.0;
	       max = 15.0;
	       width = 245;
	       value => <-.<-.<-.RealityGridSteeringParams.pollInterval;
	    };
	    
	    UItoggle start_toggle {
	       parent => <-.control_frame;
	       label = "Connect";
	       set => <-.<-.<-.RealityGridSteeringMod.start;
	    };

	    UItoggle poll_toggle {
	       parent => <-.control_frame;
	       label = "Poll for data";
	       set => <-.<-.<-.RealityGridSteeringMod.nudge;
	    };
	 }; // ControlUI

      }; // RealityGridLBE3DReaderUI
	 
   }; // RealityGridLBE3DReader

   macro RealityGridNAMDReader {
      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringParams RealityGridSteeringParams {
	 reg_sgs_name = "AVS/Express Sink";
	 connected = 0;
	 pollInterval = 1;
	 numSlices = 0;
      };

      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridSteeringMod RealityGridSteeringMod {
	 configuration => <-.RealityGridSteeringParams;
	 initialized = 0;
	 connected => configuration.connected;
	 slices => configuration.numSlices;
	 outData.size = 0;
      };

      IAC_PROJ.RealityGrid.RealityGridMods.RealityGridNAMDReaderMod RealityGridNAMDReaderMod {
	 configuration => <-.RealityGridSteeringParams;
	 inData => <-.RealityGridSteeringMod.outData;
      };
      
   }; // RealityGridNAMDReader
   
}; // RealityGridMacs
