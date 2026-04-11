# QNix Modules

`qnix-modules` is a reusable module library for:

- `NixOS`
- `Home Manager`
- mixed `NixOS + Home Manager` setups

The new structure is based on:

- **profiles** for composition
- **modules** for reusable capabilities
- **options** for feature schemas
- a shared `qnix.*` config tree
- helper functions under `lib.qnix.*`

This repository is now organized around the new profile-based system. The old
category-based structure is obsolete.

## Design

### Core ideas

- `profiles/nixos` describes machine roles
- `profiles/home` describes user roles
- `modules/shared/qnix-options.nix` defines always-available shared schema
- `options/` defines additional feature option schemas
- `modules/nixos` implements reusable NixOS capabilities
- `modules/home` implements reusable Home Manager capabilities
- `lib/` contains compatibility and context helpers

### Canonical config

The public configuration lives under:

```nix
qnix = { ... };
```

Rules:

- In `NixOS` modules, use `config.qnix`
- In `Home Manager` modules:
  - use `osConfig.qnix` when integrated into NixOS
  - fall back to `config.qnix` in standalone HM
  - use `qnixLib.qnix.getQnixConfig` for this

## Repository Layout

```text
.
├── flake.nix
├── garnix.yaml
├── checks/
│   └── flake.nix
├── lib/
│   ├── README.md
│   ├── default.nix
│   ├── context.nix
│   ├── options.nix
│   ├── attrs.nix
│   └── packages.nix
├── loader/
│   ├── nixos.nix
│   └── home.nix
├── options/
│   └── nixos/
├── modules/
│   ├── nixos/
│   ├── home/
│   └── shared/
│       └── qnix-options.nix
└── profiles/
    ├── nixos/
    └── home/
```

## Flakes

### Root flake

The root [`flake.nix`](./flake.nix) is intentionally minimal:

- exports `nixosModules.qnix`
- exports `homeManagerModules.qnix`
- exports `lib`

It does **not** carry evaluation-only inputs like `home-manager` or `nixpkgs`.

### Checks flake

The real evaluation checks live in:

- [`checks/flake.nix`](./checks/flake.nix)

This flake contains the pinned test harness:

- `nixpkgs`
- `home-manager`
- `path:..` back to `qnix-modules`

Run locally with:

```bash
nix flake check ./checks
```

### GitHub Actions

This repo publishes and validates flakes through GitHub Actions:

- [`.github/workflows/checks.yml`](./.github/workflows/checks.yml)
  runs `nix flake check ./checks` on pull requests and pushes to the default branch
- [`.github/workflows/release-tagged.yml`](./.github/workflows/release-tagged.yml)
  on tag `v*`: publishes the flake to **FlakeHub** (consumer-facing) and creates a **GitHub Release** with changelog notes only

The release helper commands in the client workflow assume tags like `v0.1.0`.

### Garnix

Garnix is configured to evaluate the nested checks flake directly:

- [`garnix.yaml`](./garnix.yaml)

Current config:

```yaml
flakeDir: checks
```

## Loaders

### NixOS loader

Use the NixOS loader to activate machine profiles:

```nix
(import "${inputs.qnix-modules}/loader/nixos.nix" {
  inherit lib;
  profiles = [
    "base"
    "server"
  ];
})
```

The loader always imports `modules/shared/qnix-options.nix` and then the
selected profiles. Profiles are still responsible for importing the
implementation modules they need.

### Home Manager loader

Use the Home loader to activate user profiles:

```nix
(import "${inputs.qnix-modules}/loader/home.nix" {
  lib = nixpkgs.lib;
  profiles = [
    "base"
    "developer"
  ];
})
```

Important:

- the loader always imports `modules/shared/qnix-options.nix`
- profiles provide the actual feature/module imports
- the Home loader should use plain `nixpkgs.lib`
- do **not** override Home Manager's `lib`
- pass `qnixLib` separately via `extraSpecialArgs`

## Library Helpers

This repo exposes helper functions under:

```nix
lib.qnix.*
```

See:

- [`lib/README.md`](./lib/README.md)

Main helpers include:

- `getQnixConfig`
- `hasOption`
- `firstExistingOptionPath`
- `setAttrByExistingOptionPath`
- `mkIfOption`
- `getAttrFromPathsOr`
- `firstExistingPackage`
- `firstExistingPackageOr`

## Using the System

Full usage examples for all supported modes are in:

- [`USAGE.md`](./USAGE.md)

Covered there:

- `NixOS only`
- `Home Manager only`
- `NixOS + Home Manager`

## Compatibility Rules

The intended compatibility model is:

- `server` can use stable
- `client` can use unstable
- modules should adapt to moved option paths and package renames

Rules:

- use `options` when deciding which config path to write
- use `lib.qnix.setAttrByExistingOptionPath` for option path differences
- use `lib.qnix.firstExistingPackage*` for package name differences

## Current Direction

This repository is in the middle of the new-system rewrite.

That means:

- the new profile-based architecture is the source of truth
- old category-based docs and assumptions are no longer valid
- the root flake stays minimal
- the `checks` flake is the evaluation harness

If something in the repo still reflects the old model, treat it as migration
leftovers, not as the intended design.
