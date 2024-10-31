{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # Specify the branch

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = { home-manager, nixpkgs, hyprpanel, ... }: rec {
    # Define the Home Manager configuration for the user
    homeConfigurations = {
      sysop = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";  # Specify the system
          overlays = [
            (self: super: { legacyPackages.x86_64-linux = super.x86_64-linux; })
            hyprpanel.overlay
          ];
          config = { allowUnfree = true; };
        };

        modules = [
          ./home.nix
        ];
      };
    };

    # Provide an activation package for easy access
    defaultPackage.x86_64-linux = homeConfigurations.sysop.activationPackage;

    # Define the default app as the activation script
    defaultApp.x86_64-linux = {
      type = "app";
      program = "${homeConfigurations.sysop.activationPackage}/activate";
      args = [];
    };
  };
}

