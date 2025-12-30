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
  let
    lib = nixpkgs.lib;

    inventory = import ./homes.nix;
    hostList = inventory.hostList;
    homesRaw = inventory.homes;

    isValidHome = h:
      lib.isAttrs h &&
      lib.hasAttr "user" h && lib.isString h.user &&
      lib.hasAttr "host" h && lib.isString h.host &&
      lib.hasAttr "system" h && lib.isString h.system &&
      lib.hasAttr "extraModules" h && lib.isList h.extraModules &&
      lib.hasAttr "critical" h && lib.isBool h.critical;

      validHomes = lib.filter isValidHome homesRaw;

      expandWildcards = homes:
      lib.concatMap (h:
        if h.host == "*"
        then map (hn: h // { host = hn; }) hostList
        else [ h ]
      ) homes;

    expandedHomes = expandWildcards validHomes;


    homeKey = h: "${h.user}@${h.host}";

    dedupeByKeyPreferLast = list:
      let
        keys = lib.unique (map homeKey list);
      in
        map (k:
          lib.last (lib.filter (h: homeKey h == k) list)
        ) keys;

    allHomes = dedupeByKeyPreferLast expandedHomes;
          
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          (final: prev: {
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ];
      };

    mkHostModule = h:
      let
        path = ./users/${h.user}/hosts/${h.host}.nix;
      in
        if builtins.pathExists path
        then path
        else {};

    mkHome = h:
      let
        pkgs = mkPkgs h.system;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            userName = h.user;
            hostName = h.host;
          };

          modules = [
            # Shared stack (keep your existing behavior)
            niri.homeModules.niri
            dms.homeModules.dankMaterialShell.default
            dms.homeModules.dankMaterialShell.niri
            niri.homeModules.stylix
            stylix.homeModules.stylix

            # User base config
            ./users/${h.user}/home.nix

            # Host-specific overrides (optional)
            (mkHostModule h)

            # Ensure HM knows who/where it is (unless already set)
            {
              home.username = h.user;
              home.homeDirectory = "/home/${h.user}";
            }
          ] ++ h.extraModules;
        };
  in {
    homeConfigurations =
      lib.genAttrs
        (map homeKey allHomes)
        (k:
          let
            h = lib.findFirst (x: homeKey x == k) null allHomes;
          in
            mkHome h
        );
  };
}
