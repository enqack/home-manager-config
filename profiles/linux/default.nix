{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../base # base profile

    ../../modules/shared/applications/zsh

    ../../modules/linux/applications/niri
    ../../modules/linux/applications/hyprstart
    ../../modules/linux/applications/conky
    ../../modules/linux/applications/zed-editor
  ];

  xdg = {
    enable = true;
    autostart.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = lib.mkDefault pkgs.xorg.xcursorthemes;
    name = lib.mkDefault "redglass";
    size = lib.mkDefault 64;
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

  modules.applications = {
    zsh.enable = true;
    conky.enable = true;
    zed-editor.enable = true;
  };
}
