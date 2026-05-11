{ config, pkgs, lib, ... }:

{
  options.modules.applications.zed-editor.enable = lib.mkEnableOption "zed-editor";

  config = lib.mkIf config.modules.applications.zed-editor.enable {

    targets.genericLinux.nixGL.vulkan.enable = true;

    programs.zed-editor = {
      enable = true;
      package = pkgs.unstable.zed-editor;
      
      extensions = [ "nix" "tmol" "yaml" "json" "jsonl" "go" "python" ];
      userSettings = {
        theme = {
          mode = "system";
          dark = "One Dark";
          light = "One Light";
        };
      };
    };

  };
}
