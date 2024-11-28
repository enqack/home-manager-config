{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''

      env = XDG_CURRENT_DESKTOP, Hyprland
      env = XDG_SESSION_TYPE, wayland
      env = XDG_SESSION_DESKTOP, Hyprland
      env = QT_QPA_PLATFORM, wayland
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
      env = QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that
      
      #env = LIBVA_DRIVER_NAME,nvidia
      #env = GBM_BACKEND,nvidia-drm
      #env = __GLX_VENDOR_LIBRARY_NAME,nvidia

      exec-once = dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME
      exec-once = systemctl --user import-environment DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME

      exec-once = systemctl --user stop xdg-desktop-portal.service
      exec-once = systemctl --user start xdg-desktop-portal-hyperland.service
      exec-once = systemctl --user start xdg-desktop-portal.service
      
      exec-once = hyprpaper
      exec-once = hypridle

      exec-once = hyprctl setcursor redglass 32

      exec-once = waybar
      exec-once = swaync

      exec-once = blueman-applet

      exec-once = conky -q -c $HOME/.config/conky/conkyrc

      # Set programs
      $terminal = alacritty
      $editor = vim
      $menu = fuzzel

      #env = XCURSOR_SIZE,32
      #env = XCURSOR_THEME,redglass

      source = ./conf.d/cursor.conf
      source = ./conf.d/debug.conf
      source = ./conf.d/monitor.conf
      source = ./conf.d/general.conf
      source = ./conf.d/device.conf
      source = ./conf.d/input.conf
      source = ./conf.d/gestures.conf
      source = ./conf.d/layouts.conf
      source = ./conf.d/workspaces.conf
      source = ./conf.d/windowrules.conf
      source = ./conf.d/animations.conf
      source = ./conf.d/decoration.conf
      source = ./conf.d/misc.conf
      source = ./conf.d/binds.conf

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

  programs.hyprlock.enable = true;
  
  programs.hyprlock.settings = {
    general = {
      grace = 3;
      no_fade_in = true;
      immediate_render = true;
    };
    background = [
      {
      path = "screenshot";
      blur_passes = 3;
      blur_size = 7;
      noise = 0.025;
      }
    ];
    label = [
      {
      monitor = "";
      text = "$USER";
      font_size = 32;
      position = "0, 50";
      halign = "center";
      valign = "center";
      }
      {
      monitor = "";
      text = "Tap security token and enter password.";
      font_size = 16;
      position = "0, -90";
      halign = "center";
      valign = "center";
      }
    ];
    input-field = [
      {
      monitor = "";
      size = "200, 50";
      outline_thickness = 5;
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
      check_color = "rgb(34,136,34)";
      fail_color = "rgb(204,34,34)"; # if authentication failed, changes outer_color and fail message color
      fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>"; # can be set to empty
      fail_transition = 300; # transition time in ms between normal outer_color and fail_color
      capslock_color = -1;
      numlock_color = -1;
      bothlock_color = -1; # when both locks are active, -1 means don't change outer color
      invert_numlock = false; # change color if numlock is off
      swap_font_color = false;

      position = "0, -20";
      halign = "center";
      valign = "center";
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
    hyprcursor
    hyprdim
    hyprpanel
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

