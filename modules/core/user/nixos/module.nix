{ lib, config, ... }:

let
  # Options can be in NixOS (system-wide, if loadOptions=true) or home-manager (via config.hm.qnix.*)
  # Check system-wide first, fallback to home-manager for flexibility (e.g., servers without home-manager)
  cfg = config.qnix.core.user or config.hm.qnix.core.user;

  # Convert qnix.user.users to users.users format
  # Simple attrset construction with cleanup
  convertUser =
    username: userCfg:
    let
      # Group is required - use provided value or default to username
      userGroup = if userCfg.group != null && userCfg.group != "" then userCfg.group else username;

      # Determine user type (exactly one must be set)
      userType =
        if userCfg.isNormalUser == true then
          { isNormalUser = true; }
        else if userCfg.isSystemUser == true then
          { isSystemUser = true; }
        else
          { isNormalUser = true; }; # Default to normal user

      # Merge default extra groups with user-specific extra groups
      allExtraGroups = lib.unique (cfg.defaultExtraGroups ++ userCfg.extraGroups);

      # Determine password source: sops secret path or direct password
      # sops secrets are decrypted at activation time, so we can reference the path
      passwordValue =
        if userCfg.passwordFromSops != null then
          # Use sops secret path - NixOS will read the file during activation
          config.sops.secrets.${userCfg.passwordFromSops}.path
        else
          userCfg.initialHashedPassword;

      # Build config with all fields, then filter out null/empty
      fullConfig = {
        group = userGroup;
        home = userCfg.home;
        description = userCfg.description;
        extraGroups = allExtraGroups;
        # Set initialHashedPassword to the file path when using sops, or direct password otherwise
        hashedPasswordFile = if userCfg.passwordFromSops != null then passwordValue else null;
        initialHashedPassword =
          if userCfg.initialHashedPassword != null then userCfg.initialHashedPassword else null;
        ignoreShellProgramCheck = userCfg.ignoreShellProgramCheck;
        openssh.authorizedKeys.keys = userCfg.openssh.authorizedKeys.keys;
      }
      // userType;

      # Filter out null values and empty lists
      cleaned = lib.filterAttrs (
        name: value:
        # Always keep group and user type
        name == "group"
        || name == "isNormalUser"
        || name == "isSystemUser"
        ||
          # For other attributes, filter out null and empty lists
          (value != null && !(lib.isList value && value == [ ]))
      ) fullConfig;
    in
    cleaned;

  # Convert users using mapAttrs' to handle attribute names with dots
  convertedUsers = lib.listToAttrs (
    lib.mapAttrsToList (
      username: userCfg: lib.nameValuePair username (convertUser username userCfg)
    ) cfg.users
  );

  # Root user config
  rootUser = lib.optionalAttrs cfg.root.enable {
    root = {
      isSystemUser = true;
      # Use sops secret path if specified, otherwise use direct password
      initialHashedPassword =
        if cfg.root.passwordFromSops != null then
          config.sops.secrets.${cfg.root.passwordFromSops}.path
        else
          cfg.root.password;
    };
  };

  # Groups to create (all groups referenced by users as primary groups)
  # Note: Standard system groups like "users", "audio", "video", "wheel" should already exist
  # We only create primary groups here - extraGroups should reference existing system groups
  allGroupNames = lib.unique (
    lib.mapAttrsToList (
      username: userCfg: if userCfg.group != null && userCfg.group != "" then userCfg.group else username
    ) cfg.users
  );

  # Create groups for all referenced group names (primary groups only)
  userGroups = lib.listToAttrs (lib.map (groupName: lib.nameValuePair groupName { }) allGroupNames);
  # Helper function to check if sops secret exists
  sopsSecretExists = secretName: lib.hasAttr secretName (config.sops.secrets or { });

  # Assertions for password configuration (only when module is enabled)
  assertion = lib.optionals cfg.enable (
    [
      # Root user password validation
      {
        assertion = !cfg.root.enable || cfg.root.password == null || cfg.root.passwordFromSops == null;
        message = "qnix.core.user.root: Cannot set both 'password' and 'passwordFromSops'";
      }
      # Root user sops secret must exist if passwordFromSops is set
      {
        assertion =
          !cfg.root.enable || cfg.root.passwordFromSops == null || sopsSecretExists cfg.root.passwordFromSops;
        message =
          if cfg.root.passwordFromSops != null then
            "qnix.core.user.root: sops secret '${cfg.root.passwordFromSops}' does not exist. Make sure it's defined in qnix.core.sops.secrets"
          else
            "";
      }
    ]
    ++ lib.mapAttrsToList (username: userCfg: {
      assertion = userCfg.initialHashedPassword == null || userCfg.passwordFromSops == null;
      message = "qnix.core.user.users.${username}: Cannot set both 'initialHashedPassword' and 'passwordFromSops'";
    }) cfg.users
    ++ lib.mapAttrsToList (username: userCfg: {
      assertion = userCfg.passwordFromSops == null || sopsSecretExists userCfg.passwordFromSops;
      message =
        if userCfg.passwordFromSops != null then
          "qnix.core.user.users.${username}: sops secret '${userCfg.passwordFromSops}' does not exist. Make sure it's defined in qnix.core.sops.secrets"
        else
          "";
    }) cfg.users
  );
in
lib.mkMerge [
  # Configuration (only when module is enabled)
  (lib.mkIf cfg.enable {
    # Direct attrset merge
    users = {
      mutableUsers = false;
      users = rootUser // convertedUsers;
    };

    # Groups
    # Ensure standard system groups exist (users, audio, video, wheel are standard but ensure they exist)
    users.groups = userGroups // {
      # Ensure users group exists (standard system group, but ensure it's created)
      users = { };
    };
  })
  # Assertions (only when module is enabled)
  {
    assertions = assertion;
  }
]
