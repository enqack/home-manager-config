# home.nix — usage example for macosDefaults
#
# Wire the module in your home-manager flake:
#
#   home-manager.users.<you> = { pkgs, lib, ... }: {
#     imports = [ .../modules/darwin/settings/macos-defaults ];
#     ...
#   };

{ pkgs, lib, ... }:

let
  macosDefaultsLib = import .../modules/darwin/settings/macos-defaults/lib.nix { inherit lib; };
in
{
  imports = [ .../modules/darwin/settings/macos-defaults ];

  modules.settings.macos-defaults.settings = {
    "com.apple.dock" = {
      autohide = true;
      autohide-delay = macosDefaultsLib.mkFloat 0.0;
      show-recents = false;
      tilesize = 48;

      # PlistBuddy path — used because persistent-apps is an array of dicts.
      # defaults write cannot serialize nested typed structures.
      # Each entry must have tile-data.file-data._CFURLString pointing to the .app bundle.
      persistent-apps = macosDefaultsLib.mkPlistArray [
        (macosDefaultsLib.mkPlistDict {
          tile-data = macosDefaultsLib.mkPlistDict {
            file-label = "Finder";
            file-data = macosDefaultsLib.mkPlistDict {
              _CFURLString = "/System/Library/CoreServices/Finder.app";
              _CFURLStringType = macosDefaultsLib.mkPlistInt 0;
            };
          };
        })
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
            file-label = "Terminal";
            file-data = macosDefaultsLib.mkPlistDict {
              _CFURLString = "/System/Applications/Utilities/Terminal.app";
              _CFURLStringType = macosDefaultsLib.mkPlistInt 0;
            };
          };
        })
      ];
    };

    "com.apple.finder" = {
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Clmv"; # column view
      FXDefaultSearchScope = "SCcf"; # search current folder
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Optional: add restart entry for a 3rd-party app domain
  macosDefaults.extraRestartProcesses = {
    "com.apple.finder" = [
      "Finder"
      "cfprefsd"
    ];
  };
}
