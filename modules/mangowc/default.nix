{ pkgs, pkgs-unstable, config, inputs, ... }:

{ 
  options.app.mangowc.enable = lib.mkEnableOption "mangowc";

  inputs = {
    dms.url = "github:AvengeMedia/DankMaterialShell";
    dms.inputs.nixpkgs.follows = "nixpkgs";    
  };
  
  config = lib.mkIf (config.app.niri.enable) {

  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.mangowc
  ];

    home.packages = with pkgs; [
      mangowc
    ];

    programs.dankMaterialShell = {
        enable = true;
        quickshell.package = pkgs-unstable.quickshell;
    };
  };
}