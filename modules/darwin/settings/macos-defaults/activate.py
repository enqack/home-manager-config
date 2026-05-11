"""
macosDefaults activation script.

argv[1]: JSON-encoded settings  { domain: { key: value } }
argv[2]: JSON-encoded restartMap { domain: [process] }

Dispatch rules per key value:
  { "_macosType": "plistArray", ... }  → PlistBuddy   (/usr/libexec/PlistBuddy)
  everything else                       → defaults write

Manifest lives at MANIFEST_PATH. On each run:
  1. Load old manifest (empty dict if first run).
  2. Delete keys present in old but absent in new (dispatch-aware).
  3. Write all keys in new settings (dispatch-aware).
  4. Persist new manifest.
  5. killall any processes mapped to touched domains.

Exit codes:
  0  success
  1  argument error
  2  defaults write/delete failure (PlistBuddy write failures also exit 2)
"""

import json
import os
import subprocess
import sys

MANIFEST_PATH = os.path.expanduser(
    "~/.local/state/home-manager/macos-defaults-manifest.json"
)

# Absolute paths required — Nix activation environment does not include
# /usr/bin or /bin on PATH.
PLISTBUDDY = "/usr/libexec/PlistBuddy"
DEFAULTS = "/usr/bin/defaults"
KILLALL = "/usr/bin/killall"


# ---------------------------------------------------------------------------
# defaults write — type dispatch
# ---------------------------------------------------------------------------


def _infer(raw):
    """
    Returns (type_str, value) from a raw Python value.
    Tagged form: { "_macosType": "float"|"array"|"dict", "value": ... }
    Inferred: bool → "bool", int → "int", str → "string"
    Raises TypeError for plistArray (caller must check _is_plist_routed first).
    """
    if isinstance(raw, dict) and "_macosType" in raw:
        t = raw["_macosType"]
        if t == "plistArray":
            raise TypeError(
                "plistArray must be dispatched via PlistBuddy, not defaults write"
            )
        if t not in ("float", "array", "dict"):
            raise TypeError(f"Unknown _macosType: {t!r}")
        return t, raw["value"]

    # bool must precede int — bool is a subclass of int in Python.
    if isinstance(raw, bool):
        return "bool", raw
    if isinstance(raw, int):
        return "int", raw
    if isinstance(raw, str):
        return "string", raw

    raise TypeError(
        f"Cannot infer defaults type for value: {raw!r} ({type(raw).__name__})"
    )


def _build_args(type_str, value):
    """Produces the trailing argv fragment for `defaults write domain key ...`"""
    if type_str == "bool":
        return ["-bool", "TRUE" if value else "FALSE"]
    if type_str == "int":
        return ["-int", str(value)]
    if type_str == "float":
        return ["-float", str(value)]
    if type_str == "string":
        return ["-string", str(value)]
    if type_str == "array":
        if not isinstance(value, list):
            raise TypeError(f"array value must be a list, got {type(value).__name__}")
        return ["-array"] + [str(v) for v in value]
    if type_str == "dict":
        if not isinstance(value, dict):
            raise TypeError(f"dict value must be a dict, got {type(value).__name__}")
        args = ["-dict"]
        for k, v in value.items():
            args += [str(k), str(v)]
        return args
    raise TypeError(f"Unhandled type_str: {type_str!r}")


# ---------------------------------------------------------------------------
# PlistBuddy — type dispatch
# ---------------------------------------------------------------------------


def _is_plist_routed(raw):
    """True iff this key must be handled via PlistBuddy."""
    return isinstance(raw, dict) and raw.get("_macosType") == "plistArray"


def _plist_path(domain):
    return os.path.expanduser(f"~/Library/Preferences/{domain}.plist")


def _plist_scalar_str(type_str, value):
    """Format a scalar value for embedding in a PlistBuddy Add command string."""
    if type_str == "boolean":
        return "true" if value else "false"
    return str(value)


def _plist_commands(path, raw):
    """
    Recursively generate PlistBuddy Add command strings for a keypath.

    path    PlistBuddy keypath, e.g. ":persistent-apps" or ":persistent-apps:0:tile-data"
    raw     One of:
              bool / int / float / str
                → inferred scalar (boolean / integer / real / string)
              { "_macosType": "plistArray", "value": [...] }
                → top-level dispatch; treated as array
              { "_plistType": "dict",    "value": { key: raw } }
                → nested dict
              { "_plistType": "array",   "value": [raw, ...] }
                → nested array
              { "_plistType": "integer" | "real" | "boolean" | "string", "value": ... }
                → explicit scalar (use when Python inference would be wrong)

    NOTE: PlistBuddy receives each command as a separate -c argument (no shell
    expansion). Values containing spaces are safe. Values containing single
    quotes would break the command string; that is a known limitation.
    """
    cmds = []

    if isinstance(raw, dict) and raw.get("_macosType") == "plistArray":
        cmds.append(f"Add {path} array")
        for i, item in enumerate(raw["value"]):
            cmds.extend(_plist_commands(f"{path}:{i}", item))

    elif isinstance(raw, dict) and "_plistType" in raw:
        t = raw["_plistType"]
        v = raw["value"]
        if t == "dict":
            cmds.append(f"Add {path} dict")
            for k, item in v.items():
                cmds.extend(_plist_commands(f"{path}:{k}", item))
        elif t == "array":
            cmds.append(f"Add {path} array")
            for i, item in enumerate(v):
                cmds.extend(_plist_commands(f"{path}:{i}", item))
        elif t in ("integer", "real", "boolean", "string"):
            cmds.append(f"Add {path} {t} {_plist_scalar_str(t, v)}")
        else:
            raise TypeError(f"Unknown _plistType: {t!r}")

    elif isinstance(raw, bool):
        cmds.append(f"Add {path} boolean {'true' if raw else 'false'}")
    elif isinstance(raw, int):
        cmds.append(f"Add {path} integer {raw}")
    elif isinstance(raw, float):
        cmds.append(f"Add {path} real {raw}")
    elif isinstance(raw, str):
        cmds.append(f"Add {path} string {raw}")
    else:
        raise TypeError(f"Cannot serialize plist value at {path!r}: {raw!r}")

    return cmds


def _run_plistbuddy(plist_path, commands, tolerant=False):
    """
    Execute PlistBuddy with a list of command strings against plist_path.
    Each command is passed as a separate -c argument; no shell quoting needed.
    tolerant=True: non-zero exit is a warning; used for speculative Deletes.
    """
    args = [PLISTBUDDY]
    for cmd in commands:
        args += ["-c", cmd]
    args.append(plist_path)

    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        msg = result.stderr.strip() or result.stdout.strip()
        if tolerant:
            print(f"  WARN: PlistBuddy ({plist_path}): {msg}", file=sys.stderr)
        else:
            print(f"ERROR: PlistBuddy ({plist_path})\n  {msg}", file=sys.stderr)
            sys.exit(2)


def _ensure_plist_exists(plist_path):
    """
    Create an empty dict plist at plist_path if it does not already exist.
    Required because PlistBuddy's implicit creation behavior varies across
    macOS versions; explicit initialization is safer.
    ~/Library/Preferences is assumed to exist — it is always present on macOS.
    """
    if not os.path.exists(plist_path):
        _run_plistbuddy(plist_path, ["Add : dict"])


def write_plist_key(domain, key, raw):
    plist = _plist_path(domain)
    _ensure_plist_exists(plist)
    _run_plistbuddy(plist, [f"Delete :{key}"], tolerant=True)
    cmds = _plist_commands(f":{key}", raw)
    _run_plistbuddy(plist, cmds, tolerant=True)


def delete_plist_key(domain, key):
    plist = _plist_path(domain)
    _run_plistbuddy(plist, [f"Delete :{key}"], tolerant=True)


# ---------------------------------------------------------------------------
# defaults write / delete — shell dispatch
# ---------------------------------------------------------------------------


def _run(cmd, tolerant=False):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        msg = result.stderr.strip() or result.stdout.strip()
        if tolerant:
            print(f"  WARN: {' '.join(cmd)}: {msg}", file=sys.stderr)
        else:
            print(f"ERROR: {' '.join(cmd)}\n  {msg}", file=sys.stderr)
            sys.exit(2)


def delete_removed(old, new):
    """
    Delete keys present in old manifest but absent in new settings.
    Route to PlistBuddy if the old value was plist-typed.
    """
    for domain, keys in old.items():
        for key, old_val in keys.items():
            if domain not in new or key not in new[domain]:
                if _is_plist_routed(old_val):
                    print(f"  plistbuddy delete  {domain} :{key}")
                    delete_plist_key(domain, key)
                else:
                    print(f"  defaults delete    {domain} {key}")
                    _run([DEFAULTS, "delete", domain, key], tolerant=True)


def write_settings(new):
    for domain, keys in new.items():
        for key, raw in keys.items():
            if _is_plist_routed(raw):
                print(f"  plistbuddy write   {domain} :{key}")
                write_plist_key(domain, key, raw)
            else:
                try:
                    type_str, value = _infer(raw)
                    args = _build_args(type_str, value)
                except TypeError as e:
                    print(f"ERROR: {domain} {key}: {e}", file=sys.stderr)
                    sys.exit(2)
                print(f"  defaults write     {domain} {key} ({type_str})")
                _run([DEFAULTS, "write", domain, key] + args)


# ---------------------------------------------------------------------------
# Process restart
# ---------------------------------------------------------------------------


def restart_processes(new, restart_map):
    to_restart = set()
    for domain in new:
        for proc in restart_map.get(domain, []):
            to_restart.add(proc)
    for proc in sorted(to_restart):
        print(f"  killall {proc}")
        # Non-fatal: process may not be running.
        subprocess.run([KILLALL, proc], capture_output=True)


# ---------------------------------------------------------------------------
# Manifest I/O
# ---------------------------------------------------------------------------


def load_manifest():
    if not os.path.exists(MANIFEST_PATH):
        return {}
    try:
        with open(MANIFEST_PATH) as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        print(
            f"WARN: could not load manifest ({e}); treating as empty", file=sys.stderr
        )
        return {}


def save_manifest(data):
    os.makedirs(os.path.dirname(MANIFEST_PATH), exist_ok=True)
    with open(MANIFEST_PATH, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main():
    if len(sys.argv) != 3:
        print(
            f"Usage: {sys.argv[0]} <settings-json> <restart-map-json>", file=sys.stderr
        )
        sys.exit(1)

    try:
        new_settings = json.loads(sys.argv[1])
        restart_map = json.loads(sys.argv[2])
    except json.JSONDecodeError as e:
        print(f"ERROR: failed to parse arguments: {e}", file=sys.stderr)
        sys.exit(1)

    old_manifest = load_manifest()

    print("macosDefaults: removing stale keys")
    delete_removed(old_manifest, new_settings)

    print("macosDefaults: writing settings")
    write_settings(new_settings)

    save_manifest(new_settings)

    print("macosDefaults: restarting affected processes")
    restart_processes(new_settings, restart_map)

    print("macosDefaults: done")


main()
