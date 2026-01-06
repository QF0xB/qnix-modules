# Example Configurations

This directory contains example configurations for using qnix-modules in client and server setups.

## Client Example

The `client/` directory shows how to set up a desktop/laptop configuration:

- **Categories**: `["core", "desktop"]` - Loads both core and desktop modules
- **Nixpkgs**: Uses `nixos-unstable` for bleeding-edge packages
- **Inputs**: Includes desktop-specific inputs (nvf, ags, qnix-ags)

### Key Points

1. **flake.nix**: Passes `categories = ["core", "desktop"]` in `specialArgs`
2. **nixos-hosts.nix**: Host factory that uses categories from `specialArgs`
3. **myhost/qnix.nix**: Example of enabling desktop modules

## Server Example

The `server/` directory shows how to set up a server configuration:

- **Categories**: `["core", "server"]` - Loads core and server-specific modules (e.g., Nextcloud)
- **Nixpkgs**: Uses stable branch (e.g., `nixos-25.11`)
- **Inputs**: Minimal - only what server modules need

### Key Points

1. **flake.nix**: Passes `categories = ["core", "server"]` in `specialArgs`
2. **nixos-hosts.nix**: Same structure as client, but loads core + server modules
3. **myserver/qnix.nix**: Example showing core and server modules available

## Usage

These are reference examples. To use them:

1. Copy the structure to your own repository
2. Update input URLs to point to your actual repositories
3. Customize host configurations in `{host-name}/` directories
4. Adjust `categories` and `inputs` in `specialArgs` as needed

## Differences: Client vs Server

| Aspect | Client | Server |
|--------|--------|--------|
| Categories | `["core", "desktop"]` | `["core", "server"]` |
| Nixpkgs | `nixos-unstable` | `nixos-25.11` (stable) |
| Evaluation | Slower (more modules) | Faster (core + server only) |
| Modules Available | Core + Desktop | Core + Server (e.g., Nextcloud) |

