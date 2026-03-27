## flake.nix
#
# inputs = {
#     dms.url = "github:AvengeMedia/DankMaterialShell";
#     dms.inputs.nixpkgs.follows = "nixpkgs-unstable";    
# };

{ lib, pkgs, pkgs-unstable, config, inputs, ... }:

{ 
  options.modules.applications.mangowc = {
    enable = lib.mkEnableOption "mangowc";
  };

  imports = [
    inputs.dms.homeModules.dankMaterialShell.default
  ];

  config = lib.mkIf (config.app.niri.enable) {

    home.packages = with pkgs; [
      mangowc
    ];

    programs.dankMaterialShell = {
      enable = true;
      quickshell.package = pkgs-unstable.quickshell;
    };
  };
}
