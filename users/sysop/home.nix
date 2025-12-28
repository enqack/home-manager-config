{ lib, pkgs, config, inputs, ... }:

{
  imports = [
    ../../profiles/base

    ../../modules/niri

    ../../git-config.nix
  ];

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/shades-of-purple.yaml";
    opacity.terminal = 0.8;
    image = ./synthwave-crinkled-paper.png;
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

  home.username = "sysop";
  home.homeDirectory = "/home/sysop";

  home.packages = with pkgs; [
    base16-schemes
    antigravity
    typos-lsp
    # c dev
    clang
    clang-analyzer
    clang-tools
    cmake
    cpm-cmake
    pkg-config
    ninja
    ## X11
    xorg.libX11.dev
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXext
    xorg.libXcursor
    fontconfig

    webkitgtk_4_1
    ##/ X11
    #/ c dev

    # rust dev
    rustc
    cargo
    #/ rust dev

    # py dev
    ruff
    ty
    uv
    #/ py dev

    faircamp
    go
    gopls
    hugo
    inkscape
    jetbrains-toolbox
    jetbrains.clion
    jetbrains.dataspell
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.rust-rover
    jetbrains.webstorm
    libgtop
    obsidian
    youtube-music
    streamdeck-ui
    rsstail
    russ
    zscroll
    tytools
    terminator

    inputs.dms.packages.x86_64-linux.dms-shell
    inputs.dgop.packages.x86_64-linux.dgop
    inputs.awelauncher.packages.x86_64-linux.awelauncher
    matugen
    quickshell
    linux-wallpaperengine
  ];

  home.file.".config/zsh/.zshrc" = {
    text = ''
      eval "$(hugo completion zsh)"
    '';
  };

  programs.hyprstart = {
    enable = true;
    vtnr = 1;
    compositor = "niri-session -l";
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

  xdg.configFile."wofi/style.css".text = ''
    /* Global window */
    window {
      background: rgba(20, 20, 20, 0.88);
      border-radius: 10px;
      border: 2px solid #6943ff;
      padding: 6px;
      width: 350px;
      max-height: 500px;
    }

    /* Prompt area */
    #input {
      margin: 6px;
      padding: 10px;
      font-size: 1.2em;
      font-family: "FiraCode Nerd Font";
      color: #ffffff;
      border-radius: 6px;
      border: 1px solid #5352ed;
    }

    /* Results list */
    #inner-box {
      margin-top: 4px;
    }

    #entry {
      padding: 8px 10px;
      font-size: 1.1em;
      font-family: "FiraCode Nerd Font";
      color: #e0e0e0;
    }

    #entry:selected {
      background-color: #6943ff;
      color: #ffffff;
    }

    /* Icons */
    icon {
      margin-right: 10px;
    }


  '';

  systemd.user.services = {
    enqack-net-dev = {
      Unit = {
        Description = "Serve enqack.net hugo development environment";
      };

      Install = {
        WantedBy = [ "multi-user.target" ];
      };

      Service = {
        WorkingDirectory = "%h/Projects/enqack-website";
        ExecStart = ''
          ${pkgs.hugo}/bin/hugo server \
            --buildDrafts \
            --buildExpired \
            --buildFuture
        '';
      };
    };
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

  app.niri.enable = true;
}

