{ config, pkgs, lib, ... }:

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
        family = lib.mkDefault "FiraMono Nerd Font";
      };
      font.size = lib.mkDefault 16;

      colors = {
        bright = {
          black = lib.mkDefault "#666666";
          blue = lib.mkDefault "#3b8eea";
          cyan = lib.mkDefault "#29b8db";
          green = lib.mkDefault "#23d18b";
          magenta = lib.mkDefault "#d670d6";
          red = lib.mkDefault "#f14c4c";
          white = lib.mkDefault "#e5e5e5";
          yellow = lib.mkDefault "#f5f543";
        };
        normal = {
          black = lib.mkDefault "#000000";
          blue = lib.mkDefault "#2472c8";
          cyan = lib.mkDefault "#11a8cd";
          green = lib.mkDefault "#0dbc79";
          magenta = lib.mkDefault "#bc3fbc";
          red = lib.mkDefault "#cd3131";
          white = lib.mkDefault "#e5e5e5";
          yellow = lib.mkDefault "#e5e510";
        };
        primary = {
          background = lib.mkDefault "#000000";
          foreground = lib.mkDefault "#cccccc";
        };
        selection = {
          background = lib.mkDefault "#565656";
          text = lib.mkDefault "CellForeground";
        };
      };

      mouse = {
        hide_when_typing = false;
      };

      window = {
        opacity = lib.mkDefault 0.8;
      };

      general.import = [
        "dank-theme.toml"
      ];
      
      # Optional general settings
      # general.live_config_reload = true;
    };
  };
}
