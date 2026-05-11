{ niri, dms, dsearch, stylix, ... }:

{
  linuxHosts = [
    "catalyst"
    "elysium"
    "flex"
    "grillage"
    "knell"
    "reactor"
    "scalar"
    "tartarus"
    "vector"
  ];

  darwinHosts = [
    "forte"
  ];

  homes = [
    # sysadm applies to all linux hosts
    {
      user = "sysadm";
      host = "*";
      system = "x86_64-linux";
      extraModules = [
        niri.homeModules.niri
        dms.homeModules.dank-material-shell
        dms.homeModules.niri
        dsearch.homeModules.dsearch
        niri.homeModules.stylix
        stylix.homeModules.stylix
      ];
      critical = true;
    }

    # sysop applies to all linux hosts
    {
      user = "sysop";
      host = "*";
      system = "x86_64-linux";
      extraModules = [
        niri.homeModules.niri
        dms.homeModules.dank-material-shell
        dms.homeModules.niri
        dsearch.homeModules.dsearch
        niri.homeModules.stylix
        stylix.homeModules.stylix
      ];
      critical = true;
    }

    # sysop applies to all macos hosts
    {
      user = "sysop";
      host = "*";
      system = "aarch64-darwin";
      extraModules = [ ];
      critical = true;
    }
  ];
}
