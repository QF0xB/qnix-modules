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
    nvf = {
      url = "github:notashelf/nvf";
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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      stylix,
      noctalia-shell,
      nvf,
      impermanence,
      sops-nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
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
          qnixLib = import ../lib {
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
          qnixLib = import ../lib {
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
                wireguard-client-key: dummy-client-key
                wireguard-home-key: dummy-home-key
                wireguard-gateway-psk: dummy-gateway-psk
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

          # Hyprland profile defaults enable client PR notify; test configs have no GitHub token.
          hyprlandTestDisableClientPrNotifyModule = {
            qnix.desktop.clientPrNotify.enable = lib.mkForce false;
          };

          # Hyprland profile defaults also enable YubiKey login/sudo auth, which
          # requires U2F mappings that these generic eval fixtures do not provide.
          hyprlandTestDisableYubikeyAuthModule = {
            qnix.security.yubikey = {
              login = lib.mkForce false;
              sudo = lib.mkForce false;
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

          nixosCorednsEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "coredns-server"
                ];
              })
              commonSystemModule
              testUserModule
              {
                qnix.network.addressing = {
                  hostName = "coredns-test";
                  nameservers = [
                    "1.1.1.1"
                  ];
                  defaultGateway = "192.0.2.1";
                  defaultGatewayInterface = "eth0";
                  interfaces.eth0 = {
                    useDHCP = false;
                    ipv4.addresses = [
                      {
                        address = "192.0.2.53";
                        prefixLength = 24;
                      }
                    ];
                  };
                };

                qnix.network.coredns.forwardUpstreams = [
                  "1.1.1.1"
                  "9.9.9.9"
                ];
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
              hyprlandTestDisableClientPrNotifyModule
              hyprlandTestDisableYubikeyAuthModule
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

          nixosContainerHostEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              sops-nix.nixosModules.sops

              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "container-host"
                ];
              })
              commonSystemModule
              testUserModule
              {
                qnix.network.addressing.hostName = "container-host-test";
              }
            ];
          };

          nixosWireguardClientEvaluation = lib.nixosSystem {
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
              hyprlandTestDisableClientPrNotifyModule
              hyprlandTestDisableYubikeyAuthModule
              {
                qnix.network.wireguard = {
                  enable = true;
                  openFirewall = true;
                  tunnels.work = {
                    backend = "networkmanager";
                    interfaceName = "wg0";
                    addresses = [ "10.23.42.2/32" ];
                    privateKey.sopsSecret = "wireguard-client-key";
                    listenPort = 51820;
                    peers = {
                      gateway = {
                        publicKey = "xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=";
                        allowedIPs = [
                          "0.0.0.0/0"
                          "::/0"
                        ];
                        endpoint = "vpn.example.test:51820";
                        presharedKey.sopsSecret = "wireguard-gateway-psk";
                        persistentKeepalive = 25;
                      };
                    };
                  };
                  tunnels.home = {
                    backend = "networkmanager";
                    interfaceName = "wg1";
                    addresses = [ "10.77.0.2/32" ];
                    privateKey.sopsSecret = "wireguard-home-key";
                    peers.gateway = {
                      publicKey = "4JfGkH9b5j+3JZfd7bZ5g6bQpTjKWxJ2grdM9GCBqDQ=";
                      allowedIPs = [ "10.77.0.0/24" ];
                      endpoint = "home.example.test:51820";
                    };
                  };
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
              hyprlandTestDisableClientPrNotifyModule
              hyprlandTestDisableYubikeyAuthModule
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

          nixosBackupEvaluation = lib.nixosSystem {
            inherit pkgs lib;
            modules = [
              sops-nix.nixosModules.sops
            ]
            ++ (lib.qnix.mkNixosOptionImports {
              category = "dev";
              name = "git";
            })
            ++ [
              (import ../loader/nixos.nix {
                inherit lib;
                profiles = [
                  "workstation"
                ];
              })
              commonSystemModule
              testUserModule
              {
                qnix.storage.backup = {
                  enable = true;
                  targets = {
                    borg = {
                      us = {
                        enable = true;
                        repo = "tester@us.repo.borgbase.com:repo";
                        sshKeyPath = "/run/keys/borgbase-us";
                        encryption.sopsSecretName = "borgbase-us-passphrase";
                      };

                      eu = {
                        enable = true;
                        repo = "tester@eu.repo.borgbase.com:repo";
                        sshKeyPath = "/run/keys/borgbase-eu";
                        encryption.sopsSecretName = "borgbase-eu-passphrase";
                      };
                    };

                    nfs = {
                      home = {
                        enable = true;
                        repo = "/mnt/backup-nfs/tester";
                        mount.what = "nas:/srv/backup";
                        encryption.sopsSecretName = "nfs-passphrase";
                      };
                    };
                  };
                };

                qnix.security.sops = {
                  enable = true;
                  defaultSopsFile = builtins.toFile "dummy-secrets.yaml" ''
                    {}
                  '';
                  age = {
                    generateKey = false;
                    keyFile = "/tmp/dummy-age-key.txt";
                  };
                  secrets = {
                    borgbase-us-passphrase = { };
                    borgbase-eu-passphrase = { };
                    nfs-passphrase = { };
                  };
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
              nvf.homeManagerModules.default
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
                qnix.desktop.clientPrNotify.enable = lib.mkForce false;
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
              nvf.homeManagerModules.default
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
              nvf.homeManagerModules.default
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
                qnix.desktop.clientPrNotify.enable = lib.mkForce false;
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
              hyprlandTestDisableClientPrNotifyModule
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
                    nvf.homeManagerModules.default
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
            test "${
              if nixosServerEvaluation.config.qnix.network.networkmanager.enable then "yes" else "no"
            }" = "no"
            test "${
              if nixosServerEvaluation.config.networking.networkmanager.enable then "yes" else "no"
            }" = "no"
            test "${nixosServerEvaluation.config.networking.hostName}" = "server-test"
            touch $out
          '';

          nixos-coredns-evaluates = nixosCorednsEvaluation.config.system.build.toplevel;

          nixos-coredns-defaults = pkgs.runCommand "nixos-coredns-defaults" { } ''
            test "${if nixosCorednsEvaluation.config.qnix.network.coredns.enable then "yes" else "no"}" = "yes"
            test "${if nixosCorednsEvaluation.config.qnix.status.server then "yes" else "no"}" = "yes"
            test "${if nixosCorednsEvaluation.config.services.coredns.enable then "yes" else "no"}" = "yes"
            test "${if lib.elem 53 nixosCorednsEvaluation.config.qnix.network.firewall.allowedTCPPorts then "yes" else "no"}" = "yes"
            test "${if lib.elem 53 nixosCorednsEvaluation.config.qnix.network.firewall.allowedUDPPorts then "yes" else "no"}" = "yes"
            touch $out
          '';

          nixos-client-evaluates = nixosClientEvaluation.config.system.build.toplevel;

          nixos-container-host-evaluates = nixosContainerHostEvaluation.config.system.build.toplevel;

          nixos-container-host-defaults = pkgs.runCommand "nixos-container-host-defaults" { } ''
            test "${if nixosContainerHostEvaluation.config.qnix.status.server then "yes" else "no"}" = "yes"
            test "${if nixosContainerHostEvaluation.config.qnix.status.headless then "yes" else "no"}" = "yes"
            test "${
              if nixosContainerHostEvaluation.config.qnix.runtime.docker.enable then "yes" else "no"
            }" = "yes"
            test "${
              if nixosContainerHostEvaluation.config.virtualisation.docker.enable then "yes" else "no"
            }" = "yes"
            test "${nixosContainerHostEvaluation.config.networking.hostName}" = "container-host-test"
            test "${lib.concatStringsSep " " (lib.sort builtins.lessThan nixosContainerHostEvaluation.config.users.users.tester.extraGroups)}" = "docker wheel"
            touch $out
          '';

          nixos-wireguard-client-evaluates = nixosWireguardClientEvaluation.config.system.build.toplevel;

          nixos-wireguard-client-defaults = pkgs.runCommand "nixos-wireguard-client-defaults" { } ''
            test "${
              if nixosWireguardClientEvaluation.config.qnix.network.wireguard.enable then "yes" else "no"
            }" = "yes"
            test "${nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work.connection.type}" = "wireguard"
            test "${nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work.connection.interface-name}" = "wg0"
            test "${
              builtins.replaceStrings [ "$" "{" "}" ] [ "DOLLAR" "LBRACE" "RBRACE" ]
                nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work.wireguard.private-key
            }" = "DOLLARLBRACEQNIX_WG_WORK_PRIVATE_KEYRBRACE"
            test "${toString nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work.wireguard.listen-port}" = "51820"
            test "${nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work.ipv4.address1}" = "10.23.42.2/32"
            test "${
              nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work."wireguard-peer.xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=".endpoint
            }" = "vpn.example.test:51820"
            test "${
              toString nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.work."wireguard-peer.xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg="."preshared-key-flags"
            }" = "0"
            test "${nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.home.connection.interface-name}" = "wg1"
            test "${nixosWireguardClientEvaluation.config.networking.networkmanager.ensureProfiles.profiles.home.ipv4.address1}" = "10.77.0.2/32"
            test "${toString (builtins.head nixosWireguardClientEvaluation.config.qnix.network.firewall.allowedUDPPorts)}" = "51820"
            touch $out
          '';

          nixos-laptop-evaluates = nixosLaptopEvaluation.config.system.build.toplevel;

          nixos-laptop-defaults = pkgs.runCommand "nixos-laptop-defaults" { } ''
            test "${if nixosLaptopEvaluation.config.qnix.status.laptop then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.qnix.system.laptop.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosLaptopEvaluation.config.qnix.system.power-management.enable then "yes" else "no"
            }" = "yes"
            test "${
              if nixosLaptopEvaluation.config.qnix.system.thunderbolt.enable then "yes" else "no"
            }" = "yes"
            test "${if nixosLaptopEvaluation.config.qnix.system.bluetooth.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.services.upower.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.services.tuned.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.services.thermald.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.services.fwupd.enable then "yes" else "no"}" = "yes"
            test "${nixosLaptopEvaluation.config.services.logind.settings.Login.HandleLidSwitch}" = "suspend"
            test "${nixosLaptopEvaluation.config.services.logind.settings.Login.HandleLidSwitchExternalPower}" = "ignore"
            test "${nixosLaptopEvaluation.config.services.logind.settings.Login.HandleLidSwitchDocked}" = "ignore"
            test "${if nixosLaptopEvaluation.config.services.hardware.bolt.enable then "yes" else "no"}" = "yes"
            test "${if nixosLaptopEvaluation.config.hardware.bluetooth.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosLaptopEvaluation.config.hardware.bluetooth.powerOnBoot then "yes" else "no"
            }" = "yes"
            test "${if nixosLaptopEvaluation.config.services.blueman.enable then "yes" else "no"}" = "yes"
            touch $out
          '';

          nixos-backup-evaluates = pkgs.runCommand "nixos-backup-evaluates" { } ''
            test "${if nixosBackupEvaluation.config.qnix.storage.backup.enable then "yes" else "no"}" = "yes"
            test "${
              if builtins.hasAttr "us" nixosBackupEvaluation.config.services.borgbackup.jobs then "yes" else "no"
            }" = "yes"
            test "${
              if builtins.hasAttr "eu" nixosBackupEvaluation.config.services.borgbackup.jobs then "yes" else "no"
            }" = "yes"
            test "${
              if builtins.hasAttr "home" nixosBackupEvaluation.config.services.borgbackup.jobs then
                "yes"
              else
                "no"
            }" = "yes"
            test "${nixosBackupEvaluation.config.services.borgbackup.jobs.us.repo}" = "tester@us.repo.borgbase.com:repo"
            test "${nixosBackupEvaluation.config.services.borgbackup.jobs.eu.repo}" = "tester@eu.repo.borgbase.com:repo"
            test "${nixosBackupEvaluation.config.services.borgbackup.jobs.home.repo}" = "/mnt/backup-nfs/tester"
            test "${nixosBackupEvaluation.config.fileSystems."/mnt/backup-nfs".device}" = "nas:/srv/backup"
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
            test "${if nixosClientEvaluation.config.qnix.dev.codex.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.dev.cursor.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.dev.jetbrains.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosClientEvaluation.config.qnix.dev.jetbrains.idea.enable then "yes" else "no"
            }" = "yes"
            test "${if nixosClientEvaluation.config.qnix.dev.postman.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.dev.wireshark.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosClientEvaluation.config.qnix.desktop.displaymanager.enable then "yes" else "no"
            }" = "yes"
            test "${
              if nixosClientEvaluation.config.qnix.desktop.displaymanager.sddm.enable then "yes" else "no"
            }" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.stylix.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.system.plymouth.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.terminal.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.noctalia.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosClientEvaluation.config.qnix.security.gnome-keyring.enable then "yes" else "no"
            }" = "yes"
            test "${if nixosClientEvaluation.config.qnix.apps.browser.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.clipboard.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.apps.fileManager.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.lock.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosClientEvaluation.config.qnix.desktop.screenshots.enable then "yes" else "no"
            }" = "yes"
            test "${if nixosClientEvaluation.config.qnix.desktop.sound.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.apps.notes.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.apps.bitwarden.enable then "yes" else "no"}" = "no"
            test "${if nixosClientEvaluation.config.qnix.apps.music.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.qnix.apps.obs.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.programs.hyprland.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.xdg.portal.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.services.pipewire.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.programs.wireshark.enable then "yes" else "no"}" = "yes"
            test "${
              if nixosClientEvaluation.config.services.gnome.gnome-keyring.enable then "yes" else "no"
            }" = "yes"
            test "${
              if nixosClientEvaluation.config.services.displayManager.sddm.enable then "yes" else "no"
            }" = "yes"
            test "${if nixosClientEvaluation.config.stylix.enable then "yes" else "no"}" = "yes"
            test "${if nixosClientEvaluation.config.boot.plymouth.enable then "yes" else "no"}" = "yes"
            test "${nixosClientEvaluation.config.boot.plymouth.theme}" = "${nixosClientEvaluation.config.qnix.system.plymouth.theme}"
            test "${
              if homeOnlyEvaluation.config.wayland.windowManager.hyprland.enable then "yes" else "no"
            }" = "yes"
            test "${if homeOnlyEvaluation.config.stylix.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.dev.codex.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.dev.cursor.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.dev.jetbrains.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.dev.postman.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.programs.cursor.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.programs.kitty.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.programs.noctalia-shell.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.clipboard.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.screenshots.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.desktop.sound.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.apps.notes.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.apps.bitwarden.enable then "yes" else "no"}" = "no"
            test "${if homeOnlyEvaluation.config.qnix.apps.music.enable then "yes" else "no"}" = "yes"
            test "${if homeOnlyEvaluation.config.qnix.apps.obs.enable then "yes" else "no"}" = "yes"
            test "${homeOnlyEvaluation.config.home.sessionVariables.NIXOS_OZONE_WL}" = "1"
            touch $out
          '';

          nixos-and-home-manager-client-evaluates = nixosWithHomeEvaluation.config.system.build.toplevel;

          nvf-profile-defaults =
            let
              nixosNvfEvaluation = lib.nixosSystem {
                inherit pkgs lib;
                modules = [
                  stylix.nixosModules.stylix
                  impermanence.nixosModules.impermanence
                ]
                # `storage/impermanence` references `qnix.system.shell.packages`; the nvf-only
                # profile set does not pull base, so declare shell options explicitly.
                ++ (lib.qnix.mkNixosOptionImports {
                  category = "system";
                  name = "shell";
                })
                ++ [
                  (import ../loader/nixos.nix {
                    inherit lib;
                    profiles = [
                      "impermanence"
                      "nvf"
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
                  }
                  impermanenceTestModule
                ];
              };

              homeOnlyNvfEvaluation = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {
                  inherit qnixLib;
                  qnixHomeStandalone = true;
                };
                modules = [
                  nvf.homeManagerModules.default
                  {
                    imports = [
                      (import ../loader/home.nix {
                        lib = nixpkgs.lib;
                        profiles = [
                          "nvf"
                        ];
                      })
                    ];

                    home.username = "tester";
                    home.homeDirectory = "/tmp/tester";
                    home.stateVersion = "25.11";
                  }
                ];
              };
            in
            pkgs.runCommand "nvf-profile-defaults" { } ''
              test "${if nixosNvfEvaluation.config.qnix.dev.nvf.enable then "yes" else "no"}" = "yes"
              test "${if homeOnlyNvfEvaluation.config.qnix.dev.nvf.enable then "yes" else "no"}" = "yes"
              test "${if homeOnlyNvfEvaluation.config.programs.nvf.enable then "yes" else "no"}" = "yes"
              touch $out
            '';
        }
      );
    };
}
