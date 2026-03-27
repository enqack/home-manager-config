{
  config,
  lib,
  pkgs,
  ...
}:

# Pattern: Configuration DSL → defaults write + manifest diffing
# Problem:  nix-darwin system.defaults is root-scoped; no user-level declarative primitive
# Tradeoff: Manifest diff catches removals, but is blind to out-of-band defaults writes

let
  cfg = config.modules.settings.macos-defaults;

  defaultRestartMap = import ./restartMap.nix;

  mergedRestartMap = lib.recursiveUpdate defaultRestartMap cfg.extraRestartProcesses;

  # Runtime type inference rules:
  #   Nix bool   → -bool
  #   Nix int    → -int
  #   Nix string → -string
  #   { _macosType = "float"|"array"|"dict"; value = ...; } → tagged dispatch
  # Validation is deferred to activate.py; Nix types.anything avoids over-constraining.

  activationPkg = pkgs.writeTextFile {
    name = "macos-defaults-activate";
    executable = true;
    destination = "/bin/macos-defaults-activate";
    text = ''
      #!${pkgs.python3}/bin/python3
      ${builtins.readFile ./activate.py}
    '';
  };

in
{
  imports = [ ];

  options.modules.settings.macos-defaults = {
    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = { };
      description = ''
        Nested attrset: domain → key → value.
        Primitive values (bool, int, string) are inferred automatically.
        Use mkFloat / mkArray / mkDict from macosDefaults.lib for edge cases.
      '';
      example = lib.literalExpression ''
        {
          "com.apple.dock" = {
            autohide       = true;
            autohide-delay = macosDefaultsLib.mkFloat 0.0;
            persistent-apps = macosDefaultsLib.mkArray [];
          };
          "com.apple.finder" = {
            ShowPathbar    = true;
            FXPreferredViewStyle = "Nlsv";
          };
          NSGlobalDomain = {
            AppleShowAllExtensions    = true;
            InitialKeyRepeat          = 15;
            KeyRepeat                 = 2;
          };
        }
      '';
    };

    extraRestartProcesses = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      description = ''
        Merge additional domain → [process] entries into the built-in restart map.
        Processes are sent SIGTERM via killall after activation; failures are non-fatal.
      '';
      example = lib.literalExpression ''
        { "com.example.myapp" = [ "MyApp" ]; }
      '';
    };
  };

  config = lib.mkIf (cfg.settings != { }) {
    home.activation.macosDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${activationPkg}/bin/macos-defaults-activate \
        ${lib.escapeShellArg (builtins.toJSON cfg.settings)} \
        ${lib.escapeShellArg (builtins.toJSON mergedRestartMap)}
    '';
  };
}
