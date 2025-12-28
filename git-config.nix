{ config, pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "enqack";
          email = "enqack@gmail.com";
        };
      };
    };
    delta.enable = true;
  };
}

