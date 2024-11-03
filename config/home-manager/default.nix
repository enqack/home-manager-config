{ config, pkgs, lib, ... }:

{
  systemd.user = {
    services.home-manager-rebuild = {
      Unit = {
        Description = "Rebuild Home Manager Configuration";
        Requires = [ "dbus.service" ];
        After = [ "dbus.service" ];
      };
      Service = {
        Type = "oneshot";
        Environment = "PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin";
        #ExecStartPre = "${pkgs.libnotify}/bin/notify-send 'Home Manager' 'Starting Rebuild'";
        ExecStart = "${pkgs.home-manager}/bin/home-manager switch --flake .config/home-manager";
        #ExecStartPost = "${pkgs.libnotify}/bin/notify-send 'Home Manager' 'Rebuild Complete'";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    timers.home-manager-rebuild-timer = {
      Unit = {
        Description = "Hourly Timer for Home Manager Rebuild";
      };
      Timer = {
        OnCalendar = "hourly";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}

