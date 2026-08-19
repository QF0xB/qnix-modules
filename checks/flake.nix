{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    qnix-modules.url = "path:..";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      impermanence,
      qnix-modules,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qnix = qnix-modules.lib.mkQNix {
        context.hostname = "check";
      };

      mkNixos = modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs; };
          modules = [ { system.stateVersion = "26.11"; } ] ++ modules;
        };

      mkHome = modules:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit pkgs; };
          modules = [
            {
              home.username = "check";
              home.homeDirectory = "/home/check";
              home.stateVersion = "26.11";
            }
          ] ++ modules;
        };

      persistFeature = qnix.features.persist;
      fishFeature = qnix.features."shell.fish";
      shellPackagesFeature = qnix.features."shell.packages";
      starshipFeature = qnix.features."shell.starship";
      zshFeature = qnix.features."shell.zsh";
      userFeature = qnix.features."system.users";
      impermanenceFeature = qnix.features."storage.impermanence";

      persistEvaluation = nixpkgs.lib.evalModules {
        modules = persistFeature.optionModules;
      };

      persistConfiguredEvaluation = nixpkgs.lib.evalModules {
        modules = persistFeature.optionModules ++ [
          {
            qnix.persist = {
              root = {
                directories = [ "/var/lib/example" ];
                files = [ "/etc/example.conf" ];
                cache.directories = [ "/var/cache/example" ];
                cache.files = [ "/var/cache/example.state" ];
              };
              users.tester = {
                directories = [ ".local/share/example" ];
                files = [ ".config/example.conf" ];
                cache.directories = [ ".cache/example" ];
                cache.files = [ ".cache/example.state" ];
              };
            };
          }
        ];
      };

      invalidPersistPath = builtins.tryEval (
        (nixpkgs.lib.evalModules {
          modules = persistFeature.optionModules ++ [
            { qnix.persist.root.directories = [ "/home/invalid" ]; }
          ];
        }).config.qnix.persist.root.directories
      );

      impermanenceFileSystems = {
        fileSystems."/persist" = {
          device = "/dev/test-persist";
          fsType = "ext4";
        };
        fileSystems."/cache" = {
          device = "/dev/test-cache";
          fsType = "ext4";
        };
      };

      impermanenceEvaluation = mkNixos (
        [ impermanence.nixosModules.impermanence ]
        ++ qnix.modulesFor.nixos [ "impermanence" ]
        ++ [
          impermanenceFileSystems
          {
            qnix.persist = {
              root = {
                directories = [ "/var/lib/example" ];
                files = [ "/etc/example.conf" ];
                cache.directories = [ "/var/cache/example" ];
                cache.files = [ "/var/cache/example.state" ];
              };
              users = {
                "*" = {
                  directories = [ ".local/share/example" ];
                  files = [ ".config/example.conf" ];
                  cache.directories = [ ".cache/example" ];
                  cache.files = [ ".cache/example.state" ];
                };
                tester.cache.files = [ ".cache/tester.state" ];
                alice.directories = [ "alice-data" ];
              };
            };
            qnix.system.users.users.tester = { };
            qnix.storage.impermanence.enable = true;
          }
        ]
      );

      impermanenceManifest = builtins.fromJSON (
        builtins.readFile impermanenceEvaluation.config.environment.etc."impermanence.json".source
      );
      directoryPaths = map (entry: entry.directory);
      filePaths = map (entry: entry.file);

      userEvaluation = mkNixos (
        userFeature.optionModules
        ++ userFeature.nixosModules
        ++ [
          {
            qnix.system.users = {
              defaultExtraGroups = [ "wheel" ];
              defaultShell = "bash";
              root.enable = true;
              users.alice = {
                extraGroups = [ "audio" ];
                home = "/home/alice";
                description = "Alice";
                shell = "zsh";
                openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA alice" ];
              };
              users.service = {
                kind = "system";
                group = "svc";
              };
            };
          }
        ]
      );

      fishNixosEvaluation = mkNixos (
        persistFeature.optionModules ++ fishFeature.optionModules ++ fishFeature.nixosModules
      );
      fishHomeEvaluation = mkHome (fishFeature.optionModules ++ fishFeature.__homeModuleFor "standalone-home");

      shellPackagesEvaluation = mkHome (
        shellPackagesFeature.optionModules
        ++ shellPackagesFeature.__homeModuleFor "standalone-home"
        ++ [
          {
            qnix.shell.packages.packages = {
              derivation = pkgs.writeText "shell-package-derivation" "derivation";
              string = "printf '%s\\n' string";
              attrset = {
                runtimeInputs = [ pkgs.coreutils ];
                text = "printf '%s\\n' attrset";
              };
            };
          }
        ]
      );

      starshipEvaluation = mkHome (
        starshipFeature.optionModules
        ++ starshipFeature.__homeModuleFor "standalone-home"
        ++ [
          {
            qnix.shell.starship.settings = {
              add_newline = false;
              format = "$directory$character";
            };
          }
        ]
      );

      zshNixosEvaluation = mkNixos (
        persistFeature.optionModules ++ zshFeature.optionModules ++ zshFeature.nixosModules
      );
      zshHomeEvaluation = mkHome (zshFeature.optionModules ++ zshFeature.__homeModuleFor "standalone-home");

      impermanenceHomeEvaluation = mkHome (
        shellPackagesFeature.optionModules
        ++ impermanenceFeature.optionModules
        ++ shellPackagesFeature.__homeModuleFor "standalone-home"
        ++ impermanenceFeature.__homeModuleFor "standalone-home"
        ++ [ { qnix.storage.impermanence.enable = true; } ]
      );

      defaultEvaluation = mkNixos (qnix.modulesFor.nixos [ "base" ]);
      impermanenceProfileEvaluation = mkNixos (
        [ impermanence.nixosModules.impermanence ]
        ++ qnix.modulesFor.nixos [ "impermanence" ]
        ++ [ impermanenceFileSystems ]
      );
      overrideEvaluation = mkNixos (
        qnix.modulesFor.nixos [ "base" ]
        ++ [
          {
            qnix.system.localisation = {
              timezone = "UTC";
              xkb.layout = "us";
            };
          }
        ]
      );
    in
    {
      checks.${system}.default =
        assert qnix.featureNames == [
          "persist"
          "shell.fish"
          "shell.packages"
          "shell.starship"
          "shell.zsh"
          "storage.impermanence"
          "system.localisation"
          "system.users"
        ];
        assert qnix.profileNames == [ "base" "impermanence" ];
        assert persistFeature.supportedEnvironments == [ "nixos" ];
        assert persistEvaluation.config.qnix.persist.root.directories == [ ];
        assert persistEvaluation.config.qnix.persist.users == { };
        assert persistConfiguredEvaluation.config.qnix.persist.root.directories == [ "/var/lib/example" ];
        assert persistConfiguredEvaluation.config.qnix.persist.root.files == [ "/etc/example.conf" ];
        assert persistConfiguredEvaluation.config.qnix.persist.root.cache.directories == [ "/var/cache/example" ];
        assert persistConfiguredEvaluation.config.qnix.persist.root.cache.files == [ "/var/cache/example.state" ];
        assert persistConfiguredEvaluation.config.qnix.persist.users.tester.directories == [ ".local/share/example" ];
        assert persistConfiguredEvaluation.config.qnix.persist.users.tester.files == [ ".config/example.conf" ];
        assert persistConfiguredEvaluation.config.qnix.persist.users.tester.cache.directories == [ ".cache/example" ];
        assert persistConfiguredEvaluation.config.qnix.persist.users.tester.cache.files == [ ".cache/example.state" ];
        assert !invalidPersistPath.success;
        assert impermanenceFeature.supportedEnvironments == [ "nixos" "integrated-home" "standalone-home" ];
        assert impermanenceEvaluation.config.fileSystems."/persist".neededForBoot;
        assert impermanenceEvaluation.config.fileSystems."/cache".neededForBoot;
        assert impermanenceEvaluation.config.services.journald.storage == "persistent";
        assert directoryPaths impermanenceEvaluation.config.environment.persistence."/persist".directories == [ "/var/lib/nixos" "/var/lib/example" ];
        assert directoryPaths impermanenceEvaluation.config.environment.persistence."/cache".directories == [ "/var/log" "/var/log/journal" "/var/cache/example" ];
        assert impermanenceEvaluation.config.environment.persistence."/persist".allowTrash;
        assert impermanenceEvaluation.config.environment.persistence."/cache".allowTrash;
        assert filePaths impermanenceEvaluation.config.environment.persistence."/persist".files == [ "/etc/example.conf" ];
        assert filePaths impermanenceEvaluation.config.environment.persistence."/cache".files == [ "/var/cache/example.state" ];
        assert directoryPaths impermanenceEvaluation.config.environment.persistence."/persist".users.tester.directories == [ "Projects" ".ssh" ".local/share/example" ];
        assert filePaths impermanenceEvaluation.config.environment.persistence."/persist".users.tester.files == [ ".config/example.conf" ];
        assert directoryPaths impermanenceEvaluation.config.environment.persistence."/cache".users.tester.directories == [ ".cache" ".gradle" ".cache/example" ];
        assert filePaths impermanenceEvaluation.config.environment.persistence."/cache".users.tester.files == [ ".cache/example.state" ".cache/tester.state" ];
        assert directoryPaths impermanenceEvaluation.config.environment.persistence."/persist".users.alice.directories == [ "Projects" ".ssh" ".local/share/example" "alice-data" ];
        assert directoryPaths impermanenceEvaluation.config.environment.persistence."/cache".users.alice.directories == [ ".cache" ".gradle" ".cache/example" ];
        assert impermanenceEvaluation.config.environment.etc."impermanence.json".source != null;
        assert builtins.elem "/var/lib/nixos" impermanenceManifest.directories;
        assert builtins.elem "/etc/example.conf" impermanenceManifest.files;
        assert builtins.elem "/home/tester/.local/share/example" impermanenceManifest.directories;
        assert builtins.elem "/home/tester/.cache/tester.state" impermanenceManifest.files;
        assert builtins.elem "/home/alice/alice-data" impermanenceManifest.directories;
        assert fishFeature.supportedEnvironments == [ "nixos" "integrated-home" "standalone-home" ];
        assert fishNixosEvaluation.config.programs.fish.enable;
        assert fishHomeEvaluation.config.programs.fish.enable;
        assert fishNixosEvaluation.config.qnix.persist.users."*".directories == [ ".local/share/fish" ];
        assert shellPackagesFeature.supportedEnvironments == [ "integrated-home" "standalone-home" ];
        assert builtins.hasAttr "derivation" shellPackagesEvaluation.config.qnix.shell.packages.packages;
        assert builtins.hasAttr "string" shellPackagesEvaluation.config.qnix.shell.packages.packages;
        assert builtins.hasAttr "attrset" shellPackagesEvaluation.config.qnix.shell.packages.packages;
        assert starshipFeature.supportedEnvironments == [ "integrated-home" "standalone-home" ];
        assert starshipEvaluation.config.programs.starship.enable;
        assert starshipEvaluation.config.programs.starship.settings.add_newline == false;
        assert starshipEvaluation.config.programs.starship.settings.format == "$directory$character";
        assert zshFeature.supportedEnvironments == [ "nixos" "integrated-home" "standalone-home" ];
        assert zshNixosEvaluation.config.programs.zsh.enable;
        assert zshNixosEvaluation.config.programs.zsh.autosuggestions.enable;
        assert zshNixosEvaluation.config.programs.zsh.syntaxHighlighting.enable;
        assert zshNixosEvaluation.config.programs.zsh.enableCompletion;
        assert zshHomeEvaluation.config.programs.zsh.enable;
        assert zshHomeEvaluation.config.programs.zsh.autosuggestion.enable;
        assert zshNixosEvaluation.config.qnix.persist.users."*".files == [ ".zsh_history" ];
        assert builtins.hasAttr "show-root-filesystem" impermanenceHomeEvaluation.config.qnix.shell.packages.packages;
        assert userFeature.supportedEnvironments == [ "nixos" ];
        assert userEvaluation.config.users.mutableUsers == false;
        assert userEvaluation.config.users.defaultUserShell == pkgs.bash;
        assert userEvaluation.config.users.users.root.isSystemUser;
        assert userEvaluation.config.users.users.alice.isNormalUser;
        assert userEvaluation.config.users.users.alice.group == "alice";
        assert userEvaluation.config.users.users.alice.extraGroups == [ "wheel" "audio" ];
        assert userEvaluation.config.users.users.alice.home == "/home/alice";
        assert userEvaluation.config.users.users.alice.description == "Alice";
        assert userEvaluation.config.users.users.alice.shell == pkgs.zsh;
        assert userEvaluation.config.users.users.alice.openssh.authorizedKeys.keys == [ "ssh-ed25519 AAAA alice" ];
        assert userEvaluation.config.users.users.service.isSystemUser;
        assert userEvaluation.config.users.users.service.group == "svc";
        assert builtins.hasAttr "alice" userEvaluation.config.users.groups;
        assert builtins.hasAttr "svc" userEvaluation.config.users.groups;
        assert impermanenceProfileEvaluation.config.qnix.storage.impermanence.enable;
        assert impermanenceProfileEvaluation.config.qnix.persist.root.directories == [ "/var/lib/nixos" ];
        assert defaultEvaluation.config.qnix.system.localisation.enable;
        assert defaultEvaluation.config.qnix.system.users.defaultExtraGroups == [ "wheel" ];
        assert defaultEvaluation.config.qnix.system.users.defaultShell == "fish";
        assert defaultEvaluation.config.programs.fish.enable;
        assert defaultEvaluation.config.programs.zsh.enable;
        assert defaultEvaluation.config.time.timeZone == "Europe/Berlin";
        assert defaultEvaluation.config.services.xserver.xkb.layout == "de";
        assert defaultEvaluation.config.console.useXkbConfig;
        assert overrideEvaluation.config.time.timeZone == "UTC";
        assert overrideEvaluation.config.services.xserver.xkb.layout == "us";
        pkgs.runCommand "qnix-modules-check" { } "touch $out";
    };
}
