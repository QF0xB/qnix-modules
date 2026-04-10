{ lib }:
let
  # Find the first supported option path from a list of possible upstream paths.
  # This is mainly for stable/unstable compatibility when option paths move.
  firstExistingOptionPath =
    options: paths:
    let
      matches = builtins.filter (path: builtins.hasAttrByPath path options) paths;
    in
    if matches == [ ] then null else builtins.head matches;
in
{
  # Return whether an option path exists in `options`.
  hasOption = options: path: builtins.hasAttrByPath path options;

  inherit firstExistingOptionPath;

  # Set a config value using the first supported option path.
  # Returns `{ }` if none of the candidate paths exist.
  setAttrByExistingOptionPath =
    options: paths: value:
    let
      path = firstExistingOptionPath options paths;
    in
    if path == null then { } else lib.setAttrByPath path value;

  # Set a config value only if the option exists on this nixpkgs version.
  mkIfOption =
    options: path: value:
    if builtins.hasAttrByPath path options then lib.setAttrByPath path value else { };
}
