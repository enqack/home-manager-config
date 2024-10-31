{ config, pkgs, ... }:

{
  home.packages = [ pkgs.vim ];

  home.file.".config/vim/vimrc" = {
    text = builtins.readFile ./vimrc;
    executable = false;
  };
}

