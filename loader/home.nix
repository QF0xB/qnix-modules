{
  lib,
  categories ? null,
  ...
}:
let
  # Import module index
  moduleIndex = import ../module-index.nix;

  # Default to all categories if not specified
  allCategories = builtins.attrNames moduleIndex;
  finalCategories = if categories != null then categories else allCategories;

  # Ensure core is always included
  categoriesList = lib.unique ([ "core" ] ++ finalCategories);

  # Validate categories exist in index
  validCategories = builtins.filter (cat: builtins.hasAttr cat moduleIndex) categoriesList;

  # Collect all Home Manager modules from selected categories
  collectHomeModules =
    category:
    let
      catModules = moduleIndex.${category} or { };
      moduleNames = builtins.attrNames catModules;
      # Only include modules that have home = true
      homeModules = builtins.filter (
        name:
        let
          info = catModules.${name};
        in
        info.home or false
      ) moduleNames;
      modulePaths = builtins.map (
        name: (toString ./../modules) + "/${category}/${name}/home/module.nix"
      ) homeModules;
    in
    modulePaths;

  # Collect all imports
  allHomeModules = lib.concatMap collectHomeModules validCategories;

  # qnix options must be loaded first (defines the namespace)
  # qnix is NOT in module-index, it's always loaded from modules/qnix/
  # Use __dirname-relative path: loader/ is sibling to modules/
  qnixOptions = [ ./../modules/qnix/options/options.nix ];

  # qnix home module (if it exists)
  qnixHomeModule =
    if builtins.pathExists ./../modules/qnix/home/module.nix then
      [ ./../modules/qnix/home/module.nix ]
    else
      [ ];
in
lib.traceSeqN 1 ">>> [qnix/home] Categories: ${builtins.toString validCategories}" {
  # Import qnix options first, then other options, then modules
  imports = qnixHomeModule ++ allHomeModules;
}
