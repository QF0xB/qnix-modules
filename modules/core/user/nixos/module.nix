{ lib, config, ... }:

let
  cfg = config.qnix.user;
  
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
      
      # Build config with all fields, then filter out null/empty
      fullConfig = {
        group = userGroup;
        home = userCfg.home;
        description = userCfg.description;
        extraGroups = userCfg.extraGroups;
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
  
  # Groups to create (when group name matches username)
  userGroups = lib.listToAttrs (
    lib.concatMap (username:
      let
        userCfg = cfg.users.${username};
        userGroup = if userCfg.group != null && userCfg.group != "" then userCfg.group else username;
      in
      lib.optional (userGroup == username) (lib.nameValuePair userGroup {})
    ) (lib.attrNames cfg.users)
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
