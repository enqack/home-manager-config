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

        url = {
          "git@github.com:" = {
            insteadOf = "https://github.com/";
          };
        };
      };
    };
    delta.enable = true;
  };
}

