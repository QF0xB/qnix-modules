{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    qnix-modules.url = "path:..";
  };

  outputs =
    { nixpkgs, qnix-modules, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qnix = qnix-modules.lib.mkQNix {
        context = {
          hostname = "check";
        };
      };

      testOptions = {
        options = {
          services.xserver.xkb.layout = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.str;
          };
          services.xserver.xkb.variant = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.str;
          };
          console.useXkbConfig = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.bool;
          };
          time.timeZone = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.str;
          };
          i18n.supportedLocales = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.listOf nixpkgs.lib.types.str;
          };
          i18n.extraLocaleSettings = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.attrsOf nixpkgs.lib.types.str;
          };

          qnix.persist.users."*".directories = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.listOf nixpkgs.lib.types.str;
            default = [ ];
          };
        };
      };

      fishFeature = qnix.features."shell.fish";
      shellPackagesFeature = qnix.features."shell.packages";
      persistFeature = qnix.features.persist;
      impermanenceFeature = qnix.features."storage.impermanence";

      homePackageTestOptions = {
        options.home.packages = nixpkgs.lib.mkOption {
          type = nixpkgs.lib.types.listOf nixpkgs.lib.types.package;
          default = [ ];
        };
      };

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
              users."tester" = {
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
        let
          evaluation = nixpkgs.lib.evalModules {
            modules = persistFeature.optionModules ++ [
              {
                qnix.persist.root.directories = [ "/home/invalid" ];
              }
            ];
          };
        in
        evaluation.config.qnix.persist.root.directories
      );

      impermanenceTestOptions = {
        options = {
          users.users = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.attrsOf nixpkgs.lib.types.attrs;
            default = {
              tester = { };
            };
          };

          fileSystems = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.attrsOf (
              nixpkgs.lib.types.submodule {
                options.neededForBoot = nixpkgs.lib.mkOption {
                  type = nixpkgs.lib.types.bool;
                  default = false;
                };
              }
            );
            default = { };
          };

          services.journald.storage = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.str;
            default = "volatile";
          };

          environment.persistence = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.attrsOf (
              nixpkgs.lib.types.submodule {
                options = {
                  hideMounts = nixpkgs.lib.mkOption {
                    type = nixpkgs.lib.types.bool;
                    default = false;
                  };
                  files = nixpkgs.lib.mkOption {
                    type = nixpkgs.lib.types.listOf nixpkgs.lib.types.str;
                    default = [ ];
                  };
                  directories = nixpkgs.lib.mkOption {
                    type = nixpkgs.lib.types.listOf nixpkgs.lib.types.str;
                    default = [ ];
                  };
                  users = nixpkgs.lib.mkOption {
                    type = nixpkgs.lib.types.attrsOf (
                      nixpkgs.lib.types.submodule {
                        options = {
                          files = nixpkgs.lib.mkOption {
                            type = nixpkgs.lib.types.listOf nixpkgs.lib.types.str;
                            default = [ ];
                          };
                          directories = nixpkgs.lib.mkOption {
                            type = nixpkgs.lib.types.listOf nixpkgs.lib.types.str;
                            default = [ ];
                          };
                        };
                      }
                    );
                    default = { };
                  };
                };
              }
            );
            default = { };
          };

          environment.etc = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.attrsOf (
              nixpkgs.lib.types.submodule {
                options.source = nixpkgs.lib.mkOption {
                  type = nixpkgs.lib.types.path;
                };
              }
            );
            default = { };
          };
        };
      };

      impermanenceEvaluation = nixpkgs.lib.evalModules {
        specialArgs = { inherit pkgs; };
        modules = [ impermanenceTestOptions ] ++ persistFeature.optionModules ++ impermanenceFeature.optionModules ++ impermanenceFeature.nixosModules ++ [
          {
            users.users.tester = { };
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
            qnix.storage.impermanence.enable = true;
          }
        ];
      };

      impermanenceManifest = builtins.fromJSON (
        builtins.readFile impermanenceEvaluation.config.environment.etc."impermanence.json".source
      );

      fishPersistenceEvaluation = nixpkgs.lib.evalModules {
        modules = [ testOptions ] ++ fishFeature.optionModules ++ fishFeature.nixosModules;
      };

      shellPackagesEvaluation = nixpkgs.lib.evalModules {
        specialArgs = { inherit pkgs; };
        modules = [ homePackageTestOptions ] ++ shellPackagesFeature.optionModules ++ (shellPackagesFeature.__homeModuleFor "standalone-home") ++ [
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
        ];
      };

      impermanenceHomeEvaluation = nixpkgs.lib.evalModules {
        specialArgs = { inherit pkgs; };
        modules = [ homePackageTestOptions ] ++ shellPackagesFeature.optionModules ++ impermanenceFeature.optionModules ++ (shellPackagesFeature.__homeModuleFor "standalone-home") ++ (impermanenceFeature.__homeModuleFor "standalone-home") ++ [
          {
            qnix.storage.impermanence.enable = true;
          }
        ];
      };

      defaultEvaluation = nixpkgs.lib.evalModules {
        modules = [ testOptions ] ++ qnix.modulesFor.nixos [ "base" ];
      };

      impermanenceProfileEvaluation = nixpkgs.lib.evalModules {
        specialArgs = { inherit pkgs; };
        modules = [ impermanenceTestOptions ] ++ qnix.modulesFor.nixos [ "impermanence" ];
      };

      overrideEvaluation = nixpkgs.lib.evalModules {
        modules = [
          testOptions
          {
            qnix.system.localisation = {
              timezone = "UTC";
              xkb.layout = "us";
            };
          }
        ]
        ++ qnix.modulesFor.nixos [ "base" ];
      };
    in
    {
      checks.${system}.default =
        assert qnix.featureNames == [ "persist" "shell.fish" "shell.packages" "storage.impermanence" "system.localisation" ];
        assert qnix.profileNames == [ "base" "impermanence" ];
        assert impermanenceProfileEvaluation.config.qnix.storage.impermanence.enable;
        assert impermanenceProfileEvaluation.config.qnix.persist.root.directories == [ "/var/lib/nixos" ];
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
        assert shellPackagesFeature.supportedEnvironments == [ "integrated-home" "standalone-home" ];
        assert builtins.length shellPackagesEvaluation.config.home.packages == 3;
        assert impermanenceFeature.supportedEnvironments == [ "nixos" "integrated-home" "standalone-home" ];
        assert impermanenceEvaluation.config.fileSystems."/persist".neededForBoot;
        assert impermanenceEvaluation.config.fileSystems."/cache".neededForBoot;
        assert impermanenceEvaluation.config.services.journald.storage == "persistent";
        assert impermanenceEvaluation.config.environment.persistence."/persist".directories == [ "/var/lib/nixos" "/var/lib/example" ];
        assert impermanenceEvaluation.config.environment.persistence."/cache".directories == [ "/var/log" "/var/log/journal" "/var/cache/example" ];
        assert impermanenceEvaluation.config.environment.persistence."/persist".files == [ "/etc/example.conf" ];
        assert impermanenceEvaluation.config.environment.persistence."/cache".files == [ "/var/cache/example.state" ];
        assert impermanenceEvaluation.config.environment.persistence."/persist".users.tester.directories == [ "Projects" ".ssh" ".local/share/example" ];
        assert impermanenceEvaluation.config.environment.persistence."/persist".users.tester.files == [ ".config/example.conf" ];
        assert impermanenceEvaluation.config.environment.persistence."/cache".users.tester.directories == [ ".cache" ".gradle" ".cache/example" ];
        assert impermanenceEvaluation.config.environment.persistence."/cache".users.tester.files == [ ".cache/example.state" ".cache/tester.state" ];
        assert impermanenceEvaluation.config.environment.persistence."/persist".users.alice.directories == [ "Projects" ".ssh" ".local/share/example" "alice-data" ];
        assert impermanenceEvaluation.config.environment.persistence."/cache".users.alice.directories == [ ".cache" ".gradle" ".cache/example" ];
        assert impermanenceEvaluation.config.environment.etc."impermanence.json".source != null;
        assert builtins.length impermanenceHomeEvaluation.config.home.packages == 1;
        assert builtins.hasAttr "show-root-filesystem" impermanenceHomeEvaluation.config.qnix.shell.packages.packages;
        assert builtins.elem "/var/lib/nixos" impermanenceManifest.directories;
        assert builtins.elem "/etc/example.conf" impermanenceManifest.files;
        assert builtins.elem "/home/tester/.local/share/example" impermanenceManifest.directories;
        assert builtins.elem "/home/tester/.cache/tester.state" impermanenceManifest.files;
        assert builtins.elem "/home/alice/alice-data" impermanenceManifest.directories;
        assert fishFeature.supportedEnvironments == [ "nixos" "integrated-home" "standalone-home" ];
        assert
          fishPersistenceEvaluation.config.qnix.persist.users."*".directories
          == [ ".local/share/fish" ];
        assert defaultEvaluation.config.qnix.system.localisation.enable;
        assert defaultEvaluation.config.time.timeZone == "Europe/Berlin";
        assert defaultEvaluation.config.services.xserver.xkb.layout == "de";
        assert defaultEvaluation.config.console.useXkbConfig;
        assert overrideEvaluation.config.time.timeZone == "UTC";
        assert overrideEvaluation.config.services.xserver.xkb.layout == "us";
        pkgs.runCommand "qnix-modules-check" { } "touch $out";
    };
}
