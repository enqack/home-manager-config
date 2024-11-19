{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    swaynotificationcenter
  ];

  home.file.".config/swaync/style.css" = {
    text = builtins.readFile ./style.css;
    executable = false;
  };
}