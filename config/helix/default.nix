{ config, pkgs, ... }:

{
  programs.helix = {
    enable = ture;
    settings = [
        theme = "base16_default";
    ]; 
  };
}

