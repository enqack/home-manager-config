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
    git
    go
    htop
    jetbrains-toolbox
    jetbrains.goland
    jetbrains.pycharm-professional
    libgtop
    youtube-music
    zscroll
  ];
  
  home.activation.cloneRepos = lib.mkAfter ''
    if [ ! -d "$HOME/.scripts" ]; then
      ${pkgs.git}/bin/git clone https://github.com/enqack/.scripts.git $HOME/.scripts;
    else
      (cd $HOME/.scripts && ${pkgs.git}/bin/git pull);
    fi

    if [ ! -d "$HOME/.dotfiles" ]; then
      ${pkgs.git}/bin/git clone https://github.com/enqack/.dotfiles.git $HOME/.dotfiles;
    else
      (cd $HOME/.dotfiles && ${pkgs.git}/bin/git pull);
    fi
  '';

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
    ../../config/vim
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper

    ../../git-config.nix
  ];
}

