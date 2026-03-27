{ niri, dms, stylix, ... }:

{
  hostList = [
    "catalyst"
    "elysium"
    "flex"
    "forte"
    "grillage"
    "knell"
    "reactor"
    "scalar"
    "tartarus"
    "vector"
  ];

  homes = [
    # sysadm applies to all linux hosts
    {
      user = "sysadm";
      host = "*";
      system = "x86_64-linux";
      extraModules = [
        niri.homeModules.niri
        dms.homeModules.dankMaterialShell.default
        dms.homeModules.dankMaterialShell.niri
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
        dms.homeModules.dankMaterialShell.default
        dms.homeModules.dankMaterialShell.niri
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
