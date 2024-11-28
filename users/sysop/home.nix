{ config, pkgs, ... }:

{
  home.username = "sysop";
  home.homeDirectory = "/home/sysop";

  home.packages = with pkgs; [
    go
    hugo
    jetbrains-toolbox
    jetbrains.goland
    jetbrains.pycharm-professional
    libgtop
    youtube-music
    rsstail
    russ
    zscroll
  ];

  home.file.".config/zsh/.zshrc" = {
    text = ''
      eval "$(hugo completion zsh)"
    '';
  };

  programs.hyprstart = {
    enable = true;
    vtnr = 1;
  };

  programs.hyprpaper = {
    enable = true;
    wallpaper = [ "eDP-1,~/Pictures/backgrounds/crinkled-paper.png" ];
  };

  xdg.configFile."Yubico/u2f_keys" = {
    text = ''
    '';
  };

  systemd.user.services = {
    nestops-sysman = {
      Unit = {
        Description = "Serve NestOps System Manual";
      };

      Service = {
        WorkingDirectory = "%h/NestOps/nestops-sysman";
        ExecStart = ''
          ${pkgs.hugo}/bin/hugo server \
            --buildDrafts \
            --buildExpired \
            --buildFuture
        '';
      };
    };
  };

  imports = [
    ../../profiles/base

    ../../git-config.nix
  ];
}

