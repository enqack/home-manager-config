{ config, pkgs, lib, ... }:

{
  options.modules.applications.swaync.enable = lib.mkEnableOption "swaync";

  config = lib.mkIf config.modules.applications.swaync.enable {
    home.packages = with pkgs; [
      swaynotificationcenter
    ];

    home.file.".config/swaync/style.css" = {
      text = builtins.readFile ./style.css;
      executable = false;
    };
  };
}