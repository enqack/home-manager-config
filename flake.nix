{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager?ref=release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix/release-25.11"; 
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    dms.inputs.nixpkgs.follows = "nixpkgs";

    dgop.url = "github:AvengeMedia/dgop";
    dgop.inputs.nixpkgs.follows = "nixpkgs";

    awelauncher.url = "github:enqack/awelauncher";
    awelauncher.inputs.nixpkgs.follows = "nixpkgs";    
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, home-manager, stylix, niri, dms, dgop, awelauncher, ... }:

  rec {
    # Define the Home Manager configuration for the users
    homeConfigurations = {
        
      sysadm = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            (self: super: { legacyPackages.x86_64-linux = super.x86_64-linux; })
          ];
          config = { 
            allowUnfree = true;
          };
        };

        modules = [
          stylix.homeModules.stylix
          ./users/sysadm/home.nix
        ];
      };

      sysop = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            (self: super: { legacyPackages.x86_64-linux = super.x86_64-linux; })
            niri.overlays.niri
          ];

          config = { 
            allowUnfree = true;
          };
        };

        extraSpecialArgs = {
          inherit inputs;
          pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };

        modules = [
          niri.homeModules.niri
          dms.homeModules.dankMaterialShell.default
          dms.homeModules.dankMaterialShell.niri
          niri.homeModules.stylix
          stylix.homeModules.stylix
          ./users/sysop/home.nix
        ];

      };
    };
  };
}
