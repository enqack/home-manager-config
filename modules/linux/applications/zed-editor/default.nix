{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.modules.applications.zed-editor.enable = lib.mkEnableOption "zed-editor";

  config = lib.mkIf config.modules.applications.zed-editor.enable {

    targets.genericLinux.nixGL.vulkan.enable = true;

    programs.zed-editor = {
      enable = true;
      package = pkgs.unstable.zed-editor;

      extensions = [
        "nix"
        "tmol"
        "yaml"
        "json"
        "jsonl"
        "go"
        "proto"
        "python"
      ];

      userSettings = {
        auto_update = false;
        theme = {
          mode = "system";
          dark = "One Dark";
          light = "One Light";
        };
        features = {
          copilot = false;
        };

        lsp = {
          nix = {
            binary = {
              path_lookup = true;
            };
          };
        };

      };

    };
  };
}
