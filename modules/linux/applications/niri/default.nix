{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.modules.applications.niri;
in

{
  options.modules.applications.niri = {
    enable = lib.mkEnableOption "niri";

    outputs = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Niri outputs setting.";
    };
  };

  config = lib.mkIf (cfg.enable) {
    home.packages = with pkgs; [
      xwayland-satellite
      nautilus
      gnome-keyring
      polkit_gnome
      qt6Packages.qt6ct
      inputs.awelauncher.packages.x86_64-linux.awelauncher
      matugen
      linux-wallpaperengine
    ];

    programs.niri = {
      enable = true;
      package = pkgs.niri;
      settings = {
        environment = {
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
          QT_QPA_PLATFORM = "wayland";
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        };
        debug = {
          wait-for-frame-completion-before-queueing = [ ];
        };
        spawn-at-startup = [
          {
            command = [
              "awelaunch"
              "--daemon"
            ];
          }
          {
            command = [
              "sh"
              "-c"
              "conky -q -c $HOME/.config/conky/conkyrc"
            ];
          }
        ];
        overview = {
          backdrop-color = "transparent";
        };
        gestures.hot-corners.enable = false;
        layout = {
          gaps = 10;
          border = {
            enable = true;
            width = 2;
            #active.color = "#f92a1c";
            #inactive.color = "#6943ff";
            #urgent.color = "#ffe700";
          };
          focus-ring = {
            enable = false;
            width = 2;
            #active.color = "#065738";
            #inactive.color = "#6943ff";
            #urgent.color = "#ffe700";
          };
          shadow = {
            enable = true;
            offset = {
              x = 10;
              y = 10;
            };
            draw-behind-window = true;
          };
          preset-column-widths = [
            { proportion = 0.25; }
            { proportion = 0.333; }
            { proportion = 0.5; }
            { proportion = 0.666; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];
          preset-window-heights = [
            { proportion = 0.25; }
            { proportion = 0.333; }
            { proportion = 0.5; }
            { proportion = 0.666; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];
          background-color = "transparent";
          always-center-single-column = true;
          center-focused-column = "on-overflow";
          default-column-width.proportion = 0.5;
        };
        prefer-no-csd = true;
        cursor.theme = "redglass";
        hotkey-overlay.skip-at-startup = true;
        input = {
          # Prevents Niri from intercepting the hardware power button
          power-key-handling.enable = false;
        };
        outputs = cfg.outputs;
        layer-rules = [
          {
            matches = [
              {
                namespace = "^quickshell$";
              }
            ];
            place-within-backdrop = true;
          }
        ];
        window-rules = [
          {
            matches = [
              {
                app-id = ".*";
              }
            ];
            geometry-corner-radius = {
              top-left = 5.0;
              top-right = 5.0;
              bottom-left = 5.0;
              bottom-right = 5.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [
              {
                is-active = false;
              }
            ];
            opacity = 0.9;
          }
          {
            matches = [
              {
                app-id = "com.danklinux.dms$";
              }
            ];
            open-floating = true;
            default-column-width = {
              fixed = 1500;
            };
            default-window-height = {
              fixed = 1000;
            };
          }
          {
            matches = [
              {
                app-id = "^steam$";
                title = "^Steam Big Picture Mode$";
              }
              {
                app-id = "^steam$";
                title = "^Steam$";
              }
            ];
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "^steam$";
                title = "^(notificationtoasts.*|Steam Keyboard|QuickAccess.*|Menu.*|overlay.*)$";
              }
            ];
            open-floating = true;
          }
        ];
        binds =
          with config.lib.niri.actions;

          let
            sh = spawn "sh" "-c";
            terminal = "${pkgs.alacritty}/bin/alacritty";
          in
          {
            # Baisc functions
            "Super+Space".action = spawn "awelaunch" "--show" "drun";
            "Super+Shift+Space".action = spawn "awelaunch" "--show" "run";
            "Super+Control+Space".action = spawn "awelaunch" "--show" "window";
            "Super+Alt+Space".action = spawn "awelaunch" "--show" "ssh";

            "Super+Return".action = spawn terminal;
            "Super+Shift+Return".action = spawn "google-chrome-stable";

            "Super+N".action = sh "dms ipc call widget toggle notificationButton";
            "Super+Shift+N".action = sh "dms ipc call notifications toggleDoNotDisturb";

            "Super+O".action = toggle-overview;

            # Window/column control
            "Super+W".action = close-window;
            "Super+M".action = maximize-column;
            "Super+F".action = fullscreen-window;
            "Super+C".action = center-column;
            "Super+Shift+Left".action = consume-or-expel-window-left;
            "Super+Shift+Right".action = consume-or-expel-window-right;

            # Window selection and movement
            "Super+Up".action = focus-window-up;
            "Super+Down".action = focus-window-down;
            "Super+Shift+Up".action = move-window-up;
            "Super+Shift+Down".action = move-window-down;

            # Column selection and movement
            "Super+BracketLeft".action = focus-column-first;
            "Super+BracketRight".action = focus-column-last;
            "Super+H".action = focus-column-left;
            "Super+L".action = focus-column-right;
            "Super+Shift+H".action = move-column-left;
            "Super+Shift+L".action = move-column-right;
            "Super+WheelScrollLeft".action = focus-column-left;
            "Super+WheelScrollRight".action = focus-column-right;

            # Column control
            "Super+Equal".action = set-column-width "-5%";
            "Super+Minus".action = set-column-width "+5%";
            "Super+Shift+Equal".action = switch-preset-window-height;
            "Super+Shift+Minus".action = switch-preset-column-width;
            "Super+Shift+Period".action = set-column-width "50%";

            # Monitor control
            "Super+J".action = focus-monitor-down;

            "Super+K".action = focus-monitor-up;
            "Super+Shift+J".action = move-column-to-monitor-down;
            "Super+Shift+K".action = move-column-to-monitor-up;

            # Niri/DMS
            "Super+Control+Q".action = sh "dms ipc call widget toggle powerMenuButton";
            "Super+Control+R".action = sh "niri msg action load-config-file";

            # Lock Session
            "Super+Escape".action = sh "${pkgs.systemd}/bin/loginctl lock-session";

            # Screenshotting
            # "Print".action = screenshot;

            # Workspaces
            "Super+0".action.focus-workspace = 0;
            "Super+1".action.focus-workspace = 1;
            "Super+2".action.focus-workspace = 2;
            "Super+3".action.focus-workspace = 3;
            "Super+4".action.focus-workspace = 4;
            "Super+5".action.focus-workspace = 5;
            "Super+6".action.focus-workspace = 6;
            "Super+7".action.focus-workspace = 7;
            "Super+8".action.focus-workspace = 8;
            "Super+9".action.focus-workspace = 9;
            "Super+Shift+0".action.move-window-to-workspace = 0;
            "Super+Shift+1".action.move-window-to-workspace = 1;
            "Super+Shift+2".action.move-window-to-workspace = 2;
            "Super+Shift+3".action.move-window-to-workspace = 3;
            "Super+Shift+4".action.move-window-to-workspace = 4;
            "Super+Shift+5".action.move-window-to-workspace = 5;
            "Super+Shift+6".action.move-window-to-workspace = 6;
            "Super+Shift+7".action.move-window-to-workspace = 7;
            "Super+Shift+8".action.move-window-to-workspace = 8;
            "Super+Shift+9".action.move-window-to-workspace = 9;

            # Special Keys
            "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
            "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
            "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86PowerOff".action = sh "dms ipc call powermenu toggle";
          };
      };
    };

    #xdg.configFile.niri-config.enable = lib.mkForce false;

    # xdg.configFile."niri/config.kdl" = lib.mkForce {
    #   enable = true;
    #   text = ''
    #     //DMS integration
    #     include "dms/colors.kdl"

    #     ${niriCfg}
    #   '';
    # };

    xdg.portal = {
      enable = true;
      configPackages = [
        pkgs.xdg-desktop-portal-gnome
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-termfilechooser
      ];
      config.common = {
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };

    xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
      force = true;
      text = ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/lf-wrapper.sh
      '';
    };

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
