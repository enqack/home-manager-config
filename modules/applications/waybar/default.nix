{ config, pkgs, lib, ... }:

{
  options.modules.applications.waybar.enable = lib.mkEnableOption "waybar";

  config = lib.mkIf config.modules.applications.waybar.enable {
    programs.waybar = {
      enable = true;
    };

    home.file.".config/waybar/hypr-config" = {
      text = builtins.readFile ./hypr-config;
      executable = false;
    };

    home.file.".config/waybar/niri-config" = {
      text = builtins.readFile ./niri-config;
      executable = false;
    };

    home.file.".config/waybar/style.css" = {
      text = builtins.readFile ./nightreign-style.css;
      executable = false;
    };
  };
}
