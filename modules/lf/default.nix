{ config, pkgs, ... }:

{
  home.packages = [ pkgs.lf ];

  home.file.".config/lf/lfrc" = {
    text = builtins.readFile ./lfrc;
    executable = false;
  };
}

