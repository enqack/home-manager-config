{ lib, pkgs, ... }:

let
  macosDefaultsLib = import ../../../modules/darwin/settings/macos-defaults/lib.nix { inherit lib; };
in

{
  imports = [
    ../../../profiles/darwin

    ../../../git-config.nix
  ];

  home.username = "sysop";
  home.homeDirectory = "/Users/sysop";

  home.packages = with pkgs; [
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
    jetbrains.goland
    jetbrains.pycharm
    libgtop
    obsidian
    youtube-music
    rsstail
    russ
    tytools
  ];

  modules.settings.macos-defaults.settings = {
    "com.apple.dock" = {
      autohide = true;
      autohide-delay = macosDefaultsLib.mkFloat 0.0;
      show-recents = false;
      tilesize = 48;
      orientation = "left";

      persistent-apps = macosDefaultsLib.mkPlistArray [
        (macosDefaultsLib.mkPlistDict {
          tile-data = macosDefaultsLib.mkPlistDict {
            file-label = "Studio One 6";
            file-data = macosDefaultsLib.mkPlistDict {
              _CFURLString = "/Applications/Studio One 6.app";
              _CFURLStringType = macosDefaultsLib.mkPlistInt 0;
            };
          };
        })
        (macosDefaultsLib.mkPlistDict {
          tile-data = macosDefaultsLib.mkPlistDict {
            file-label = "Obsidian";
            file-data = macosDefaultsLib.mkPlistDict {
              _CFURLString = "${pkgs.obsidian}/Applications/Obsidian.app";
              _CFURLStringType = macosDefaultsLib.mkPlistInt 0;
            };
          };
        })
        (macosDefaultsLib.mkPlistDict {
          tile-data = macosDefaultsLib.mkPlistDict {
            file-label = "Zettlr";
            file-data = macosDefaultsLib.mkPlistDict {
              _CFURLString = "/Applications/Zettlr.app";
              _CFURLStringType = macosDefaultsLib.mkPlistInt 0;
            };
          };
        })
      ];

    };
  };

}
