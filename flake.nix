{
  description = "QNix NixOS modules";

  # No inputs - qnix-modules is version-agnostic
  # Modules receive inputs via specialArgs from consuming repositories
  inputs = {};

  outputs = { self, ... }:
    {
      # NixOS module loader
      nixosModules.qnix = import ./loader/nixos.nix;
      
      # Home Manager module loader
      homeManagerModules.qnix = import ./loader/home.nix;
      
      # Library builder - consumers pass their lib and pkgs
      # Usage: lib = inputs.qnix-modules.lib { lib = nixpkgs.lib; pkgs = ...; };
      lib = { lib, pkgs }: import ./qnix-lib.nix { inherit lib pkgs; };

      # Development outputs
      # Validate flake structure: nix eval .#checks
      # This ensures the flake evaluates correctly
      checks = {
        # If this evaluates, the flake structure is valid
        valid = true;
      };
      
      # Documentation generation
      # Usage: nix build .#docs.markdown or nix build .#docs.json
      # nixpkgs is only fetched when building docs, not during flake evaluation
      docs = let
        # Fetch nixpkgs for documentation generation (only when docs are built)
        nixpkgsSrc = builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
        };
        # Import nixpkgs - nixosOptionsDoc is in pkgs.lib
        nixpkgs = import nixpkgsSrc {
          # Ensure we get the full nixpkgs with lib functions
        };
        
        # Collect all option modules (for documentation)
        # Similar to loader/nixos.nix but includes ALL categories
        collectAllOptions = root:
          let
            moduleIndex = import (root + "/module-index.nix");
            modulesRoot = root + "/modules";
            
            collectFromCategory = category:
              let
                catModules = moduleIndex.${category} or {};
                moduleNames = builtins.attrNames catModules;
                optionPaths = builtins.map (name:
                  modulesRoot + "/${category}/${name}/options/options.nix"
                ) moduleNames;
              in
              optionPaths;
            
            allCategories = builtins.attrNames moduleIndex;
            allOptionModules = nixpkgs.lib.concatMap collectFromCategory allCategories;
            qnixOptions = [ (modulesRoot + "/qnix/options/options.nix") ];
          in
          qnixOptions ++ allOptionModules;
        
        # Collect all option modules with proper imports
        qnixModules = builtins.map (path:
          import path {
            lib = nixpkgs.lib;
            pkgs = nixpkgs;
          }
        ) (collectAllOptions (toString ./.));
      in
      import ./docs/generation/options.nix {
        lib = nixpkgs.lib;
        pkgs = nixpkgs;
        qnixModules = qnixModules;
      };
    };
}
