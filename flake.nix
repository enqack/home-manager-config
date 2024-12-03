{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = { home-manager, nixpkgs, hyprpanel, ... }:
  rec {
    # Define the Home Manager configuration for the user
    homeConfigurations = {
      sysadm = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            (self: super: { legacyPackages.x86_64-linux = super.x86_64-linux; })
            hyprpanel.overlay
          ];
          config = { allowUnfree = true; };
        };

        modules = [
          ./users/sysadm/home.nix
        ];
      };
      sysop = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            (self: super: { legacyPackages.x86_64-linux = super.x86_64-linux; })
            hyprpanel.overlay
          ];
          config = { allowUnfree = true; };
        };

        modules = [
          ./users/sysop/home.nix
        ];
      };
    };
  };
}

