# macos-defaults/lib.nix
#
# Type constructors for values that cannot be inferred from Nix primitives alone.
# Import this in your home configuration and use in macosDefaults.settings.
#
# Usage:
#   let macosDefaultsLib = import ./modules/darwin/settings/macos-defaults/lib.nix { inherit lib; };
#   ...
#   macosDefaults.settings."com.apple.dock".autohide-delay =
#     macosDefaultsLib.mkFloat 0.2;

{ lib }:

let
  tag = _macosType: value: { inherit _macosType value; };
  ptag = _plistType: value: { inherit _plistType value; };
in
{
  # ---------------------------------------------------------------------------
  # defaults write constructors
  # ---------------------------------------------------------------------------

  # mkFloat :: number → tagged
  # Use when a key strictly requires a float (e.g. animation timings).
  # Nix has no float type; bare numbers become int.
  mkFloat = tag "float";

  # mkArray :: [string] → tagged
  # All elements serialized as strings via defaults write -array.
  # Use mkPlistArray for typed or nested arrays.
  mkArray = tag "array";

  # mkDict :: { string = string; } → tagged
  # Flat string→string only. Nested dicts require mkPlistDict.
  mkDict = tag "dict";

  # ---------------------------------------------------------------------------
  # PlistBuddy constructors
  # ---------------------------------------------------------------------------

  # mkPlistArray :: [a] → tagged
  # Routes this key through PlistBuddy instead of defaults write.
  # Elements may be mkPlistDict, mkPlistArray (nested), or inferred primitives
  # (bool → boolean, int → integer, float → real, string → string).
  # Use for any array that contains dicts, nested arrays, or typed scalars.
  mkPlistArray = tag "plistArray";

  # mkPlistDict :: { string = a; } → tagged
  # Use inside mkPlistArray or nested plist structures.
  # Values follow the same inference rules as mkPlistArray elements.
  mkPlistDict = ptag "dict";

  # Explicit scalar constructors for use inside plist trees.
  # Use when Python type inference would produce the wrong plist type,
  # e.g. mkPlistInt 0 ensures integer rather than boolean false.
  mkPlistInt = ptag "integer";
  mkPlistReal = ptag "real";
  mkPlistBool = ptag "boolean";
  mkPlistString = ptag "string";
}
