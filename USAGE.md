# QNix Usage

This document describes how to use the new `qnix-modules` layout in the three
supported modes:

- `NixOS` only
- `Home Manager` only
- `NixOS + Home Manager`

The new model is:

- loaders activate **profiles**
- host or user config sets `qnix.*` values
- `NixOS` modules use `lib.qnix.*`
- `Home Manager` modules use `qnixLib.qnix.*`

## Core Rule

There are two different library contexts:

### NixOS modules
Use the extended module-system lib:

```nix
lib.qnix.*
```

### Home Manager modules
Do **not** override Home Manager's `lib`, because HM needs `lib.hm.*`.

Instead pass a separate helper library:

```nix
extraSpecialArgs = {
  qnixLib = inputs.qnix-modules.lib {
    lib = nixpkgs.lib;
    pkgs = pkgs;
  };
};
```

Then use:

```nix
qnixLib.qnix.*
```

## 1. NixOS Only

Use this when the machine only consumes NixOS modules and not Home Manager.

### Flake pattern

```nix
{
  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      qnixLib = inputs.qnix-modules.lib {
        lib = nixpkgs.lib;
        inherit pkgs;
      };

      lib = nixpkgs.lib.extend (_final: _prev: qnixLib);
    in {
      nixosConfigurations.myhost = lib.nixosSystem {
        inherit pkgs lib;

        modules = [
          inputs.impermanence.nixosModules.impermanence
          inputs.sops-nix.nixosModules.sops

          ./hosts/myhost/configuration.nix
          ./hosts/myhost/qnix.nix
          ./hosts/myhost/hardware.nix

          (import "${inputs.qnix-modules}/loader/nixos.nix" {
            inherit lib;
            profiles = [
              "base"
              "server"
            ];
          })
        ];
      };
    };
}
```

### Host config pattern

```nix
{
  qnix = {
    system.headless = true;

    services = {
      openssh.enable = true;
      fail2ban.enable = true;
      netbird.enable = false;
    };
  };
}
```

If you use `qnix.security.sops`, the consumer must import `sops-nix`
explicitly. `qnix-modules` does not import `sops-nix` from inside the module.

If you use the `impermanent` profile or set `qnix.storage.impermanence.enable`,
the consumer must also import `inputs.impermanence.nixosModules.impermanence`
explicitly. `qnix-modules` does not import the upstream impermanence module
from inside the storage module.

Per-user persistence is configured through `qnix.persist.users`, keyed by
username. The special key `"*"` applies defaults to every managed user from
`qnix.system.users.users`.

## 2. Home Manager Only

Use this when there is no NixOS system module layer, for example:

- standalone Home Manager on Linux
- `nix-darwin + Home Manager`
- user-only configuration

### Flake pattern

```nix
{
  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      qnixLib = inputs.qnix-modules.lib {
        lib = nixpkgs.lib;
        inherit pkgs;
      };
    in {
      homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit qnixLib;
        };

        modules = [
          ./home.nix

          (import "${inputs.qnix-modules}/loader/home.nix" {
            lib = nixpkgs.lib;
            profiles = [
              "base"
              "developer"
            ];
          })

          {
            home.username = "q.braendli";
            home.homeDirectory = "/home/q.braendli";
            home.stateVersion = "25.11";

            qnix = {
              apps.obsidian.enable = true;
            };
          }
        ];
      };
    };
}
```

### Home module pattern

In standalone Home Manager there is no `osConfig`, so helpers should fall back
to `config.qnix`.

```nix
{ lib, config, osConfig ? null, qnixLib, ... }:
let
  qcfg = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
in
{
  config = lib.mkIf qcfg.apps.obsidian.enable {
    programs.git.enable = true;
  };
}
```

## 3. NixOS + Home Manager

Use this when Home Manager is integrated into a NixOS system.

This is the most important combined mode because:

- NixOS owns the canonical `qnix` configuration
- Home Manager should read from `osConfig.qnix`
- Home Manager must still keep its own `lib.hm.*`

### Flake pattern

```nix
{
  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      qnixLib = inputs.qnix-modules.lib {
        lib = nixpkgs.lib;
        inherit pkgs;
      };

      lib = nixpkgs.lib.extend (_final: _prev: qnixLib);
    in {
      nixosConfigurations.myclient = lib.nixosSystem {
        inherit pkgs lib;

        modules = [
          inputs.impermanence.nixosModules.impermanence
          inputs.sops-nix.nixosModules.sops

          ./hosts/myclient/configuration.nix
          ./hosts/myclient/qnix.nix
          ./hosts/myclient/hardware.nix

          (import "${inputs.qnix-modules}/loader/nixos.nix" {
            inherit lib;
            profiles = [
              "base"
              "workstation"
              "laptop"
            ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit qnixLib;
              };

              users."q.braendli" = {
                imports = [
                  ./hosts/myclient/home.nix

                  (import "${inputs.qnix-modules}/loader/home.nix" {
                    lib = nixpkgs.lib;
                    profiles = [
                      "base"
                      "developer"
                    ];
                  })
                ];
              };
            };
          }
        ];
      };
    };
}
```

If the NixOS side uses `qnix.security.sops`, keep `sops-nix` imported on the
NixOS side and let Home Manager consume the resulting `osConfig.qnix` state.

If the NixOS side loads the `impermanent` profile, keep
`inputs.impermanence.nixosModules.impermanence` in the NixOS module list so the
`environment.persistence` option tree exists before the QNix storage module
configures it.

### Host config pattern

The canonical config lives in NixOS:

```nix
{
  qnix = {
    system.headless = false;

    services = {
      openssh.enable = true;
      docker.enable = true;
    };

    apps = {
      obsidian.enable = true;
      codex.enable = true;
    };
  };
}
```

### Home module pattern

In integrated mode, `getQnixConfig` will prefer `osConfig.qnix`.

```nix
{ lib, config, osConfig ? null, qnixLib, ... }:
let
  qcfg = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
in
{
  config = lib.mkIf qcfg.apps.codex.enable {
    home.sessionVariables.EDITOR = "nvim";
  };
}
```

## Summary

### NixOS only
- extend `nixpkgs.lib` with `inputs.qnix-modules.lib`
- import `loader/nixos.nix`
- use `lib.qnix.*`

### Home only
- keep Home Manager's own `lib`
- pass `qnixLib` via `extraSpecialArgs`
- import `loader/home.nix` with plain `nixpkgs.lib`
- use `qnixLib.qnix.*`

### NixOS + Home Manager
- extend `nixpkgs.lib` for the NixOS side
- pass `qnixLib` separately to Home Manager
- Home Manager modules read from `osConfig.qnix` when present

## What not to do

- Do not override Home Manager's `lib` with the extended qnix lib
- Do not use `lib.qnix.*` directly inside Home Manager modules
- Do not duplicate the canonical config tree between NixOS and HM

Use:
- `lib.qnix.*` in NixOS
- `qnixLib.qnix.*` in Home Manager
