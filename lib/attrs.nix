{ lib }:
{
  # Read the first existing attr path from an attrset, else return `default`.
  # Use this for reading from config-like attrsets where multiple path variants
  # may exist.
  getAttrFromPathsOr =
    default: attrs: paths:
    let
      matches = builtins.filter (path: builtins.hasAttrByPath path attrs) paths;
    in
    if matches == [ ] then default else builtins.getAttrFromPath (builtins.head matches) attrs;
}
