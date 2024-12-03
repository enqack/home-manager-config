{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;
  
  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
    BAT_THEME = "twodark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.xorg.xcursorthemes;
    name = "redglass";
    size = 64;
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  
    # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
    scdaemonSettings = {
      disable-ccid = true;
      reader-port = "Yubico Yubi";
    };
  
    # https://github.com/drduh/config/blob/master/gpg.conf
    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      no-symkey-cache = true;
      use-agent = true;
      throw-keyids = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # https://github.com/drduh/config/blob/master/gpg-agent.conf
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentryPackage = pkgs.pinentry-tty;
    extraConfig = ''
      ttyname $GPG_TTY
    '';
  };

  imports = [
    ../../config/alacritty
    ../../config/conky
    ../../config/fuzzel
    ../../config/home-manager
    ../../config/hyprland
    ../../config/lf
    ../../config/swaync
    ../../config/waybar
    ../../config/wezterm
    ../../config/wlogout
    ../../config/zsh

    ../../modules/hyprpaper
    ../../modules/hyprstart

    ../../git-config.nix
  ];
}

