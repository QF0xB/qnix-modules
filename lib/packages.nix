{ lib, pkgs ? null }:
let
  requirePkgs =
    helper:
    if pkgs == null then
      throw "lib.qnix.${helper} requires `pkgs` to be provided when constructing the qnix lib."
    else
      pkgs;

  # Return the first package that exists in a package set.
  # This is useful when package names differ between stable and unstable.
  firstExistingPackage =
    packageSet: names:
    let
      matches = builtins.filter (name: builtins.hasAttr name packageSet) names;
    in
    if matches == [ ] then null else builtins.getAttr (builtins.head matches) packageSet;
in
{
  inherit firstExistingPackage;

  # Same as firstExistingPackage, but return a default fallback instead of null.
  firstExistingPackageOr =
    default: packageSet: names:
    let
      pkg = firstExistingPackage packageSet names;
    in
    if pkg == null then default else pkg;

  # Convert an attrset of shell package definitions into derivations.
  mkShellPackages =
    packages:
    let
      pkgs' = requirePkgs "mkShellPackages";
      renderPackage =
        name: value:
        if lib.isDerivation value then
          value
        else if lib.isString value then
          pkgs'.writeShellApplication {
            inherit name;
            text = value;
          }
        else if builtins.isAttrs value then
          pkgs'.writeShellApplication ({ inherit name; } // value)
        else
          throw "lib.qnix.mkShellPackages: `${name}` must be a package, string, or attrset for writeShellApplication.";
    in
    lib.mapAttrs renderPackage packages;
}
