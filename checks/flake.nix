{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qnix-modules.url = "path:..";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      qnix-modules,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkLib =
        system:
        let
          pkgs = mkPkgs system;
          qnixLib = qnix-modules.lib {
            lib = nixpkgs.lib;
            inherit pkgs;
          };
        in
        nixpkgs.lib.extend (_final: _prev: qnixLib);
    in
    {
      checks = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          lib = mkLib system;

          nixosEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "base"
                  "server"
                  "workstation"
                  "laptop"
                ];
              })
              {
                qnix = {
                  system.headless = false;
                  services = {
                    openssh.enable = true;
                    fail2ban.enable = true;
                  };
                };

                system.stateVersion = "25.11";

                fileSystems."/" = {
                  device = "none";
                  fsType = "tmpfs";
                };

                boot.isContainer = true;
              }
            ];
          };

          homeEvaluation = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit lib;
            };
            modules = [
              (import ../loader/home.nix {
                inherit lib;
                profiles = [ "base" ];
              })
              {
                home.username = "tester";
                home.homeDirectory = "/tmp/tester";
                home.stateVersion = "25.11";

                qnix = { };
              }
            ];
          };
        in
        {
          lib-evaluates = pkgs.runCommand "lib-evaluates" { } ''
            test "${if builtins.hasAttr "getQnixConfig" lib.qnix then "yes" else "no"}" = "yes"
            touch $out
          '';

          lib-qnix-available = pkgs.runCommand "lib-qnix-available" { } ''
            test "${if builtins.hasAttr "firstExistingPackageOr" lib.qnix then "yes" else "no"}" = "yes"
            touch $out
          '';

          nixos-loader-evaluates = nixosEvaluation.config.system.build.toplevel;

          home-loader-evaluates = homeEvaluation.activationPackage;
        }
      );
    };
}
