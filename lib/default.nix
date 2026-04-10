{ lib, pkgs ? null }:
# Entry point for all shared qnix helpers.
# Consumers should import this through the flake's `lib` output so helpers are
# available as `lib.qnix.*`.
{
  qnix =
    (import ./context.nix { inherit lib; })
    // (import ./imports.nix { })
    // (import ./options.nix { inherit lib; })
    // (import ./attrs.nix { inherit lib; })
    // (import ./packages.nix { inherit lib pkgs; });
}
