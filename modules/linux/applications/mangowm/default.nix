{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.modules.applications.mangowm;
in

{
  options.modules.applications.mangowm = {
    enable = lib.mkEnableOption "mangowm";

    monitorrules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of monitorrule strings, e.g. [ \"name:^DP-5$,width:2560,height:1440,refresh:144,x:0,y:0\" ]";
    };
  };

  config = lib.mkIf cfg.enable {
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

    wayland.windowManager.mango = {
      enable = true;

      systemd = {
        enable = true;
        variables = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "NIXOS_OZONE_WL"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
          "QT_QPA_PLATFORM"
          "QT_QPA_PLATFORMTHEME"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION"
        ];
      };

      autostart_sh = ''
        dms run &
        awelaunch --daemon &
        conky -q -c $HOME/.config/conky/conkyrc &
      '';

      settings = {
        # Environment
        env = [
          "XDG_CURRENT_DESKTOP,mango"
          "XDG_SESSION_DESKTOP,mango"
          "XDG_SESSION_TYPE,wayland"
          "QT_QPA_PLATFORM,wayland"
          "QT_QPA_PLATFORMTHEME,gtk3"
          "QT_QPA_PLATFORMTHEME_QT6,gtk3"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        ];

        # Cursor (niri: cursor.theme = "redglass")
        cursor_theme = "redglass";
        cursor_size = 24;

        # Gaps (niri: layout.gaps = 10)
        gappih = 10;
        gappiv = 10;
        gappoh = 10;
        gappov = 10;

        # Borders (niri: layout.border.enable = true, width = 2)
        borderpx = 2;

        # Shadows (niri: layout.shadow.enable = true, offset x=10 y=10)
        shadows = 1;
        shadows_position_x = 10;
        shadows_position_y = 10;
        shadow_only_floating = 0;

        # Opacity (niri: window-rule inactive opacity = 0.9)
        focused_opacity = 1.0;
        unfocused_opacity = 0.9;

        # Corner radius (niri: geometry-corner-radius all = 5.0)
        border_radius = 5;

        # Scroller layout to match niri's scrollable column model
        # (niri: default-column-width.proportion = 0.5, preset widths, center-focused-column)
        scroller_default_proportion = 0.5;
        scroller_focus_center = 0;
        scroller_prefer_center = 1;
        scroller_proportion_preset = "0.25,0.333,0.5,0.666,0.75,1.0";

        # Monitor rules forwarded from module option
        monitorrule = cfg.monitorrules;

        # No CSD (niri: prefer-no-csd = true)
        windowrule = [
          "allow_csd:0,appid:.*"
          # Unfocused opacity applied globally via unfocused_opacity above;
          # quickshell floats with fixed size
          "isfloating:1,width:1500,height:1000,appid:org.quickshell"
        ];

        # Tag rules: use scroller on all tags to approximate niri's column layout
        tagrule = [
          "id:1,layout_name:scroller,no_hide:1"
          "id:2,layout_name:scroller,no_hide:1"
          "id:3,layout_name:scroller,no_hide:1"
          "id:4,layout_name:scroller,no_hide:1"
          "id:5,layout_name:scroller,no_hide:1"
          "id:6,layout_name:scroller,no_hide:1"
          "id:7,layout_name:scroller,no_hide:1"
          "id:8,layout_name:scroller,no_hide:1"
          "id:9,layout_name:scroller,no_hide:1"
        ];

        bind = [
          # Launchers
          "SUPER,Space,spawn,awelaunch --show drun"
          "SUPER+SHIFT,Space,spawn,awelaunch --show run"
          "SUPER+CTRL,Space,spawn,awelaunch --show window"
          "SUPER+ALT,Space,spawn,awelaunch --show ssh"

          # Applications
          "SUPER,Return,spawn,${pkgs.alacritty}/bin/alacritty"
          "SUPER+SHIFT,Return,spawn,google-chrome-stable"

          # DMS integration
          "SUPER,N,spawn_shell,dms ipc call widget toggle notificationButton"
          "SUPER+SHIFT,N,spawn_shell,dms ipc call notifications toggleDoNotDisturb"
          "SUPER+CTRL,Q,spawn_shell,dms ipc call widget toggle powerMenuButton"

          # Compositor
          "SUPER+CTRL,R,reload_config"
          "SUPER,O,toggleoverview"

          # Lock session
          "SUPER,Escape,spawn,${pkgs.systemd}/bin/loginctl lock-session"

          # Window control
          "SUPER,W,killclient"
          "SUPER,M,togglemaximizescreen"
          "SUPER,F,togglefullscreen"
          "SUPER,C,centerwin"

          # Window focus (up/down within stack)
          "SUPER,Up,focusdir,up"
          "SUPER,Down,focusdir,down"

          # Column/scroller focus (left/right between columns)
          "SUPER,H,focusdir,left"
          "SUPER,L,focusdir,right"
          "SUPER,BracketLeft,scroller_stack,left" # niri: focus-column-first
          "SUPER,BracketRight,scroller_stack,right" # niri: focus-column-last

          # Window movement
          "SUPER+SHIFT,Up,exchange_client,up"
          "SUPER+SHIFT,Down,exchange_client,down"
          "SUPER+SHIFT,H,exchange_client,left"
          "SUPER+SHIFT,L,exchange_client,right"

          # Scroller stack in/out (niri: consume-or-expel-window-left/right)
          "SUPER+SHIFT,Left,scroller_stack,left"
          "SUPER+SHIFT,Right,scroller_stack,right"

          # Column/window sizing (niri: set-column-width, switch-preset-*)
          "SUPER,equal,set_proportion,+0.05"
          "SUPER,minus,set_proportion,-0.05"
          "SUPER+SHIFT,equal,switch_proportion_preset"
          "SUPER+SHIFT,minus,switch_proportion_preset"
          "SUPER+SHIFT,period,set_proportion,0.5"

          # Monitor focus/move
          "SUPER,J,focusmon,down"
          "SUPER,K,focusmon,up"
          "SUPER+SHIFT,J,tagmon,down"
          "SUPER+SHIFT,K,tagmon,up"

          # Tags (view = focus tag; tag = move window to tag; 1-indexed)
          "SUPER,1,view,1"
          "SUPER,2,view,2"
          "SUPER,3,view,3"
          "SUPER,4,view,4"
          "SUPER,5,view,5"
          "SUPER,6,view,6"
          "SUPER,7,view,7"
          "SUPER,8,view,8"
          "SUPER,9,view,9"
          "SUPER,0,view,0"
          "SUPER+SHIFT,1,tag,1"
          "SUPER+SHIFT,2,tag,2"
          "SUPER+SHIFT,3,tag,3"
          "SUPER+SHIFT,4,tag,4"
          "SUPER+SHIFT,5,tag,5"
          "SUPER+SHIFT,6,tag,6"
          "SUPER+SHIFT,7,tag,7"
          "SUPER+SHIFT,8,tag,8"
          "SUPER+SHIFT,9,tag,9"
          "SUPER+SHIFT,0,tag,0"

          # Audio
          "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
          "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
          "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ];
      };
    };

    xdg.portal = {
      enable = true;
      configPackages = [ pkgs.xdg-desktop-portal-gnome ];
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
