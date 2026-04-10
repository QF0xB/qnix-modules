# QNix Lib Helpers

This directory contains shared helper functions exposed as `lib.qnix.*`.

They are meant to solve two recurring problems in `qnix-modules`:

- `Home Manager` modules need to work in both modes:
  - integrated into `NixOS`, where the canonical config lives in `osConfig.qnix`
  - standalone, where the config lives in `config.qnix`
- `server` and `client` may run different `nixpkgs` versions, so option paths and package names may differ between stable and unstable

## Files

### `default.nix`
Combines all helper sets into one namespace:

- `lib.qnix.getQnixConfig`
- `lib.qnix.hasOption`
- `lib.qnix.firstExistingOptionPath`
- `lib.qnix.setAttrByExistingOptionPath`
- `lib.qnix.mkIfOption`
- `lib.qnix.getAttrFromPathsOr`
- `lib.qnix.firstExistingPackage`
- `lib.qnix.firstExistingPackageOr`

Use from a consuming flake like:

```nix
lib = inputs.qnix-modules.lib {
  lib = nixpkgs.lib;
  pkgs = pkgs;
};
```

### `context.nix`
Contains context helpers.

#### `getQnixConfig`
Returns the canonical `qnix` configuration object.

Use this in `Home Manager` modules so they work in both:

- `NixOS + Home Manager`: reads `osConfig.qnix`
- standalone `Home Manager`: falls back to `config.qnix`

Example:

```nix
let
  qcfg = lib.qnix.getQnixConfig { inherit config osConfig; };
in
lib.mkIf qcfg.profiles.home.developer.enable { ... }
```

### `options.nix`
Contains helpers for dealing with changed option paths between `nixpkgs` versions.

These helpers should usually work on `options`, not `config`, because compatibility should be based on what the current system supports.

#### `hasOption options path`
Returns whether an option path exists.

Use when a module needs to know if an upstream option is available.

#### `firstExistingOptionPath options paths`
Returns the first existing path from a list, or `null`.

Use when an upstream option has moved between releases.

#### `setAttrByExistingOptionPath options paths value`
Builds a config attrset using the first supported option path.

Use when the same logical setting must be written to different upstream option paths depending on `nixpkgs`.

#### `mkIfOption options path value`
Sets a value only if the option path exists.

Use when a feature is optional and should only be configured when supported.

### `attrs.nix`
Contains helpers for reading from normal attrsets with fallback paths.

#### `getAttrFromPathsOr default attrs paths`
Reads the first existing attr path from an attrset, otherwise returns `default`.

Use when reading values from `config`, `osConfig`, or other computed attrsets where multiple path variants are possible.

### `packages.nix`
Contains helpers for package compatibility.

#### `firstExistingPackage pkgs names`
Returns the first package that exists in a package set, or `null`.

Use when package names differ between stable and unstable channels.

#### `firstExistingPackageOr default pkgs names`
Same as above, but returns a default value when no package exists.

Use when a package is optional or when you want a controlled fallback.

## Rules of thumb

- In `NixOS` modules, read from `config.qnix`
- In `Home Manager` modules, use `lib.qnix.getQnixConfig`
- For compatibility between stable and unstable, inspect `options` when deciding where to write config
- For package compatibility, use `firstExistingPackage*`

## Typical examples

### Home Manager module

```nix
{ lib, config, osConfig ? null, ... }:
let
  qcfg = lib.qnix.getQnixConfig { inherit config osConfig; };
in
{
  config = lib.mkIf qcfg.apps.obsidian.enable {
    programs.obsidian.enable = true;
  };
}
```

### Option path compatibility

```nix
config = lib.mkMerge [
  (lib.qnix.setAttrByExistingOptionPath options [
    [ "services" "xserver" "displayManager" "sddm" "enable" ]
    [ "services" "displayManager" "sddm" "enable" ]
  ] true)
];
```

### Package compatibility

```nix
let
  vscodePkg = lib.qnix.firstExistingPackageOr pkgs.vscode pkgs [
    "code-cursor"
    "vscode"
  ];
in
{
  environment.systemPackages = [ vscodePkg ];
}
```
