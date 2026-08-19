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

      fishPersistenceEvaluation = nixpkgs.lib.evalModules {
        modules = [ testOptions ] ++ fishFeature.optionModules ++ fishFeature.nixosModules;
      };

      defaultEvaluation = nixpkgs.lib.evalModules {
        modules = [ testOptions ] ++ qnix.modulesFor.nixos [ "base" ];
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
        assert qnix.featureNames == [ "shell.fish" "system.localisation" ];
        assert qnix.profileNames == [ "base" ];
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
