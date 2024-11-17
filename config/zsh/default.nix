{ config, pkgs, ... }:

{
  programs.zsh = {
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      lt = "ls -ltr";
      l  = "ls -CF";
    };

    history.size = 10000;
    history.path = "$XDG_DATA_HOME/zsh/history";
  };

  home.file = {
    ".config/zsh/.zshrc" = {
       text = "";
       executable = false;
    };
  };

  home.file.".config/zsh/.zprofile" = {
    text = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
          exec Hyprland >/dev/null
      fi      
    '';
    executable = false;
  };
}

