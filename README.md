# QNix Modules

Public, reusable NixOS and Home Manager modules. Contains no secrets - all sensitive configuration stays in client/server/pentesting repositories.

**Version-agnostic**: This repository has **no inputs** - it works with any Nixpkgs version. Modules receive inputs via `specialArgs` from consuming repositories.

## Quick Start

### Using in Your Flake

Add `qnix-modules` as an input:

```nix
{
  inputs = {
    # Recommended: Use FlakeHub (with version tag)
    qnix-modules = {
      url = "flakehub:your-org/qnix-modules/v2025.01.15.1";
      # Or use latest: "flakehub:your-org/qnix-modules"
    };
    
    # Alternative: Use GitHub directly
    # qnix-modules = {
    #   url = "github:your-org/qnix-modules";
    #   # Or use a specific branch/tag
    # };
  };
}
```

**Version tags**: FlakeHub releases are tagged as `vYEAR.MONTH.DAY.ITERATION` (e.g., `v2025.01.15.1`).

### Loading Modules

Import the loaders in your NixOS configuration:

```nix
{
  nixosConfigurations = {
    myhost = nixpkgs.lib.nixosSystem {
      specialArgs = {
        categories = ["core", "desktop"];  # Load core + desktop modules
        # ... other specialArgs
      };
      
      modules = [
        inputs.qnix-modules.nixosModules.qnix
        # ... other modules
      ];
    };
  };
}
```

For Home Manager:

```nix
{
  home-manager = {
    extraSpecialArgs = {
      categories = ["core", "desktop"];  # Load core + desktop modules
      # ... other specialArgs
    };
    
    users.myuser = {
      imports = [
        inputs.qnix-modules.homeManagerModules.qnix
        # ... other imports
      ];
    };
  };
}
```

## Categories

Modules are organized into categories for selective loading:

- **`core`**: Core system modules (always loaded, even if not specified)
- **`desktop`**: Desktop-specific modules (GUI, window managers, etc.)
- **`server`**: Server-specific modules (e.g., Nextcloud, server services)
- **`pentesting`**: Pentesting-specific modules

### Category Selection

- **Clients** (laptops, desktops): `categories = ["core", "desktop"]`
- **Servers**: `categories = ["core", "server"]` - Includes server services like Nextcloud
- **Pentesting**: `categories = ["core", "desktop"]` (or as needed)

If `categories` is not specified, **all categories** are loaded by default.

> **💡 Tip**: See [example/](example/) for complete client and server configuration examples.

## Module Structure

Each module follows this structure:

```
modules/{category}/{module-name}/
├── nixos/
│   └── module.nix      # NixOS configuration (optional)
├── home/
│   └── module.nix      # Home Manager configuration (optional)
└── options/
    └── options.nix      # Option definitions (always present)
```

## Creating a New Module

Use the `gen-module` script:

```bash
./tools/gen-module.sh <type> <name> <category>
```

**Parameters:**
- `type`: `n` (NixOS only), `h` (Home Manager only), or `b` (both)
- `name`: Module name (e.g., `mymodule`)
- `category`: `core`, `desktop`, `server`, or `pentesting`

**Example:**
```bash
# Create a module with both NixOS and Home Manager support
./tools/gen-module.sh b mymodule desktop
```

After creating a module, regenerate the index:
```bash
python3 tools/module-update.py
```

## Module Index

The `module-index.nix` file is **generated and committed**. It provides fast, deterministic module loading without directory scanning.

**Regenerating the index:**
```bash
python3 tools/module-update.py
```

This will:
1. Scan `modules/` directory
2. Generate `module-index.nix`
3. Generate `MODULES.md` documentation

**Important**: Always commit the generated `module-index.nix` and `MODULES.md` files.

## Module Options

All modules expose options under `qnix.<module-name>.*`. At minimum, every module has:

- `qnix.<module-name>.enable` (bool, default: `false`) - Enable the module

See [MODULES.md](MODULES.md) for complete documentation of all modules and their options.

## Compatibility

Modules use capability detection via `lib.hasAttrByPath` to handle upstream API changes. This allows:

- Server to pin `nvf` 0.7
- Client to pin `nvf` 0.8
- Both use identical `qnix.nvf.*` configuration

Modules automatically adapt to the available API.

## Accessing Inputs in Modules

Modules receive selected inputs via `specialArgs`. Pass only what modules need:

```nix
specialArgs = {
  categories = ["core", "desktop"];
  inputs = {
    nvf = inputs.nvf;        # Only inputs modules actually use
    ags = inputs.ags;
    # Not all inputs, just what's needed
  };
};
```

Modules access inputs via `inputs` from `specialArgs`:

```nix
{ lib, config, inputs, ... }:
let
  nvfModule = inputs.nvf.homeManagerModules.default;
in
{ ... }
```

## Using the QNix Library

The `qnix-modules` flake exports a `lib` function that extends your nixpkgs `lib` with QNix utilities:

```nix
outputs = { nixpkgs, ... }@inputs:
let
  pkgs = import nixpkgs { ... };
  
  # Extend nixpkgs.lib with qnix-modules utilities
  lib = inputs.qnix-modules.lib {
    lib = nixpkgs.lib;
    pkgs = pkgs;
  };
in
{
  # Use lib in your configurations
  # lib.qnix-lib.writeShellApplicationCompletions { ... }
}
```

## Development

### Project Structure

```
qnix-modules/
├── flake.nix              # Exports modules
├── lib/
│   └── default.nix         # mkQnixLib function
├── loader/
│   ├── nixos.nix          # NixOS module loader
│   └── home.nix           # Home Manager module loader
├── module-index.nix       # Generated module index
├── MODULES.md             # Generated module documentation
├── modules/               # Module directory
│   ├── core/
│   ├── desktop/
│   ├── server/
│   └── pentesting/
└── tools/
    ├── gen-module.sh      # Create new module
    └── module-update.py   # Generate index & docs
```

### Building and Testing

Validate that the flake evaluates correctly:

```bash
# Check that the flake structure is valid
nix eval .#checks

# Or evaluate specific outputs
nix eval .#nixosModules.qnix
nix eval .#homeManagerModules.qnix
```

### Workflow

1. **Create a module**: `./tools/gen-module.sh b mymodule desktop`
2. **Edit module files**: Add your configuration
3. **Regenerate index**: `python3 tools/module-update.py`
4. **Validate**: `nix eval .#checks` to ensure everything evaluates
5. **Commit**: Include `module-index.nix` and `MODULES.md` in your commit

## Example Branches

### Empty Scaffold Branch

For a clean starting point with no existing modules (only the scaffold structure), check out the `scaffold` branch:

```bash
git checkout scaffold
```

This branch contains:
- Complete module structure (categories, loaders, tools)
- No pre-configured modules
- Ready for you to add your own modules from scratch

### Example Configurations

See [example/](example/) for complete client and server configuration examples.

## Branching Strategy

See [BRANCHING.md](BRANCHING.md) for the complete branching strategy. Quick summary:

- **`main`**: Stable releases (tagged, published to FlakeHub)
- **`dev`**: Development branch (bleeding edge, used by clients when testing)
- **`scaffold`**: Empty template with no modules

## See Also

- [MODULES.md](MODULES.md) - Complete module documentation
- [BRANCHING.md](BRANCHING.md) - Branching strategy and workflow
- [example/](example/) - Example client and server configurations
