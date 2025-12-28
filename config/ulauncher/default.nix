{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    gtk3
    ulauncher
  ];
}