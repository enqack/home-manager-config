{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
    BAT_THEME = "twodark";
  };

  xdg = {
    enable = true;
    portal = {
      enable = true;
      configPackages = [
        pkgs.xdg-desktop-portal-hyprland
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.xorg.xcursorthemes;
    name = "redglass";
    size = 64;
  };

  imports = [
    ../../config/alacritty
    ../../config/conky
    ../../config/fuzzel
    ../../config/home-manager
    ../../config/hyprland
    ../../config/lf
    ../../config/swaync
    ../../config/waybar
    ../../config/wezterm
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper
    ../../modules/hyprstart

    ../../git-config.nix
  ];
}

