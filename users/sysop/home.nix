{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base

    ../../git-config.nix
  ];
  
  stylix = {
    enable = true;
    image = ./crinkled-paper.png;
    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };

      monospace = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
    targets = {
      alacritty.enable = false;
      fuzzel.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      waybar.enable = false;
    };
  };

  home.username = "sysop";
  home.homeDirectory = "/home/sysop";

  home.packages = with pkgs; [
    base16-schemes
    go
    hugo
    jetbrains-toolbox
    jetbrains.goland
    jetbrains.pycharm-professional
    libgtop
    obsidian
    youtube-music
    rsstail
    russ
    zscroll
    tytools
  ];  

  home.file.".config/zsh/.zshrc" = {
    text = ''
      eval "$(hugo completion zsh)"
    '';
  };

  programs.hyprstart = {
    enable = true;
    vtnr = 1;
  };

  programs.hyprpaper = {
    enable = true;
    wallpaper = [
      "eDP-1,~/Pictures/backgrounds/crinkled-paper.png"
      "HDMI-A-1,~/Pictures/backgrounds/crinkled-paper.png"
    ];
  };

  xdg.configFile."Yubico/u2f_keys" = {
    text = ''
    '';
  };

  systemd.user.services = {
    nestops-sysman = {
      Unit = {
        Description = "Serve NestOps System Manual";
      };

      Service = {
        WorkingDirectory = "%h/NestOps/nestops-sysman";
        ExecStart = ''
          ${pkgs.hugo}/bin/hugo server \
            --buildDrafts \
            --buildExpired \
            --buildFuture
        '';
      };
    };
  };
}

