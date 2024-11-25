{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      bell = {
        animation = "EaseOutExpo";
        color = "#ffffff";
        duration = 1;
      };

      font.normal = {
        family = "JetBrainsMono Nerd Font";

      };
      font.size = 16;

      colors = {
        bright = {
          black = "#666666";
          blue = "#3b8eea";
          cyan = "#29b8db";
          green = "#23d18b";
          magenta = "#d670d6";
          red = "#f14c4c";
          white = "#e5e5e5";
          yellow = "#f5f543";
        };
        normal = {
          black = "#000000";
          blue = "#2472c8";
          cyan = "#11a8cd";
          green = "#0dbc79";
          magenta = "#bc3fbc";
          red = "#cd3131";
          white = "#e5e5e5";
          yellow = "#e5e510";
        };
        primary = {
          background = "#000000";
          foreground = "#cccccc";
        };
        selection = {
          background = "#565656";
          text = "CellForeground";
        };
      };

      mouse = {
        hide_when_typing = false;
      };

      window = {
        opacity = 0.8;
      };

      # Optional general settings
      # general.live_config_reload = true;
    };
  };
}