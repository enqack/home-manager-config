{ config, pkgs, ... }:

{
  home.username = "sysop";
  home.homeDirectory = "/home/sysop";

  home.packages = with pkgs; [
    go
    htop
    jetbrains-toolbox
    jetbrains.goland
    jetbrains.pycharm-professional
    libgtop
    youtube-music
    rsstail
    russ
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

  pam.yubico.authorizedYubiKeys.ids = [
    "vvcccbldbvtd"
  ];

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    verbose = true;
  };

  imports = [
    ../../profiles/base

    ../../git-config.nix
  ];
}

