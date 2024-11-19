{ config, pkgs, lib, ... }:

{
  home.username = "sysop";
  home.homeDirectory = "/home/sysop";

  home.stateVersion = "24.05";

  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
  };

  xdg.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    go
    htop
    jetbrains-toolbox
    jetbrains.goland
    jetbrains.pycharm-professional
    libgtop
    youtube-music
    rsstail
    zscroll
  ];

  programs.hyprstart = {
    enable = true;
    vtnr = 1;
  };

  programs.hyprpaper = {
    enable = true;
    wallpaper = [ "eDP-1,~/Pictures/backgrounds/crinkled-paper.png" ];
  };
  
  imports = [
    ../../config/alacritty
    ../../config/conky
    ../../config/fuzzel
    ../../config/home-manager
    ../../config/hyprland
    ../../config/lf
    ../../config/swaync
    ../../config/vim
    ../../config/waybar
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper
    ../../modules/hyprstart

    ../../git-config.nix
  ];
}

