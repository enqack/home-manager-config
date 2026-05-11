# NixOS and Nix-Darwin Home Manager Configuration

## Getting started

### Linux

Install and initial run:

1. `git clone git@github.com:enqack/home-manager-config.git /home/<user>/.config/home-manager`
2. `home-manager switch`

Subsequent runs:

- `nh home switch`

### Darwin

Install and initial run:

1. `git clone git@github.com:enqack/home-manager-config.git /Users/<user>/.config/home-manager`
2. `home-manager switch`

Subsequent runs:

- `nh home switch`

## Current directory structure

```text
home-mamager-config
├── lib                 # Function library
├── modules             # Configuration modules
│  ├── darwin           # MacOS configuration modules
│  ├── linux            # Linux configuration modules
│  └── shared           # OS agnostic configuration modules
├── pkgs                # Package definitions
├── profiles            # Configuration profiles
│  ├── base
│  ├── linux
│  └── darwin
└── users               # User configurations
    ├── sysadm          # Default user configuration
    └── sysop           # Default user configuration
        └── hosts       # Host specific user configuration
```
