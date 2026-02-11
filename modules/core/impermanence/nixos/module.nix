{
  lib,
  pkgs,
  config,
  user,
  ...
}:

let
  cfg = config.qnix.core.impermanence;
  persist = config.qnix.persist;

  # Create impermanence.json after environment.persistence is merged
  # Extract directory paths from impermanence's directory attribute sets
  # (impermanence converts strings to attribute sets, we need to extract the path)
  getDirPath =
    dir:
    if lib.isString dir then
      dir
    else if lib.isAttrs dir && dir ? directory then
      dir.directory
    else if lib.isAttrs dir && dir ? dirPath then
      dir.dirPath
    else
      toString dir;

  getFilePath =
    file:
    if lib.isString file then
      file
    else if lib.isAttrs file && file ? filePath then
      file.filePath
    else
      toString file;

  # Build paths from our own persist options (lists), not from evaluated persistence config
  rootDirs =
    (
      if persist.root.defaultFolders then
        [
          "/var/log"
          "/var/lib/nixos"
        ]
      else
        [ ]
    )
    ++ persist.root.directories
    ++ persist.root.cache.directories;
  rootFiles = persist.root.files ++ persist.root.cache.files;
  homeDirs =
    (
      if persist.home.defaultFolders then
        [
          "projects"
          ".cache/dconf"
          ".config/dconf"
          ".ssh"
        ]
      else
        [ ]
    )
    ++ persist.home.directories
    ++ persist.home.cache.directories;
  homeFiles = persist.home.files ++ persist.home.cache.files;

  homeDirPaths = lib.map (
    d:
    "/home/${user}/"
    + (if lib.hasPrefix "/" (toString d) then lib.removePrefix "/" (toString d) else toString d)
  ) homeDirs;
  homeFilePaths = lib.map (
    f:
    "/home/${user}/"
    + (if lib.hasPrefix "/" (toString f) then lib.removePrefix "/" (toString f) else toString f)
  ) homeFiles;

  impermanenceJson = pkgs.writeText "impermanence.json" (
    lib.strings.toJSON {
      directories = lib.unique (rootDirs ++ homeDirPaths);
      files = lib.unique (rootFiles ++ homeFilePaths);
    }
  );
in
{
  config = lib.mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/cache".neededForBoot = true;

    environment.persistence = {
      "/persist" = {
        hideMounts = true;
        files = lib.unique persist.root.files;
        directories = lib.unique (
          (
            if persist.root.defaultFolders then
              [
                "/var/log"
                "/var/lib/nixos"
              ]
            else
              [ ]
          )
          ++ persist.root.directories
        );

        users.${user} = {
          files = lib.unique persist.home.files;
          directories = lib.unique (
            (
              if persist.home.defaultFolders then
                [
                  "projects"
                  ".cache/dconf"
                  ".config/dconf"
                  ".ssh"
                ]
              else
                [ ]
            )
            ++ persist.home.directories
          );
        };
      };

      # Not backed up; Still persisted
      "/cache" = {
        hideMounts = true;
        files = lib.unique persist.root.cache.files;
        directories = lib.unique persist.root.cache.directories;

        users.${user} = {
          files = lib.unique persist.home.cache.files;
          directories = lib.unique persist.home.cache.directories;
        };
      };
    };

    environment.etc."impermanence.json".source = impermanenceJson;

    qnix.core.shell.packages = {
      show-root-files = {
        runtimeInputs = [
          pkgs.fd
          pkgs.jq
        ];
        text = ''
          # Exclude persisted dirs and files from impermanence.json so we only list ephemeral content
          exclude_args=()
          if [[ -f /etc/impermanence.json ]]; then
            while IFS= read -r path; do
              [[ -n "$path" ]] && exclude_args+=(--exclude "$path")
            done < <(jq -r '.directories[], .files[]' /etc/impermanence.json 2>/dev/null)
          fi
          sudo fd --one-file-system --base-directory / --type f --hidden \
            "''${exclude_args[@]}" \
            --exclude "/etc/{ssh,passwd,shadow}" \
            --exclude "*.timer" \
            --exclude "/var/lib/NetworkManager" \
            --exclude "/var/lib/sddm/.cache/" \
            --exclude "/root/.cache" \
            --exclude "${config.hm.xdg.cacheHome}/{bat,fontconfig,mesa_shader_cache,mpv,nvim,pre-commit,radv_builtin_shaders,fish,nvf,nix}" \
            --exec ls -lS | sort -rn -k5 | awk '{print $5, $9}'
        '';
      };
    };
  };
}
