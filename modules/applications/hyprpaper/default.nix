{ config, pkgs, lib, ... }:

{
  options.modules.applications.hyprpaper = {
    enable = lib.mkEnableOption "Enable hyprpaper";

    wallpaper = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "DP-1,~/Pictures/backgrounds/crinkled-paper.png" ];
      description = "The monitor and location of the background images to use";
    };
  };

  config = lib.mkIf config.modules.applications.hyprpaper.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        # get first list element of each wallpaper string element; the monitor sub-string
        preload = map (w: builtins.elemAt (lib.strings.splitString "," w) 1) config.modules.applications.hyprpaper.wallpaper;
        wallpaper = config.modules.applications.hyprpaper.wallpaper;
      };
    };
  };
}
