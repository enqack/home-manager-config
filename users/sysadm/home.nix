{ config, pkgs, ... }:

{
  home.username = "sysadm";
  home.homeDirectory = "/home/sysadm";

  home.packages = with pkgs; [
    git
    go
    htop
    libgtop
    rsstail
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
  };

  imports = [
    ../../profiles/base

    ../../git-config.nix
  ];
}

