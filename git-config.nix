{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "enqack@gmail.com";
    userName = "enqack";
    delta.enable = true;
  };
}

