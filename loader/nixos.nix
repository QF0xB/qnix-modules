{ lib, categories ? null, loadOptions ? false, ... }:
let
  # Import module index
  moduleIndex = import ../module-index.nix;
  
  # Default to all categories if not specified
  allCategories = builtins.attrNames moduleIndex;
  finalCategories = if categories != null then categories else allCategories;
  
  # Ensure core is always included
  categoriesList = lib.unique (["core"] ++ finalCategories);
  
  # Validate categories exist in index
  validCategories = builtins.filter (cat: builtins.hasAttr cat moduleIndex) categoriesList;
  
  # Collect all option modules from selected categories
  # Exclude stylix as it's always loaded separately
  collectOptions = category:
    let
      catModules = moduleIndex.${category} or {};
      moduleNames = builtins.attrNames catModules;
      # Filter out stylix (loaded separately)
      filteredNames = builtins.filter (name: name != "stylix") moduleNames;
      # Build paths using string concatenation - Nix will resolve relative to this file
      optionPaths = builtins.map (name: 
        (toString ./../modules) + "/${category}/${name}/options/options.nix"
      ) filteredNames;
    in
    optionPaths;
  
  # Collect all NixOS modules from selected categories
  collectNixosModules = category:
    let
      catModules = moduleIndex.${category} or {};
      moduleNames = builtins.attrNames catModules;
      # Only include modules that have nixos = true
      nixosModules = builtins.filter (name:
        let info = catModules.${name};
        in info.nixos or false
      ) moduleNames;
      modulePaths = builtins.map (name: 
        (toString ./../modules) + "/${category}/${name}/nixos/module.nix"
      ) nixosModules;
    in
    modulePaths;
  
  # Collect all imports
  allOptionModules = lib.concatMap collectOptions validCategories;
  allNixosModules = lib.concatMap collectNixosModules validCategories;
  
  # qnix options must be loaded first (defines the namespace)
  # qnix is NOT in module-index, it's always loaded from modules/qnix/
  # Use __dirname-relative path: loader/ is sibling to modules/
  qnixOptions = [ ./../modules/qnix/options/options.nix ];
  
  # qnix nixos module (if it exists)
  qnixNixosModule = if builtins.pathExists ./../modules/qnix/nixos/module.nix
    then [ ./../modules/qnix/nixos/module.nix ]
    else [];
  
  # Collect stylix options specifically (always loaded, not dependent on loadOptions)
  stylixOptions = if builtins.hasAttr "core" moduleIndex && builtins.hasAttr "stylix" (moduleIndex.core or {}) then
    [ (toString ./../modules) + "/core/stylix/options/options.nix" ]
  else
    [];
  
  # Conditionally include options based on loadOptions flag
  # When loadOptions = true: options are loaded into NixOS (for servers without home-manager)
  # When loadOptions = false: options are only in home-manager, accessed via config.hm.qnix.*
  # Modules should check both: config.qnix.* or config.hm.qnix.* for maximum flexibility
  # Exception: stylix options are always loaded in NixOS
  optionImports = stylixOptions ++ (if loadOptions then (qnixOptions ++ allOptionModules) else []);
in
lib.traceSeqN 1
  ">>> [qnix/nixos] Categories: ${builtins.toString validCategories}, loadOptions: ${builtins.toString loadOptions}"
  {
    # Import options first (if loadOptions=true), then NixOS modules
    # Modules should check config.qnix.* first, fallback to config.hm.qnix.*
    imports = optionImports ++ allNixosModules;
  }

