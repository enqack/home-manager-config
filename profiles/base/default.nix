{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.05";

  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
  };

  xdg.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../config/alacritty
    ../../config/conky
    ../../config/fuzzel
    ../../config/home-manager
    ../../config/hyprland
    ../../config/lf
    ../../config/swaync
    ../../config/waybar
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper
    ../../modules/hyprstart

    ../../git-config.nix
  ];
}

