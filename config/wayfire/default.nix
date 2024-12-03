{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wayfire
    wayfirePlugins.wayfire-plugins-extra
    wayfirePlugins.wcm
    wayfirePlugins.wf-shell
    wayfirePlugins.wwp-switcher
  ];  
}