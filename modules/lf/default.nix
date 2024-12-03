{ config, pkgs, lib, ... }:

{
  options.applications.lf = {
    enable = lib.mkEnableOption "Install lf.";
  };

  config = lib.mkIf config.applications.lf.enable {
    programs.lf = {
      enable = true;

      settings = {
        shell      = "zsh";
        shellopts  = "-eu";
        ifs        = "\n";
        scrolloff  = 10;
        ratios     = "1:2:3";
        previewer  = "~/.scripts/lf/preview";
        cleaner    = "~/.scripts/lf/cleaner";
        drawbox    = true;
        hidden     = true;
        ignorecase = true;
        dircounts  = true;
      };

      # --- keybindings for built-in commands ---
      keybindings = {
        # remove defaults
        m = null;
        o = null;
        n = null;
        "'" = null;
        "\"" = null;
        d = null;
        c = null;
        e = null;
        f = null;

        # built-in actions
        "." = "set hidden!";
        DD = "delete";
        p  = "paste";
        x  = "cut";
        y  = "copy";
        "<enter>" = "open";
        mf = "mkfile";
        mr = "sudomkfile";
        md = "mkdir";
        ms = "\${mkscript}";
        ch = "chmod";
        br = "\${vimv} \${fx}";
        r = "rename";
        H = "top";
        L = "bottom";
        R = "reload";
        C = "clear";
        U = "unselect";

        # movement
        gh = "cd ~";

        "gc." = "cd ~/.config";
        gbsp = "\${EDITOR} ~/.config/bspwm/bspwmrc";
        gsxk = "\${EDITOR} ~/.config/sxhkd/sxhkdrc";
        gslf = "\${EDITOR} ~/.config/lf/lfrc";

        "gs." = "cd ~/.scripts";

        gd = "cd ~/Documents";
        gD = "cd ~/Downloads";

        gp   = "cd ~/Pictures";
        gps  = "cd ~/Pictures/screenshots";

        gv   = "cd ~/Videos";

        gmnt = "cd /mnt";

        # file openers
        ee = "\${EDITOR} \"\${f}\"";
        u  = "\${view} \"\${f}\"";

        # archive bindings
        az = "zip";
        at = "tar";
        ag = "targz";
        ab = "targz";
        ae = "extract";

        # trash
        dd = "trash";
        tc = "clear_trash";
        tr = "restore_trash";
      };

      extraConfig = lib.fileContents ./extra-config.lfrc;
    };

    environment.systemPackages = with pkgs; [
      ueberzugpp
      ffmpegthumbnailer
      imagemagick
      poppler-utils
    ];
  };
}
