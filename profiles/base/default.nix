{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  xdg = {
    enable = true;
    autostart.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.sessionVariables = {
    PATH = "$PATH:~/.local/bin";
    BAT_THEME = "twodark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = lib.mkDefault pkgs.xorg.xcursorthemes;
    name = lib.mkDefault "redglass";
    size = lib.mkDefault 64;
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
    enable = false;
    enableSshSupport = true;
    # https://github.com/drduh/config/blob/master/gpg-agent.conf
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = ''
      ttyname $GPG_TTY
    '';
  };

  home.packages = with pkgs; [
    adwaita-qt6
    adwsteamgtk
  ];

  gtk = {
    enable = true;
  };

  qt = {
    enable = true;
  };

  imports = [
    ../../modules/applications/alacritty
    ../../modules/applications/conky
    #../../modules/applications/home-manager
    ../../modules/applications/helix
    #../../modules/applications/hyprland
    ../../modules/applications/swaync
    ../../modules/applications/waybar
    ../../modules/applications/wayfire
    ../../modules/applications/wezterm
    ../../modules/applications/wlogout
    ../../modules/applications/zsh

    ../../modules/applications/niri
    ../../modules/applications/hyprpaper
    ../../modules/applications/hyprstart
    ../../modules/applications/lf

    ../../git-config.nix
  ];

  modules.applications = {
    alacritty.enable = true;
    conky.enable = true;
    helix.enable = true;
    lf.enable = true;
    swaync.enable = true;
    wezterm.enable = true;
    wlogout.enable = true;
    zsh.enable = true;
  };
}

