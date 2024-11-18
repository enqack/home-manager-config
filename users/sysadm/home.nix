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
  
  home.activation.cloneRepos = lib.mkAfter ''
    repos=(
      "https://github.com/enqack/.scripts.git $HOME/.scripts"
    )

    for repo in "$repos[@]"; do
      url=$(echo "$repo" | cut -d' ' -f1)
      dir=$(echo "$repo" | cut -d' ' -f2)
      if [ ! -d "$dir" ]; then
        ${pkgs.git}/bin/git clone "$url" "$dir"
      else
        (cd "$dir" && ${pkgs.git}/bin/git pull)
      fi
    done
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
    ../../config/waybar
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper

    ../../git-config.nix
  ];
}

