{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qnix-modules.url = "path:..";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      impermanence,
      sops-nix,
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
          qnixLib = qnix-modules.lib {
            lib = nixpkgs.lib;
            inherit pkgs;
          };

          nixosOnlyEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "base"
                  "server"
                  "workstation"
                  "laptop"
                  "impermanence"
                ];
              })
              {
                system.stateVersion = "25.11";
                fileSystems."/" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                fileSystems."/persist" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                fileSystems."/cache" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                boot.isContainer = true;
                networking.hostId = "12345678";
                qnix.security.sops = {
                  enable = true;
                  defaultSopsFile = builtins.toFile "dummy-secrets.yaml" ''
                    {}
                  '';
                  age = {
                    generateKey = false;
                    keyFile = "/tmp/dummy-age-key.txt";
                  };
                  secrets = { };
                };
                qnix.system.users.users.tester = {
                  kind = "normal";
                  home = "/home/tester";
                  extraGroups = [ "wheel" ];
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEexampleexampleexampleexampleexample tester@example"
                  ];
                };
                qnix.storage.impermanence.enable = true;
                qnix.persist.users."*" = {
                  directories = [ ".config/nvim" ];
                  files = [ ".zsh_history" ];
                };
              }
            ];
          };

          homeOnlyEvaluation = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit qnixLib;
            };
            modules = [
              (import ../loader/home.nix {
                lib = nixpkgs.lib;
                profiles = [
                  "base"
                  "workstation"
                ];
              })
              {
                home.username = "tester";
                home.homeDirectory = "/tmp/tester";
                home.stateVersion = "25.11";
                qnix.security.gpg.enable = true;
              }
            ];
          };

          nixosWithHomeEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "base"
                  "workstation"
                ];
              })

              home-manager.nixosModules.home-manager

              {
                system.stateVersion = "25.11";
                fileSystems."/" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                fileSystems."/persist" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                fileSystems."/cache" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                boot.isContainer = true;
                networking.hostId = "12345678";

                qnix.security.sops = {
                  enable = true;
                  defaultSopsFile = builtins.toFile "dummy-secrets.yaml" ''
                    {}
                  '';
                  age = {
                    generateKey = false;
                    keyFile = "/tmp/dummy-age-key.txt";
                  };
                  secrets = { };
                };

                qnix.security.gpg.enable = true;

                qnix.system.users.users.tester = {
                  kind = "normal";
                  group = "tester";
                  home = "/home/tester";
                  extraGroups = [ "wheel" ];
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEexampleexampleexampleexampleexample tester@example"
                  ];
                };

                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit qnixLib;
                  };

                  users.tester = {
                    imports = [
                      (import ../loader/home.nix {
                        lib = nixpkgs.lib;
                        profiles = [
                          "base"
                          "workstation"
                        ];
                      })
                    ];

                    home.username = lib.mkForce "tester";
                    home.homeDirectory = lib.mkForce "/home/tester";
                    home.stateVersion = lib.mkForce "25.11";
                  };
                };
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

          nixos-only-evaluates = nixosOnlyEvaluation.config.system.build.toplevel;

          home-manager-only-evaluates = homeOnlyEvaluation.activationPackage;

          nixos-and-home-manager-evaluates = nixosWithHomeEvaluation.config.system.build.toplevel;
        }
      );
    };
}
