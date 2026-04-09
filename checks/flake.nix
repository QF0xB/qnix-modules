{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
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
      stylix,
      noctalia-shell,
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

          commonSystemModule = {
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
          };

          testUserModule = {
            qnix.system.users.users.tester = {
              kind = "normal";
              group = "tester";
              home = "/home/tester";
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEexampleexampleexampleexampleexample tester@example"
              ];
            };
          };

          impermanenceTestModule = {
            qnix.storage.impermanence.enable = true;
            qnix.persist.users."*" = {
              directories = [ ".config/nvim" ];
              files = [ ".zsh_history" ];
            };
          };

          nixosServerEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "server"
                ];
              })
              commonSystemModule
              testUserModule
              {
                qnix.network.addressing = {
                  hostName = "server-test";
                  nameservers = [
                    "1.1.1.1"
                    "9.9.9.9"
                  ];
                  defaultGateway = "192.0.2.1";
                  defaultGatewayInterface = "eth0";
                  interfaces.eth0 = {
                    useDHCP = false;
                    ipv4.addresses = [
                      {
                        address = "192.0.2.10";
                        prefixLength = 24;
                      }
                    ];
                  };
                };
              }
            ];
          };

          nixosClientEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "creator"
                  "dev"
                  "hyprland"
                  "personal"
                  "stylix"
                  "impermanence"
                ];
              })
              commonSystemModule
              testUserModule
              impermanenceTestModule
              {
                qnix.security.gpg.enable = true;
                qnix.security.yubikey = {
                  gui = true;
                  login = false;
                  sudo = false;
                };
                qnix.dev = {
                  direnv.enable = true;
                  nh.enable = true;
                };
                qnix.network.networkmanager.extraPlugins = [ "networkmanager-openvpn" ];
                qnix.system.shell = {
                  enable = true;
                };
              }
            ];
          };

          nixosLaptopEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "creator"
                  "dev"
                  "hyprland"
                  "personal"
                  "stylix"
                  "impermanence"
                  "laptop"
                ];
              })
              commonSystemModule
              testUserModule
              impermanenceTestModule
              {
                qnix.security.gpg.enable = true;
                qnix.security.yubikey = {
                  gui = true;
                  login = false;
                  sudo = false;
                };
                qnix.dev = {
                  direnv.enable = true;
                  nh.enable = true;
                };
                qnix.system.shell = {
                  enable = true;
                  projectRoot = "/tmp/qnix";
                };
              }
            ];
          };

          homeOnlyEvaluation = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit qnixLib;
              qnixHomeStandalone = true;
            };
            modules = [
              stylix.homeModules.stylix
              noctalia-shell.homeModules.default
              (import ../loader/home.nix {
                lib = nixpkgs.lib;
                profiles = [
                  "creator"
                  "dev"
                  "hyprland"
                  "personal"
                  "stylix"
                ];
              })
              {
                home.username = "tester";
                home.homeDirectory = "/tmp/tester";
                home.stateVersion = "25.11";
                qnix.security.gpg.enable = true;
                qnix.dev.direnv.enable = true;
                qnix.system.shell = {
                  enable = true;
                  projectRoot = "/tmp/qnix";
                };
              }
            ];
          };

          homeOnlyServerEvaluation = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit qnixLib;
              qnixHomeStandalone = true;
            };
            modules = [
              stylix.homeModules.stylix
              noctalia-shell.homeModules.default
              (import ../loader/home.nix {
                lib = nixpkgs.lib;
                profiles = [
                  "server"
                ];
              })
              {
                home.username = "tester";
                home.homeDirectory = "/tmp/tester";
                home.stateVersion = "25.11";
              }
            ];
          };

          homeOnlyLaptopEvaluation = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit qnixLib;
              qnixHomeStandalone = true;
            };
            modules = [
              stylix.homeModules.stylix
              noctalia-shell.homeModules.default
              (import ../loader/home.nix {
                lib = nixpkgs.lib;
                profiles = [
                  "creator"
                  "dev"
                  "hyprland"
                  "laptop"
                  "personal"
                  "stylix"
                ];
              })
              {
                home.username = "tester";
                home.homeDirectory = "/tmp/tester";
                home.stateVersion = "25.11";
                qnix.security.gpg.enable = true;
                qnix.dev.direnv.enable = true;
                qnix.system.shell = {
                  enable = true;
                  projectRoot = "/tmp/qnix";
                };
              }
            ];
          };

          nixosWithHomeEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "creator"
                  "dev"
                  "hyprland"
                  "personal"
                  "stylix"
                  "impermanence"
                ];
              })

              home-manager.nixosModules.home-manager

              commonSystemModule
              testUserModule
              impermanenceTestModule
              {
                qnix.security.gpg.enable = true;
                qnix.security.yubikey = {
                  gui = true;
                  login = false;
                  sudo = false;
                };
                qnix.dev = {
                  direnv.enable = true;
                  nh.enable = true;
                };
                qnix.system.shell = {
                  enable = true;
                  projectRoot = "/tmp/qnix";
                };

                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  sharedModules = [
                    noctalia-shell.homeModules.default
                  ];
                  extraSpecialArgs = {
                    inherit qnixLib;
                    qnixHomeStandalone = false;
                  };

                  users.tester = {
                    imports = [
                      (import ../loader/home.nix {
                        lib = nixpkgs.lib;
                        profiles = [
                          "creator"
                          "dev"
                          "hyprland"
                          "personal"
                          "stylix"
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

          nixos-server-evaluates = nixosServerEvaluation.config.system.build.toplevel;

          nixos-server-network-defaults = pkgs.runCommand "nixos-server-network-defaults" { } ''
            test "${if nixosServerEvaluation.config.qnix.network.networkmanager.enable then "yes" else "no"}" = "no"
            test "${if nixosServerEvaluation.config.networking.networkmanager.enable then "yes" else "no"}" = "no"
            test "${nixosServerEvaluation.config.networking.hostName}" = "server-test"
            touch $out
          '';

          nixos-client-evaluates = nixosClientEvaluation.config.system.build.toplevel;

          nixos-laptop-evaluates = nixosLaptopEvaluation.config.system.build.toplevel;

          nixos-laptop-defaults = pkgs.runCommand "nixos-laptop-defaults" { } ''
            test "${if nixosLaptopEvaluation.config.qnix.status.laptop then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.qnix.system.power-management.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.services.upower.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.services.tuned.enable then "yes" else "no"}" = "yes"
            touch $out
          '';


          home-manager-client-evaluates = homeOnlyEvaluation.activationPackage;

          home-manager-server-status-defaults = pkgs.runCommand "home-manager-server-status-defaults" { } ''
            test "${if homeOnlyServerEvaluation.config.qnix.status.server then "yes" else "no"}" = "yes"
            test "${if homeOnlyServerEvaluation.config.qnix.status.headless then "yes" else "no"}" = "yes"
            touch $out
          '';

          home-manager-laptop-status-defaults = pkgs.runCommand "home-manager-laptop-status-defaults" { } ''
            test "${if homeOnlyLaptopEvaluation.config.qnix.status.laptop then "yes" else "no"}" = "yes"
            touch $out
          '';

          hyprland-profile-defaults = pkgs.runCommand "hyprland-profile-defaults" { } ''
            test "${if nixosClientEvaluation.config.qnix.desktop.wayland.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.hyprland.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.displaymanager.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.displaymanager.sddm.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.stylix.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.terminal.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.noctalia.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.browser.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.fileManager.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.lock.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.notes.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.bitwarden.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.music.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.obs.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.programs.hyprland.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.xdg.portal.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.services.displayManager.sddm.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.stylix.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.wayland.windowManager.hyprland.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.stylix.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.programs.kitty.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.programs.noctalia-shell.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.notes.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.bitwarden.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.music.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.obs.enable then "yes" else "no"}" = "yes"
            test "${homeOnlyEvaluation.config.home.sessionVariables.NIXOS_OZONE_WL}" = "1"
            touch $out
          '';

          nixos-and-home-manager-client-evaluates = nixosWithHomeEvaluation.config.system.build.toplevel;
        }
      );
    };
}
