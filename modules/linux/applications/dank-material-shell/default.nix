{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.modules.applications.dank-material-shell;
in

{
  options.modules.applications.dank-material-shell = {
    enable = lib.mkEnableOption "dank-material-shell";
  };

  config = lib.mkIf (cfg.enable) {
    home.packages = with pkgs; [
      qt6Packages.qt6ct
      matugen
      linux-wallpaperengine
    ];

    programs.dank-material-shell = {
      enable = true;
      dgop.package = inputs.dgop.packages.x86_64-linux.dgop;

      settings = {
        theme = "blue";
        matugenScheme = "scheme-monochrome";
        runUserMatugenTemplates = true;
        widgetColorMode = "colorful";
        useFahrenheit = true;
        dynamicTheming = true;

        showWorkspaceIndex = true;
        launcherLogoMode = "os";
        launcherLogoCustomPath = "";
        launcherLogoColorOverride = "surface";
        launcherLogoColorInvertOnMode = false;
        launcherLogoBrightness = 0.5;
        launcherLogoContrast = 1;
        launcherLogoSizeOffset = 0;

        barConfigs = [
          {
            id = "default";
            name = "Top";
            enabled = true;
            position = 0;
            screenPreferences = [
              "all"
            ];
            showOnLastDisplay = true;
            leftWidgets = [
              {
                id = "launcherButton";
                enabled = true;
              }
              {
                id = "workspaceSwitcher";
                enabled = true;
              }
              {
                id = "focusedWindow";
                enabled = true;
                focusedWindowCompactMode = false;
              }
            ];
            centerWidgets = [
              {
                id = "music";
                enabled = true;
              }
              {
                id = "clock";
                enabled = true;
              }
              {
                id = "weather";
                enabled = true;
              }
            ];
            rightWidgets = [
              {
                id = "controlCenterButton";
                enabled = true;
              }
              {
                id = "powerMenuButton";
                enabled = true;
              }
            ];
            spacing = 12;
            innerPadding = 4;
            bottomGap = 0;
            transparency = 0.7;
            widgetTransparency = 1;
            squareCorners = false;
            noBackground = false;
            gothCornersEnabled = true;
            gothCornerRadiusOverride = true;
            gothCornerRadiusValue = 16;
          }
          {
            id = "bottom";
            name = "Bottom";
            enabled = true;
            position = 1;
            screenPreferences = [
              {
                name = "DP-5";
              }
            ];
            showOnLastDisplay = false;
            leftWidgets = [
              {
                id = "userathost";
                enabled = true;
              }
            ];
            centerWidgets = [
              {
                id = "dankcommandticker";
                enabled = true;
              }
            ];
            rightWidgets = [
              {
                id = "cpuUsage";
                enabled = true;
                minimumWidth = true;
              }
            ];
            spacing = 12;
            innerPadding = 4;
            bottomGap = 0;
            transparency = 0.7;
            widgetTransparency = 1;
            squareCorners = false;
            noBackground = false;
            gothCornersEnabled = true;
            gothCornerRadiusOverride = true;
            gothCornerRadiusValue = 16;
          }
        ];

      };

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableSystemMonitoring = true;
      enableVPN = true;
      #enableClipboard = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;

      plugins = {
        userathost = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "enqack";
            repo = "dms-plugin-userathost";
            rev = "v0.1.0";
            sha256 = "sha256-96ckrhf0KjiavEWaZCDXAdMFX14Af5F03Rn0vnSZSxI=";
          };
        };
        dankcommandticker = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "enqack";
            repo = "dms-plugin-dankcommandticker";
            rev = "v0.1.0";
            sha256 = "sha256-Ijvu5OYGB1TvElkIcC1659KFBTu/BqUGvGaSoPReVpA=";
          };
        };
      };
    };

    programs.dsearch = {
      enable = true;
      config = { };
    };

  };
}
