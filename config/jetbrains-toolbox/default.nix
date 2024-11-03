{ pkgs, lib, config, ... }:

let
  # Define JetBrains Toolbox as a package derivation
  jetbrainsToolbox = pkgs.stdenv.mkDerivation {
    name = "jetbrains-toolbox";
    src = pkgs.fetchurl {
      url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.1.34629.tar.gz";
      sha256 = "a082bb0a0f3d51240ad7cb64c9fe6492cfd17dc22c7cc17695a66f8beaaef6d6";
    };

    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      tar -xzf $src --strip-components=1 -C $out/bin
    '';
  };
in

{
  # Module options
  options.jetbrainsToolbox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the JetBrains Toolbox app to manage JetBrains IDEs.";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      # default = "/home/${config.users.users.your_username.name}/.local/share/JetBrainsToolbox";
      default = "${config.home.homeDirectory}/.local/share/JetBrainsToolbox";
      description = "Directory for JetBrains Toolbox data.";
    };
  };

  # Configuration block
  config = lib.mkIf config.jetbrainsToolbox.enable {
    home.packages = [
      jetbrainsToolbox
    ];

    home.file."${config.jetbrainsToolbox.dataDir}/jetbrains-toolbox" = {
      source = "${pkgs.writeShellScript "jetbrains-toolbox-launcher" ''
        #!/bin/sh
        ${jetbrainsToolbox}/bin/jetbrains-toolbox
      ''}";
      executable = true;
    };
  };
}

