{
  hostList = [
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

  homes = [
    # sysadm applies to all hosts
    {
      user = "sysadm";
      host = "*";
      system = "x86_64-linux";
      extraModules = [];
      critical = true;
    }

    # sysop applies to all hosts
    {
      user = "sysop";
      host = "*";
      system = "x86_64-linux";
      extraModules = [];
      critical = true;
    }
  ];
}

