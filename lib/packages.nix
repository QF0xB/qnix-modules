{ lib, pkgs ? null }:
let
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
}
