{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
  };

  home.file.".config/waybar/config" = {
    text = builtins.readFile ./config;
    executable = false;
  };

  home.file.".config/waybar/style.css" = {
    text = builtins.readFile ./style.css;
    executable = false;
  };
}