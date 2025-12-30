{ config, pkgs, lib, ... }:

{
  options.modules.applications.conky.enable = lib.mkEnableOption "conky";

  config = lib.mkIf config.modules.applications.conky.enable {
    home.packages = [ pkgs.conky ];

    home.file.".config/conky/conkyrc" = {
      text = builtins.readFile ./conkyrc;
      executable = false;
    };
  };
}
