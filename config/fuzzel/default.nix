{ config, pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        output = "eDP-1";
        font = "JetBrainsMono Nerd Font:size=18";
        prompt = "'Search Applications: '";
        icons-enabled = false;
        show-actions = true;
        lines = 10;
        width = 30;
      };
      colors = {
        background = "1f1f1fff";
        text = "ffffffff";
        match = "1e4620ff";
        selection = "1f1f1fff";
        selection-text = "a80301ff";
        selection-match = "1e4620ff";
        border = "a80301ff";
      };
      border = {
        width = 2;
        radius = 5;
      };
    };
  };
}