APPS.MultiWindowApp MultiWindowAppAG {
   UI {
      shell {
         x = 15;
         y = 49;
      };
      Modules {
         IUI {
            optionList {
               selectedItem = 0;
               cmdList => {
                  <-.<-.<-.<-.AccessGridViewer3D.AccessGridEmitter.AccessGridEmitterUI.UImod_panel.option};
            };
            mod_panel {
               x = 0;
               y = 0;
            };
         };
      };
   };
   IAC_PROJ.AccessGrid.AccessGridMacs.AccessGridViewer3D AccessGridViewer3D<NEx=660.,NEy=407.> {
      Scene {
         View {
            ViewUI {
               ViewPanel {
                  UI {
                     panel {
                        defaultX = 421;
                        defaultY = 493;
                     };
                  };
               };
            };
         };
      };
      AccessGridEmitter {
         AccessGridEmitterUI {
            UImod_panel {
               option {
                  set = 1;
               };
            };
            ConfigUI {
               config_frame {
                  y = 0;
               };
               config_label {
                  y = 0;
               };
               name_label {
                  y = 24;
               };
               address_label {
                  y = 54;
               };
               port_label {
                  y = 84;
               };
               ttl_label {
                  y = 114;
               };
               encoder_menu {
                  x = 0;
                  y = 144;
               };
               src0 {
                  set = 1;
               };
            };
            ControlUI {
               control_frame {
                  y = 190;
               };
               control_label {
                  y = 0;
               };
               start_toggle {
                  y = 24;
               };
               update_slider {
                  y = 48;
               };
               quality_slider {
                  y = 108;
               };
               colour_slider {
                  y = 168;
               };
               format_menu {
                  x = 0;
                  y = 228;
               };
               form0 {
                  set = 1;
               };
               flip_h_toggle {
                  y = 265;
               };
               flip_v_toggle {
                  y = 289;
               };
               refresh_button {
                  y = 313;
               };
            };
         };
      };
   };
};
