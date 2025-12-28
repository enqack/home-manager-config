{ config, pkgs, lib, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        output = "eDP-1";
        font = lib.mkDefault "JetBrainsMono Nerd Font:size=18";
        prompt = "'Search Applications: '";
        icons-enabled = false;
        show-actions = true;
        lines = 10;
        width = 30;
      };
      colors = {
        background = lib.mkDefault "1f1f1fff";
        text = lib.mkDefault "ffffffff";
        match = lib.mkDefault "1e4620ff";
        selection = lib.mkDefault "1f1f1fff";
        selection-text = lib.mkDefault "a80301ff";
        selection-match = lib.mkDefault "1e4620ff";
        border = lib.mkDefault "a80301ff";
      };
      border = {
        width = 2;
        radius = 5;
      };
    };
  };
}