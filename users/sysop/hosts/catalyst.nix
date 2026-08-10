{ pkgs, config, inputs, ... }:
let
  wrapJetBrains = import ../../../pkgs/wrap-jetbrains { inherit pkgs; };
in
{
  imports = [
    ../../../profiles/linux

    ../../../git-config.nix

    inputs.cognosis.homeManagerModules.default
    inputs.analytica.homeManagerModules.default  
  ];

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/shades-of-purple.yaml";
    opacity.terminal = 0.8;
    image = ../pictures/synthwave-crinkled-paper.png;
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

    unstable.antigravity-cli
    unstable.antigravity-ide-fhs

    unstable.claude-code
    claude-monitor    

    typos-lsp
    inputs.claude-desktop.packages.x86_64-linux.claude-desktop-fhs
    config.services.cognosis.package
    # psql/pg_dump/pg_restore matching the cognosis-postgres cluster
    config.services.cognosis.provisionPostgres.package

    nodejs

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
    rust-analyzer
    #/ rust dev

    # py dev
    ruff
    ty
    uv
    pyright
    #/ py dev

    unstable.bitwig-studio6

    discord
    faircamp
    go
    gopls
    hugo
    inkscape
    jetbrains-toolbox
    (wrapJetBrains unstable.jetbrains.idea)
    (wrapJetBrains unstable.jetbrains.clion)
    (wrapJetBrains jetbrains.dataspell)
    (wrapJetBrains jetbrains.datagrip)
    (wrapJetBrains unstable.jetbrains.goland)
    (wrapJetBrains unstable.jetbrains.pycharm)
    (wrapJetBrains jetbrains.rider)
    (wrapJetBrains jetbrains.rust-rover)
    (wrapJetBrains jetbrains.webstorm)
    libgtop
    obsidian
    youtube-music
    streamdeck-ui
    rsstail
    russ
    zscroll
    tytools
  ];

  programs.vscode.package = pkgs.vscode.fhsWithPackages (
    ps: with ps; [
      gcc
      gopls
    ]
  );

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  
  services.cognosis = {
    enable = true;

    # Postgres 16 + pgvector as a launchd user agent: socket-only, trust
    # auth in the 0700 data dir at $XDG_STATE_HOME/cognosis/pg, initdb on
    # first boot, COGNOSIS_DSN defaulted to the socket. Same cluster the
    # previously hand-rolled agent ran, now owned by the flake module.
    provisionPostgres.enable = true;

    environment = {
      COGNOSIS_EMBEDDING_URL = "http://127.0.0.1:11434";
    };
  };

  programs.analytics-mcp = {
    enable = true;
  };
  
  home.file.".config/zsh/.zshrc" = {
    text = ''
      eval "$(hugo completion zsh)"
    '';
  };

  modules.applications.hyprstart = {
    enable = true;
    vtnr = 2;
    compositor = "niri-session -l";
  };

  xdg.configFile."Yubico/u2f_keys" = {
    text = "";
  };

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

  modules.applications.niri = {
    enable = true;
    outputs = {
      "DP-2" = {
        mode = {
          height = 1440;
          width = 3440;
          refresh = 99.998;
        };
        focus-at-startup = false;
        position.x = 0;
        position.y = 0;
      };
      "HDMI-A-2" = {
        mode = {
          height = 1440;
          width = 3440;
          refresh = 100.002;
        };
        focus-at-startup = true;
        position.x = 0;
        position.y = 1440;
      };
    };
  };

  modules.applications.mangowm = {
    enable = false;
  };

  modules.applications.dank-material-shell = {
    enable = true;
  };

  modules.applications.paseo = {
    enable = true;
    

    # The daemon runs with a pinned PATH and does not inherit the login
    # shell's, so an agent CLI that is not listed here reports "unavailable"
    # in `paseo provider ls` and in the GUI - even though it is installed
    # above and works fine in a terminal.
    agentPackages = [ pkgs.unstable.claude-code ];

    # All speech on-device. No key material, so no environmentFile needed;
    # the ONNX models download once at daemon startup into modelsDir.
    voice = {
      dictation.stt = {
        provider = "local";
        model = "parakeet-tdt-0.6b-v2-int8";
      };

      voiceMode = {
        # Reuses the claude-code CLI already listed in agentPackages. A
        # provider the daemon cannot execute is unusable here too.
        llm = {
          provider = "claude";
          model = "haiku";
        };

        stt = {
          provider = "local";
          model = "parakeet-tdt-0.6b-v2-int8";
        };

        tts = {
          provider = "local";
          model = "kokoro-en-v0_19";
          speakerId = 0;
        };
      };

      providers.local.modelsDir = "${config.home.homeDirectory}/.paseo/models/local-speech";
    };
  };
}
