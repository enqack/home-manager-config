{ config, pkgs, lib, ... }:

{
  home.username = "sysop";
  home.homeDirectory = "/home/sysop";

  home.stateVersion = "24.05";

  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
  };

  xdg.enable = true;

  programs.zsh = {
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      lt = "ls -ltr";
      l  = "ls -CF";
    };

    history.size = 10000;
    history.path = "$XDG_DATA_HOME/zsh/history";
  };
  home.file = {
    ".config/zsh/.zshrc" = {
       text = "";
       executable = false;
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    git
    go
    htop
    jetbrains-toolbox
    jetbrains.goland
    jetbrains.pycharm-professional
    libgtop
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/Pictures/backgrounds/crinkled-paper.png"
      ];
      wallpaper = [
        "eDP-1,~/Pictures/backgrounds/crinkled-paper.png"
      ];
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        output = "eDP-1";
        font = "DejaVuSansMono Nerd Font:size=18";
        prompt = "'Search Applications: '";
        icons-enabled = false;
        show-actions = true;
        lines = 10;
        width = 30;
      };
      colors = {
        background = "1f1f1fff";
        text = "ffffffff";
        match = "a80301ff";
        selection = "303030ff";
        selection-text = "ffffffff";
        selection-match = "a80301ff";
        border = "a80301ff";
      };
      border = {
        width = 2;
        radius = 20;
      };
    };
  };

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

  programs.alacritty = {
    enable = true;
    settings = {
      bell = {
        animation = "EaseOutExpo";
        color = "#ffffff";
        duration = 1;
      };

      font.size = 16;

      colors = {
        bright = {
          black = "#666666";
          blue = "#3b8eea";
          cyan = "#29b8db";
          green = "#23d18b";
          magenta = "#d670d6";
          red = "#f14c4c";
          white = "#e5e5e5";
          yellow = "#f5f543";
        };
        normal = {
          black = "#000000";
          blue = "#2472c8";
          cyan = "#11a8cd";
          green = "#0dbc79";
          magenta = "#bc3fbc";
          red = "#cd3131";
          white = "#e5e5e5";
          yellow = "#e5e510";
        };
        primary = {
          background = "#000000";
          foreground = "#cccccc";
        };
        selection = {
          background = "#565656";
          text = "CellForeground";
        };
      };

      mouse = {
        hide_when_typing = false;
      };

      window = {
        opacity = 0.8;
      };

      # Optional general settings
      general.live_config_reload = true;
    };
  };

  imports = [
    ./modules/conky
    ./modules/home-manager
    ./modules/hyprland
    ./modules/lf
    ./modules/vim
  ];

}

