{ config, pkgs, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.font = wezterm.font_with_fallback {
        -- Primary font family
        "FiraMono Nerd Font",
        -- Fallbacks, optional
        "Noto Color Emoji",
        "Symbols Nerd Font",
        "JetBrains Mono",         -- fallback monospace
      }

      config.font_size = 12.0

      config.use_fancy_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true

      return config
    '';
  };
}
