{ lib, config, ... }:

let
  cfg = config.qnix.core.user;
  
  # Convert qnix.user.users to users.users format
  # Simple attrset construction with cleanup
  convertUser = username: userCfg:
    let
      # Group is required - use provided value or default to username
      userGroup = if userCfg.group != null && userCfg.group != "" then 
        userCfg.group 
      else 
        username;
      
      # Determine user type (exactly one must be set)
      userType = if userCfg.isNormalUser == true then
        { isNormalUser = true; }
      else if userCfg.isSystemUser == true then
        { isSystemUser = true; }
      else
        { isNormalUser = true; };  # Default to normal user
      
      # Merge default extra groups with user-specific extra groups
      allExtraGroups = lib.unique (cfg.defaultExtraGroups ++ userCfg.extraGroups);
      
      # Build config with all fields, then filter out null/empty
      fullConfig = {
        group = userGroup;
        home = userCfg.home;
        description = userCfg.description;
        extraGroups = allExtraGroups;
        initialHashedPassword = userCfg.initialHashedPassword;
        ignoreShellProgramCheck = userCfg.ignoreShellProgramCheck;
        openssh.authorizedKeys.keys = userCfg.openssh.authorizedKeys.keys;
      } // userType;
      
      # Filter out null values and empty lists
      cleaned = lib.filterAttrs (name: value:
        # Always keep group and user type
        name == "group" || name == "isNormalUser" || name == "isSystemUser" ||
        # For other attributes, filter out null and empty lists
        (value != null && !(lib.isList value && value == []))
      ) fullConfig;
    in
    cleaned;
  
  # Convert users using mapAttrs' to handle attribute names with dots
  convertedUsers = lib.listToAttrs (
    lib.mapAttrsToList (username: userCfg:
      lib.nameValuePair username (convertUser username userCfg)
    ) cfg.users
  );
  
  # Root user config
  rootUser = lib.optionalAttrs cfg.root.enable {
    root = {
      isSystemUser = true;
      initialHashedPassword = cfg.root.password;
    };
  };
  
  # Groups to create (all groups referenced by users)
  # Collect all unique group names from all users
  allGroupNames = lib.unique (
    lib.mapAttrsToList (username: userCfg:
      if userCfg.group != null && userCfg.group != "" then 
        userCfg.group 
      else 
        username
    ) cfg.users
  );
  
  # Create groups for all referenced group names
  userGroups = lib.listToAttrs (
    lib.map (groupName: lib.nameValuePair groupName {}) allGroupNames
  );
in
{
  config = lib.mkIf cfg.enable {
    # Direct attrset merge
    users = {
      mutableUsers = false;
      users = rootUser // convertedUsers;
    };
    
    # Groups
    users.groups = userGroups;
  };
}
