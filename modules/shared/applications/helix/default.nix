{ config, pkgs, lib, ... }:

{
  options.modules.applications.helix.enable = lib.mkEnableOption "helix";

  config = lib.mkIf config.modules.applications.helix.enable {
    programs.helix = {
      enable = true;
      settings = {
          theme = "base16_default";
      };
    };
  };
}
