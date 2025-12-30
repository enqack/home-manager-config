{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/base

    ../../modules/applications/niri
    
    ../../git-config.nix
  ];

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    opacity.terminal = 0.8;
    image = ./pictures/synthwave-crinkled-paper.png;
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.fira-mono;
        name = "FiraMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.fira-mono;
        name = "FiraMono Nerd Font";
      };

      monospace = {
        package = pkgs.nerd-fonts.fira-mono;
        name = "FiraMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    targets = {
      gtk.enable = false;
      gtk.extraCss = ''
        window.background { border-width: 2px; }
      '';
      qt.enable = false;
      fontconfig.enable = true;
      font-packages.enable = true;
      hyprpaper.enable = true;
      alacritty.enable = true;
      wezterm.enable = true;
    };
  };

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

  home.file."Pictures/crinkled-paper.png" = {
    enable = true;
    source = ./pictures/crinkled-paper.png;
  };

  home.file."Pictures/synthwave-crinkled-paper.png" = {
    enable = true;
    source = ./pictures/synthwave-crinkled-paper.png;
  };
  
  modules.applications.hyprstart = {
    enable = true;
    vtnr = 3;
    compositor = "niri-session -l";
  };

  modules.applications.hyprpaper = {
    enable = true;
    wallpaper = [ "eDP-1,~/Pictures/backgrounds/nix-snowflake-dark-night-transparent.png" ];
  };

  xdg.configFile."Yubico/u2f_keys" = {
    text = ''
    '';
  };

  modules.applications.niri = {
    enable = true;
    outputs = {
        "DP-1" = {
            mode = {
              height = 1440;
              width = 3440;
              refresh = 99.998;
            };
            focus-at-startup = false;
            position.x = 0;
            position.y = 0;
        };
        "DP-2" = {
            mode = {
              height = 1440;
              width = 3440;
              refresh = 120.0;
            };
            focus-at-startup = true;
            position.x = 0;
            position.y = 1440;
        };
    };
  };
}

