{ config, pkgs, lib, ... }:

{
  options.modules.applications.wayfire.enable = lib.mkEnableOption "wayfire";

  config = lib.mkIf config.modules.applications.wayfire.enable {
    home.packages = with pkgs; [
      wayfire
      wayfirePlugins.wayfire-plugins-extra
      wayfirePlugins.wcm
      wayfirePlugins.wf-shell
    ];  
  };
}
