{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  requires = {
    nixos = [ "persist" ];
    home = [ "shell.packages" ];
  };

  nixos =
    {
      cfg,
      config,
      lib,
      pkgs,
      qcfg,
      ...
    }:
    let
      persist = config.qnix.persist;
      wildcardUser = persist.users."*" or { };

      mergeUser =
        username:
        let
          specificUser = persist.users.${username} or { };
        in
        {
          persistFiles = lib.unique ((wildcardUser.files or [ ]) ++ (specificUser.files or [ ]));
          persistDirectories = lib.unique (
            (wildcardUser.directories or [ ]) ++ (specificUser.directories or [ ])
          );
          cacheFiles = lib.unique (
            (wildcardUser.cache.files or [ ]) ++ (specificUser.cache.files or [ ])
          );
          cacheDirectories = lib.unique (
            (wildcardUser.cache.directories or [ ]) ++ (specificUser.cache.directories or [ ])
          );
        };

      managedUserNames = lib.unique (
        (lib.attrNames config.users.users)
        ++ (lib.remove "*" (lib.attrNames persist.users))
      );
      managedUsers = lib.genAttrs managedUserNames mergeUser;

      userPaths =
        username: userCfg:
        {
          persistFiles = map (path: "/home/${username}/${lib.removePrefix "/" path}") userCfg.persistFiles;
          persistDirectories = map (path: "/home/${username}/${lib.removePrefix "/" path}") userCfg.persistDirectories;
          cacheFiles = map (path: "/home/${username}/${lib.removePrefix "/" path}") userCfg.cacheFiles;
          cacheDirectories = map (path: "/home/${username}/${lib.removePrefix "/" path}") userCfg.cacheDirectories;
        };

      expandedUsers = lib.mapAttrs userPaths managedUsers;
      allUserPaths = lib.attrValues expandedUsers;

      impermanenceJson = pkgs.writeText "impermanence.json" (builtins.toJSON {
        directories = lib.unique (
          persist.root.directories
          ++ persist.root.cache.directories
          ++ lib.concatMap (user: user.persistDirectories ++ user.cacheDirectories) allUserPaths
        );
        files = lib.unique (
          persist.root.files
          ++ persist.root.cache.files
          ++ lib.concatMap (user: user.persistFiles ++ user.cacheFiles) allUserPaths
        );
      });

    in
    {
      qnix.persist.root.directories = lib.mkBefore [ "/var/lib/nixos" ];
      qnix.persist.root.cache.directories = lib.mkBefore [
        "/var/log"
        "/var/log/journal"
      ];
      qnix.persist.users."*" = {
        directories = lib.mkBefore [
          "Projects"
          ".ssh"
        ];
        cache.directories = lib.mkBefore [
          ".cache"
          ".gradle"
        ];
      };

      fileSystems."/persist".neededForBoot = true;
      fileSystems."/cache".neededForBoot = true;

      services.journald.storage = "persistent";

      environment.persistence = {
        "/persist" = {
          hideMounts = true;
          allowTrash = true;
          files = persist.root.files;
          directories = persist.root.directories;
          users = lib.mapAttrs (_: user: {
            files = user.persistFiles;
            directories = user.persistDirectories;
          }) managedUsers;
        };

        "/cache" = {
          hideMounts = true;
          allowTrash = true;
          files = persist.root.cache.files;
          directories = persist.root.cache.directories;
          users = lib.mapAttrs (_: user: {
            files = user.cacheFiles;
            directories = user.cacheDirectories;
          }) managedUsers;
        };
      };

      environment.etc."impermanence.json".source = impermanenceJson;

    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      qnix.shell.packages.packages.show-root-filesystem = {
        runtimeInputs = with pkgs; [
          fd
          jq
          coreutils
          gnugrep
          gawk
        ];
        text = ''
          exclude_args=()

          if [[ -f /etc/impermanence.json ]]; then
            while IFS= read -r path; do
              [[ -n "$path" ]] && exclude_args+=(--exclude "$path")
            done < <(jq -r '.directories[], .files[]' /etc/impermanence.json 2>/dev/null)
          fi

          sudo fd \
            --one-file-system \
            --base-directory / \
            --type f \
            --hidden \
            "''${exclude_args[@]}" \
            --exclude "/etc/{ssh,passwd,shadow}" \
            --exclude "/var/cache/man" \
            --exclude "*.timer" \
            --exclude "/var/lib/NetworkManager" \
            --exclude "/var/lib/sddm/.cache/" \
            --exclude "/root/.cache" \
            --exec stat --printf='%s %n\n' \
          | sort -rn -k1 \
          | awk '{ print $1, $2 }'
        '';
      };
    };
}
