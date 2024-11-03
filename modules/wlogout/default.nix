{ config, lib, pkgs, ... }:
let
  # Read the layout template file
  configTemplate = builtins.readFile ./layout.template;

  # Substitute values by creating the final config file
  configText = pkgs.writeText "layout" (builtins.replaceStrings
    [ "lockCmd" config.wlogout.lockCmd ]
    [ "lockKeybind" config.wlogout.lockKeybind ]
    configTemplate);

  styleTemplate = builtins.readFile ./style.css.template;
in
{
  options.programs.wlogout = {
    enable = lib.mkEnableOption "Enable wlogout";

    lockCmd = lib.mkOption {
      type = lib.types.str;
      default = "hyprlock";
      description = "The command to use for screen locking";
    };

    lockKeybind = lib.mkOption {
      type = lib.types.str;
      default = "l";
      description = "The keybinding to use for screen locking";
    };

    hibernateCmd = lib.mkOption {
      type = lib.types.str;
      default = "systemctl hibernate";
      description = "The command to use for hibernation";
    };

    hibernateKeybind = lib.mkOption {
      type = lib.types.str;
      default = "h";
      description = "The keybinding to use for hibernation";
    };

    logoutCmd = lib.mkOption {
      type = lib.types.str;
      default = "loginctl terminate-user $USER";
      description = "The command to use to logout";
    };

    logoutKeybind = lib.mkOption {
      type = lib.types.str;
      default = "e";
      description = "The keybinding to use to logout";
    };

    shutdownCmd = lib.mkOption {
      type = lib.types.str;
      default = "systemctl poweroff";
      description = "The command to use to shutdown";
    };

    shutdownKeybind = lib.mkOption {
      type = lib.types.str;
      default = "s";
      description = "The keybinding to use to shutdown";
    };

    rebootCmd = lib.mkOption {
      type = lib.types.str;
      default = "systemctl reboot";
      description = "The command to use to reboot";
    };

    rebootKeybind = lib.mkOption {
      type = lib.types.str;
      default = "r";
      description = "The keybinding to use to reboot";
    };
  };

  config = lib.mkIf config.programs.wlogout.enable {
    # Ensure wlogout is available
    home.packages = [ pkgs.wlogout ];

    # Create config file for layout
    home.file.".config/wlogout/layout" = {
        text = configText;
        executable = false;
    };

    # Create config file for styles
    home.file.".config/wlogout/style.css" = {
        text = styleTemplate;
        executable = false;
    };
  };
}
