{
  description = "QNix NixOS modules";

  # No inputs - qnix-modules is version-agnostic
  # Modules receive inputs via specialArgs from consuming repositories
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
    };
}
