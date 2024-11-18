{ config, pkgs, lib, ... }:

{
  options.programs.hyprstart = {
    enable = lib.mkEnableOption "Enable hyprstart";

    vtnr = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "The XDG virtual terminal number to use for the compositor";
    };

    compositor = lib.mkOption {
      type = lib.types.str;
      default = "Hyprland";
      description = "The compositor to use";
    };
  };

  config = lib.mkIf config.programs.hyprstart.enable {
    home.file.".config/zsh/.zprofile" = {
      text = ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq ${builtins.toString(config.programs.hyprstart.vtnr)} ]; then
            exec ${config.programs.hyprstart.compositor} >/dev/null
        fi      
      '';
      executable = false;
    };
  };
}

