{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "QT_QPA_PLATFORM, wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME"
        "systemctl --user import-environment DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME"
        "systemctl --user stop xdg-desktop-portal.service"
        "systemctl --user start xdg-desktop-portal-hyperland.service"
        "systemctl --user start xdg-desktop-portal.service"
        "hypridle"
        "hyprctl setcursor redglass 32"
        "waybar -c $HOME/.config/waybar/hypr-config"
        "swaync"
        "blueman-applet"
        "conky -q -c $HOME/.config/conky/conkyrc"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = lib.mkDefault "rgba(a80301ee) rgba(a80301ee) 90deg";
        "col.inactive_border" = lib.mkDefault "rgba(1f1f1fee)";
        layout = "dwindle";
        allow_tearing = false;
        resize_on_border = true;
        resize_corner = 2;
      };

      debug = {
        overlay = false;
        disable_logs = false;
        disable_time = false;
      };

      animations = {
        enabled = true;

        bezier = [
          "easeInOutQuart, 0.76, 0, 0.24, 1"
          "easeInCirc, 0.55, 0, 1, 0.45"
        ];

        animation = [
          "windows, 1, 10, easeInOutQuart, popin 10%"
          "windowsOut, 1, 6, easeInOutQuart, popin 10%"
          "border, 1, 10, default"
          "borderangle, 1, 10, default, loop"
          "fade, 1, 10, easeInOutQuart"
          "workspaces, 1, 5, easeInCirc, slidefadevert 95%"
        ];
      };

      decoration = {
        rounding = 5;
        dim_inactive = true;
        dim_strength = 0.25;

        blur = {
          enabled = true;
          size = 1;
          passes = 1;

          vibrancy = 0.5;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = lib.mkDefault "rgba(1a1a1aee)";
        };
      };

      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "altwin:menu_win";
        kb_rules = "";

        follow_mouse = 0;

        touchpad = {
          natural_scroll = false;
          "tap-to-click" = false;
        };

        sensitivity = 0;
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      gestures = {
        workspace_swipe = false;
      };

      cursor = {
        enable_hyprcursor = false;
        no_hardware_cursors = 1;
      };

      monitor = [
        "DP-1,highres@120,0x0,1,bitdepth,10"
        "DP-2,highres@120,0x1440,1,bitdepth,10"
      ];

      workspaces = {
        workspace = [
          "1, monitor:DP-2, persistent:true"
          "2, monitor:DP-2, persistent:true"
          "3, monitor:DP-2, persistent:true"
          "4, monitor:DP-2, persistent:true"
          "5, monitor:DP-2, persistent:true"

          "6, monitor:DP-1, persistent:true"
          "7, monitor:DP-1, persistent:true"
          "8, monitor:DP-1, persistent:true"
          "9, monitor:DP-1, persistent:true"
          "10, monitor:DP-1, persistent:true"
        ];
      };

      dwindle = {
        force_split = 2;
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
        mfact = 0.7;
        orientation = "top";
        new_on_top = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };

      windowrulev2 = [
        # WM System application window rules
        "tile, class:^(Alacritty)$"
        "float, title:^(Bluetooth Devices)$"
        "float, title:^(Local Services)$"
        "float, class:(Alacritty), title:(waybar-float)"
        "center, class:(Alacritty), title:(waybar-float)"
        "size 70% 80%, class:(Alacritty), title:(waybar-float)"

        # General application window rules
        "float, title:^(Steam Settings)"
        "float, class:(Steam), title:^(Special Offers)"

        # Bitwarden
        "float, title:^(Bitwarden)$"

        # VSCode workaround
        "workspace 4 silent, class:^(code-url-handler)$"
        "float, class:^(code-url-handler)$, title:^(Open.*)$"
        "center, class:^(code-url-handler)$, title:^(Open.*)$"
      ];

      # 🔧 Variables
      "$mainMod" = "SUPER";
      "$terminal" = "alacritty";
      "$editor" = "emacs";
      "$xdgmenu" = "walker";
      "$pathmenu" = ''XDG_CURRENT_DESKTOP="*" fuzzel --list-executables-in-path --filter-desktop'';

      # 🧠 Descriptive Binds (bindd)
      bindd = [
        "$mainMod, space, Open applicaton menu, exec, $xdgmenu"
        "$mainMod CONTROL, space, Open applicaton menu, exec, $pathmenu"
        "$mainMod, return, Open a terminal, exec, $terminal"
        "$mainMod, E, Open an editor, exec, $editor"
        "$mainMod SHIFT, return, Open Chrome browser, exec, google-chrome-stable"
      ];

      # 🔗 Regular Binds (bind)
      bind = [
        "$mainMod, W, killactive"
        "$mainMod, F, fullscreen"
        "$mainMod, V, togglefloating"
        "$mainMod, V, resizeactive, exact 75% 75%"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"
        "$mainMod, C, centerwindow"

        "$mainMod, Tab, focusmonitor, +1"
        "$mainMod SHIFT, Tab, focusmonitor, -1"

        "$mainMod, N, exec, swaync-client -t"
        "$mainMod SHIFT, N, exec, swaync-client -d"

        "$mainMod, code:9, exec, hyprlock"
        "$mainMod CONTROL, Q, exec, wlogout"
        "$mainMod CONTROL, R, exec, hyprctl reload"
        "$mainMod CONTROL, W, exec, pkill -USR2 waybar"

        "$mainMod CONTROL, D, exec, hyprctl keyword general:layout dwindle"
        "$mainMod CONTROL, M, exec, hyprctl keyword general:layout master"
        "$mainMod CONTROL, S, exec, $HOME/.scripts/hypr/start-default-apps"

        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        "$mainMod, code:34, workspace, e-1"
        "$mainMod, code:35, workspace, e+1"

        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHFIT, J, movewindow, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      # 🖱️ Mouse Bindings (bindm)
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # 🌞 Brightness & 🎵 Media Keys (bindl)
      bindl = [
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", X86AudioNext, exec, playerctl next"
        ", X86AudioPrev, exec, playerctl previous"
      ];
    };
    extraConfig = ''
      #env = LIBVA_DRIVER_NAME,nvidia
      #env = GBM_BACKEND,nvidia-drm
      #env = __GLX_VENDOR_LIBRARY_NAME,nvidia

      #env = XCURSOR_SIZE,32
      #env = XCURSOR_THEME,redglass

      source = ./conf.d/plugins.conf
    '';
  };

  xdg.portal = {
    enable = true;
    configPackages = [
      pkgs.xdg-desktop-portal-hyprland
    ];
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  programs.hyprlock.enable = false;

  programs.hyprlock.settings = {
    general = {
      grace = 3;
      immediate_render = true;
      hide_cursor = true;
    };
    auth = {
      "fingerprint:enabled" = true;
    };
    background = lib.mkForce [
      {
      monitor = "";
      path = "screenshot";
      blur_passes = 3;
      blur_size = 7;
      }
    ];
    label = [
      {
      monitor = "DP-4";
      text = "$USER";
      font_size = 32;
      position = "0, 50";
      halign = "center";
      valign = "center";
      }
      {
      monitor = "DP-4";
      text = "Tap security token and enter password.";
      font_size = 16;
      position = "0, -75";
      halign = "center";
      valign = "center";
      }
    ];
    input-field = lib.mkDefault [
      {
      monitor = "DP-4";
      size = "100, 50";
      outline_thickness = 3;
      dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
      dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
      dots_center = false;
      dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
      outer_color = "rgb(151,151,151)";
      inner_color = "rgb(200,200,200)";
      font_color = "rgb(100,100,100)";
      fade_on_empty = false;
      placeholder_text = "<i>Input Password...</i>"; # Text rendered in the input box when it's empty
      hide_input = false;
      rounding = 10; # -1 means complete rounding (circle/oval)
      check_color = "rgb(34, 90, 136)";
      fail_color = "rgb(204,34,34)"; # if authentication failed, changes outer_color and fail message color
      fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>"; # can be set to empty
      fail_transition = 300; # transition time in ms between normal outer_color and fail_color
      capslock_color = -1;
      numlock_color = -1;
      bothlock_color = -1; # when both locks are active, -1 means don't change outer color
      invert_numlock = false; # change color if numlock is off
      swap_font_color = false;

      position = "0, -20";
      }
    ];
  };

  services.hypridle.enable = true;
  services.hypridle.settings = {
    general = {
      lock_cmd = "pidof hyprlock || hyprlock";
      before_sleep_cmd = "loginctl lock-sesison";
      after_sleep_cmd = "hyprctl dispatch dpms on";
    };

    listener = [
      {
        timeout = 1740;
        on-timeout = "notify-send \"Screen lock incoming... 60 seconds.\"";
      }
      {
        timeout = 1800;
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 3600;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };


  home.packages = with pkgs; [
    fprintd
    hyprcursor
    hyprdim
    hyprpaper
    hyprpicker
    hyprshot
    hyprutils
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  home.file.".config/hypr/conf.d" = {
    recursive = true;
    source = ./conf.d;
  };

  # wayland.windowManager.hyprland.plugins = [
  #   "hyprfocus"
  # ];
}

