{ config, pkgs, ... }:

{
  home.packages = [ pkgs.conky ];

  home.file.".config/conky/conkyrc" = {
    text = builtins.readFile ./conkyrc;
    executable = false;
  };
}

