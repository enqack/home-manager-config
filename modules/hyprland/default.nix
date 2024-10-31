{ config, pkgs, ... }:

{
  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
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
      font_size = 30;
      position = "0, 50";
      halign = "center";
      valign = "center";
      }
    ];
    input-field = [
      {
      monitor = "";
      size = "200, 50";
      outline_thickness = 3;
      dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
      dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
      dots_center = true;
      dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
      outer_color = "rgb(151,151,151)";
      inner_color = "rgb(200,200,200)";
      font_color = "rgb(100,100,100)";
      fade_on_empty = false;
      placeholder_text = "<i>Input Password...</i>"; # Text rendered in the input box when it's empty
      hide_input = false;
      rounding = 10; # -1 means complete rounding (circle/oval)
      check_color = "rgb(204,136,34)";
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
    hyprland
    hyprcursor
    hyprdim
    hyprpanel
    hyprpaper
    hyprpicker
    hyprshot
    hyprutils
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
  ];

  home.file.".config/hypr/hyprland.conf" = {
    text = builtins.readFile ./hyprland.conf;
    executable = false;
  };

  home.file.".config/hypr/conf.d" = {
    recursive = true;
    source = ./conf.d;
  };
}

