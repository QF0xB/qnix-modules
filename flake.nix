{
  description = "QNix modules";

  # Keep the root flake version-agnostic. Evaluation checks live in ./checks.
  inputs = {};

  outputs = {self, ...}: {
    # Profile-based NixOS loader.
    nixosModules.qnix = import ./loader/nixos.nix;

    # Profile-based Home Manager loader.
    homeManagerModules.qnix = import ./loader/home.nix;

    # Shared helper library, exposed as lib.qnix.* in consuming repos.
    #
    # Usage:
    # lib = inputs.qnix-modules.lib {
    #   lib = nixpkgs.lib;
    #   pkgs = pkgs;
    # };
    lib = {
      lib,
      pkgs ? null,
    }:
      import ./lib {inherit lib pkgs;};
  };
}
