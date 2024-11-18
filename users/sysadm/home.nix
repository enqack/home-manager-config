{ config, pkgs, lib, ... }:

{
  home.username = "sysadm";
  home.homeDirectory = "/home/sysadm";

  home.stateVersion = "24.05";

  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
  };

  xdg.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    git
    go
    htop
    libgtop
    zscroll
  ];

  programs.hyprstart = {
    enable = true;
    vtnr = 2;
  };

  programs.hyprpaper = {
    enable = true;
    wallpaper = [ "eDP-1,~/Pictures/backgrounds/nix-snowflake-dark-night-transparent.png" ];
  };
  
  imports = [
    ../../config/alacritty
    ../../config/conky
    ../../config/fuzzel
    ../../config/home-manager
    ../../config/hyprland
    ../../config/lf
    ../../config/vim
    ../../config/waybar
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper
    ../../modules/hyprstart

    ../../git-config.nix
  ];
}

