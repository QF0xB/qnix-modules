{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    stylix = {
      url = "github:danth/stylix";
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
      stylix,
      sops-nix,
      qnix-modules,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qnix = qnix-modules.lib.mkQNix {
        context.hostname = "check";
      };
      laptopQnix = qnix-modules.lib.mkQNix {
        context = {
          hostname = "laptop-check";
          laptop = true;
        };
      };

      mkNixos =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs; };
          modules = [ { system.stateVersion = "26.11"; } ] ++ modules;
        };

      mkHome =
        modules:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit pkgs; };
          modules = [
            {
              home.username = "check";
              home.homeDirectory = "/home/check";
              home.stateVersion = "26.11";
            }
          ]
          ++ modules;
        };

      persistFeature = qnix.features.persist;
      bootFeature = qnix.features."system.boot";
      plymouthFeature = qnix.features."system.plymouth";
      waylandFeature = qnix.features."desktop.wayland";
      hyprlandFeature = qnix.features."desktop.hyprland";
      hyprlandKeybindsFeature = qnix.features."desktop.hyprland.keybinds";
      hyprlandMonitorsFeature = qnix.features."desktop.hyprland.monitors";
      hyprlandRulesFeature = qnix.features."desktop.hyprland.rules";
      hyprlandSpecialWorkspacesFeature = qnix.features."desktop.hyprland.special-workspaces";
      laptopFeature = qnix.features."hardware.laptop";
      powerManagementFeature = qnix.features."hardware.power-management";
      bluetoothFeature = qnix.features."hardware.bluetooth";
      laptopBluetoothFeature = laptopQnix.features."hardware.bluetooth";
      thunderboltFeature = qnix.features."hardware.thunderbolt";
      fontsFeature = qnix.features."appearance.fonts";
      gpgFeature = qnix.features."security.gpg";
      gnomeKeyringFeature = qnix.features."security.gnome-keyring";
      polkitFeature = qnix.features."security.polkit";
      sopsFeature = qnix.features."security.sops";
      yubikeyFeature = qnix.features."security.yubikey";
      stylixFeature = qnix.features."appearance.stylix";
      fishFeature = qnix.features."shell.fish";
      shellPackagesFeature = qnix.features."shell.packages";
      starshipFeature = qnix.features."shell.starship";
      zshFeature = qnix.features."shell.zsh";
      userFeature = qnix.features."system.users";
      impermanenceFeature = qnix.features."storage.impermanence";
      addressingFeature = qnix.features."network.addressing";
      firewallFeature = qnix.features."network.firewall";
      networkmanagerFeature = qnix.features."network.networkmanager";
      zfsFeature = qnix.features."storage.zfs";

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

      fontsNixosEvaluation = mkNixos (fontsFeature.optionModules ++ fontsFeature.nixosModules);
      fontsHomeEvaluation = mkHome (
        fontsFeature.optionModules ++ fontsFeature.__homeModuleFor "standalone-home"
      );

      stylixNixosEvaluation = mkNixos (
        [ stylix.nixosModules.stylix ] ++ stylixFeature.optionModules ++ stylixFeature.nixosModules
      );
      sopsEvaluation = mkNixos (
        [ sops-nix.nixosModules.sops ]
        ++ sopsFeature.optionModules
        ++ sopsFeature.nixosModules
        ++ [
          {
            qnix.security.sops = {
              defaultSopsFile = /dev/null;
              validateSopsFiles = false;
              age = {
                generateKey = true;
                keyFile = "/var/lib/sops/age/keys.txt";
              };
              secrets.example = {
                key = "example";
                path = "/run/secrets/example";
                owner = "check";
                group = "users";
                mode = "0440";
                neededForUsers = true;
                restartUnits = [ "example.service" ];
              };
            };
          }
        ]
      );
      gpgNixosEvaluation = mkNixos (
        persistFeature.optionModules
        ++ gpgFeature.optionModules
        ++ gpgFeature.nixosModules
        ++ [ { qnix.security.gpg.enableSSH = false; } ]
      );
      gpgHomeEvaluation = mkHome (
        gpgFeature.optionModules
        ++ gpgFeature.__homeModuleFor "standalone-home"
        ++ [
          {
            qnix.security.gpg = {
              enableSSH = false;
              publicKeys = [
                {
                  text = "test-public-key";
                  trust = "full";
                }
              ];
            };
          }
        ]
      );
      gnomeKeyringEvaluation = mkNixos (
        persistFeature.optionModules
        ++ gnomeKeyringFeature.optionModules
        ++ gnomeKeyringFeature.nixosModules
      );
      gnomeKeyringGuiEvaluation = mkNixos (
        persistFeature.optionModules
        ++ gnomeKeyringFeature.optionModules
        ++ gnomeKeyringFeature.nixosModules
        ++ [ { qnix.security.gnome-keyring.gui = true; } ]
      );
      yubikeyEvaluation = mkNixos (
        yubikeyFeature.optionModules
        ++ yubikeyFeature.nixosModules
        ++ [
          {
            qnix.security.yubikey = {
              login = true;
              sudo = true;
              u2f = {
                cue = false;
                origin = "pam://check";
                mappings.check = [ "key-handle,public-key,es256,+presence" ];
              };
            };
          }
        ]
      );
      polkitEvaluation = mkNixos (polkitFeature.optionModules ++ polkitFeature.nixosModules);
      polkitDisabledEvaluation = mkNixos (
        polkitFeature.optionModules
        ++ polkitFeature.nixosModules
        ++ [ { qnix.security.polkit.allowUserPowerCommands = false; } ]
      );
      stylixHomeEvaluation = mkHome (
        [ stylix.homeModules.stylix ]
        ++ stylixFeature.optionModules
        ++ stylixFeature.__homeModuleFor "standalone-home"
      );

      fishNixosEvaluation = mkNixos (
        persistFeature.optionModules ++ fishFeature.optionModules ++ fishFeature.nixosModules
      );
      fishHomeEvaluation = mkHome (
        fishFeature.optionModules ++ fishFeature.__homeModuleFor "standalone-home"
      );

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
      zshHomeEvaluation = mkHome (
        zshFeature.optionModules ++ zshFeature.__homeModuleFor "standalone-home"
      );

      impermanenceHomeEvaluation = mkHome (
        shellPackagesFeature.optionModules
        ++ impermanenceFeature.optionModules
        ++ shellPackagesFeature.__homeModuleFor "standalone-home"
        ++ impermanenceFeature.__homeModuleFor "standalone-home"
        ++ [ { qnix.storage.impermanence.enable = true; } ]
      );

      zfsImpermanenceEvaluation = mkNixos (
        zfsFeature.optionModules
        ++ zfsFeature.nixosModules
        ++ impermanenceFeature.optionModules
        ++ [ { qnix.storage.impermanence.enable = true; } ]
      );

      firewallEvaluation = mkNixos (
        firewallFeature.optionModules
        ++ firewallFeature.nixosModules
        ++ [
          {
            qnix.network.firewall = {
              allowedTCPPorts = [
                22
                443
              ];
              allowedUDPPorts = [ 51820 ];
              allowPing = true;
            };
          }
        ]
      );

      addressingEvaluation = mkNixos (
        addressingFeature.optionModules
        ++ addressingFeature.nixosModules
        ++ [
          {
            qnix.network.addressing = {
              hostname = "addressing-check";
              hostId = "01234567";
              nameservers = [
                "1.1.1.1"
                "2606:4700:4700::1111"
              ];
              defaultGateway = "192.0.2.1";
              defaultGateway6 = "2001:db8::1";
              interfaces.enp1s0 = {
                useDHCP = false;
                ipv4 = {
                  addresses = [
                    {
                      address = "192.0.2.10";
                      prefixLength = 24;
                    }
                  ];
                  routes = [
                    {
                      address = "198.51.100.0";
                      prefixLength = 24;
                      via = "192.0.2.1";
                    }
                  ];
                };
              };
            };
          }
        ]
      );

      networkmanagerEvaluation = mkNixos (
        persistFeature.optionModules
        ++ networkmanagerFeature.optionModules
        ++ networkmanagerFeature.nixosModules
        ++ [
          {
            qnix.network.networkmanager = {
              unmanaged = [ "usb0" ];
              extraPlugins = [ "networkmanager-openvpn" ];
            };
          }
        ]
      );

      bootEvaluation = mkNixos (bootFeature.optionModules ++ bootFeature.nixosModules);
      plymouthEvaluation = mkNixos (
        [ stylix.nixosModules.stylix ] ++ plymouthFeature.optionModules ++ plymouthFeature.nixosModules
      );
      waylandNixosEvaluation = mkNixos (waylandFeature.optionModules ++ waylandFeature.nixosModules);
      waylandHomeEvaluation = mkHome (
        waylandFeature.optionModules
        ++ waylandFeature.__homeModuleFor "standalone-home"
        ++ [ { qnix.desktop.wayland.xdgOpenUsePortal = true; } ]
      );
      hyprlandNixosEvaluation = mkNixos (
        waylandFeature.optionModules
        ++ waylandFeature.nixosModules
        ++ hyprlandFeature.optionModules
        ++ hyprlandFeature.nixosModules
      );
      hyprlandHomeEvaluation = mkHome (
        waylandFeature.optionModules
        ++ waylandFeature.__homeModuleFor "standalone-home"
        ++ hyprlandFeature.optionModules
        ++ hyprlandFeature.__homeModuleFor "standalone-home"
        ++ [ { qnix.desktop.hyprland.noHardwareCursors = true; } ]
      );
      hyprlandFullHomeEvaluation = mkHome (
        waylandFeature.optionModules
        ++ waylandFeature.__homeModuleFor "standalone-home"
        ++ hyprlandFeature.optionModules
        ++ hyprlandFeature.__homeModuleFor "standalone-home"
        ++ hyprlandKeybindsFeature.optionModules
        ++ hyprlandKeybindsFeature.__homeModuleFor "standalone-home"
        ++ hyprlandMonitorsFeature.optionModules
        ++ hyprlandMonitorsFeature.__homeModuleFor "standalone-home"
        ++ hyprlandRulesFeature.optionModules
        ++ hyprlandRulesFeature.__homeModuleFor "standalone-home"
        ++ hyprlandSpecialWorkspacesFeature.optionModules
        ++ hyprlandSpecialWorkspacesFeature.__homeModuleFor "standalone-home"
      );
      hyprlandPersistenceEvaluation = mkNixos (
        persistFeature.optionModules
        ++ waylandFeature.optionModules
        ++ waylandFeature.nixosModules
        ++ hyprlandFeature.optionModules
        ++ hyprlandFeature.nixosModules
        ++ hyprlandMonitorsFeature.optionModules
        ++ hyprlandMonitorsFeature.nixosModules
      );
      bluetoothEvaluation = mkNixos (
        bluetoothFeature.optionModules
        ++ bluetoothFeature.nixosModules
        ++ [
          {
            qnix.hardware.bluetooth = {
              gui = true;
              powerOnBoot = false;
              settings.General.Experimental = true;
            };
          }
        ]
      );
      laptopBluetoothEvaluation = mkNixos (
        laptopBluetoothFeature.optionModules ++ laptopBluetoothFeature.nixosModules
      );
      laptopEvaluation = mkNixos (
        laptopFeature.optionModules
        ++ laptopFeature.nixosModules
        ++ [
          {
            qnix.hardware.laptop = {
              touchpad = {
                tapping = false;
                naturalScrolling = false;
              };
              lidSwitch = "hibernate";
              lidSwitchExternalPower = "lock";
              lidSwitchDocked = "ignore";
              powerKey = "suspend";
            };
          }
        ]
      );
      powerManagementEvaluation = mkNixos (
        powerManagementFeature.optionModules
        ++ powerManagementFeature.nixosModules
        ++ [
          {
            qnix.hardware.power-management = {
              upower = true;
              powerProfilesDaemon = true;
              cpuFreqGovernor = "schedutil";
            };
          }
        ]
      );
      thunderboltEvaluation = mkNixos (
        thunderboltFeature.optionModules
        ++ thunderboltFeature.nixosModules
        ++ [ { qnix.hardware.thunderbolt.package = pkgs.bolt; } ]
      );
      grubBootEvaluation = mkNixos (
        bootFeature.optionModules
        ++ bootFeature.nixosModules
        ++ [
          {
            qnix.system.boot = {
              loader = "grub";
              zfsSupport = false;
              encrypted = true;
            };
          }
        ]
      );

      defaultEvaluation = mkNixos (qnix.modulesFor.nixos [ "base" ]);
      workstationProfileEvaluation = mkNixos (qnix.modulesFor.nixos [ "workstation" ]);
      laptopProfileEvaluation = mkNixos (qnix.modulesFor.nixos [ "laptop" ]);
      secretsProfileEvaluation = mkNixos (
        [ sops-nix.nixosModules.sops ]
        ++ qnix.modulesFor.nixos [ "secrets" ]
        ++ [ { qnix.security.sops.validateSopsFiles = false; } ]
      );
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
        assert
          qnix.featureNames == [
            "appearance.fonts"
            "appearance.stylix"
            "desktop.hyprland"
            "desktop.hyprland.keybinds"
            "desktop.hyprland.monitors"
            "desktop.hyprland.rules"
            "desktop.hyprland.special-workspaces"
            "desktop.wayland"
            "hardware.bluetooth"
            "hardware.laptop"
            "hardware.power-management"
            "hardware.thunderbolt"
            "network.addressing"
            "network.firewall"
            "network.networkmanager"
            "persist"
            "security.gnome-keyring"
            "security.gpg"
            "security.polkit"
            "security.sops"
            "security.yubikey"
            "shell.fish"
            "shell.packages"
            "shell.starship"
            "shell.zsh"
            "storage.impermanence"
            "storage.zfs"
            "system.boot"
            "system.localisation"
            "system.plymouth"
            "system.users"
          ];
        assert
          qnix.profileNames == [
            "appearance"
            "base"
            "impermanence"
            "laptop"
            "secrets"
            "workstation"
          ];
        assert persistFeature.supportedEnvironments == [ "nixos" ];
        assert bootFeature.supportedEnvironments == [ "nixos" ];
        assert plymouthFeature.supportedEnvironments == [ "nixos" ];
        assert plymouthEvaluation.config.boot.plymouth.enable;
        assert plymouthEvaluation.config.boot.plymouth.theme == "nixos-bgrt";
        assert plymouthEvaluation.config.boot.plymouth.themePackages == [ pkgs.nixos-bgrt-plymouth ];
        assert plymouthEvaluation.config.boot.consoleLogLevel == 3;
        assert !plymouthEvaluation.config.boot.initrd.verbose;
        assert plymouthEvaluation.config.stylix.targets.plymouth.enable == false;
        assert
          waylandFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert waylandNixosEvaluation.config.services.graphical-desktop.enable;
        assert waylandNixosEvaluation.config.programs.dconf.enable;
        assert waylandNixosEvaluation.config.programs.xwayland.enable;
        assert waylandNixosEvaluation.config.xdg.portal.enable;
        assert waylandNixosEvaluation.config.xdg.portal.wlr.enable;
        assert builtins.elem pkgs.xdg-desktop-portal-gtk
          waylandNixosEvaluation.config.xdg.portal.extraPortals;
        assert waylandHomeEvaluation.config.home.sessionVariables.NIXOS_XDG_OPEN_USE_PORTAL == "1";
        assert
          hyprlandFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert hyprlandNixosEvaluation.config.programs.hyprland.enable;
        assert hyprlandNixosEvaluation.config.programs.hyprland.withUWSM;
        assert hyprlandNixosEvaluation.config.programs.uwsm.enable;
        assert hyprlandNixosEvaluation.config.environment.sessionVariables.NIXOS_OZONE_WL == "1";
        assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.enable;
        assert !hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.systemd.enable;
        assert hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.general.gaps_in == 5;
        assert
          hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.decoration.rounding == 10;
        assert
          hyprlandHomeEvaluation.config.wayland.windowManager.hyprland.settings.cursor.no_hardware_cursors;
        assert hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.bind != [ ];
        assert hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.windowrule != [ ];
        assert hyprlandFullHomeEvaluation.config.wayland.windowManager.hyprland.settings.source != [ ];
        assert builtins.elem "hypr-special" (
          map (package: package.pname or package.name) hyprlandFullHomeEvaluation.config.home.packages
        );
        assert
          hyprlandPersistenceEvaluation.config.qnix.persist.users."*".files == [
            ".config/hypr/monitors.conf"
            ".config/hypr/workspaces.conf"
          ];
        assert bluetoothFeature.supportedEnvironments == [ "nixos" ];
        assert bluetoothEvaluation.config.hardware.bluetooth.enable;
        assert !bluetoothEvaluation.config.hardware.bluetooth.powerOnBoot;
        assert bluetoothEvaluation.config.hardware.bluetooth.settings.General.Experimental;
        assert bluetoothEvaluation.config.services.blueman.enable;
        assert !laptopBluetoothEvaluation.config.hardware.bluetooth.powerOnBoot;
        assert laptopFeature.supportedEnvironments == [ "nixos" ];
        assert laptopEvaluation.config.services.libinput.enable;
        assert !laptopEvaluation.config.services.libinput.touchpad.tapping;
        assert !laptopEvaluation.config.services.libinput.touchpad.naturalScrolling;
        assert laptopEvaluation.config.services.logind.settings.Login.HandleLidSwitch == "hibernate";
        assert
          laptopEvaluation.config.services.logind.settings.Login.HandleLidSwitchExternalPower == "lock";
        assert laptopEvaluation.config.services.logind.settings.Login.HandleLidSwitchDocked == "ignore";
        assert laptopEvaluation.config.services.logind.settings.Login.HandlePowerKey == "suspend";
        assert powerManagementFeature.supportedEnvironments == [ "nixos" ];
        assert powerManagementEvaluation.config.services.upower.enable;
        assert powerManagementEvaluation.config.services.power-profiles-daemon.enable;
        assert powerManagementEvaluation.config.powerManagement.cpuFreqGovernor == "schedutil";
        assert thunderboltFeature.supportedEnvironments == [ "nixos" ];
        assert thunderboltEvaluation.config.services.hardware.bolt.enable;
        assert thunderboltEvaluation.config.services.hardware.bolt.package == pkgs.bolt;
        assert bootEvaluation.config.boot.loader.systemd-boot.enable;
        assert bootEvaluation.config.boot.loader.timeout == 3;
        assert bootEvaluation.config.boot.supportedFilesystems.zfs;
        assert bootEvaluation.config.boot.initrd.systemd.enable;
        assert grubBootEvaluation.config.boot.loader.grub.enable;
        assert grubBootEvaluation.config.boot.loader.grub.enableCryptodisk;
        assert !(grubBootEvaluation.config.boot.supportedFilesystems ? zfs);
        assert firewallFeature.supportedEnvironments == [ "nixos" ];
        assert firewallEvaluation.config.networking.firewall.enable;
        assert
          firewallEvaluation.config.networking.firewall.allowedTCPPorts == [
            22
            443
          ];
        assert firewallEvaluation.config.networking.firewall.allowedUDPPorts == [ 51820 ];
        assert firewallEvaluation.config.networking.firewall.allowPing;
        assert addressingFeature.supportedEnvironments == [ "nixos" ];
        assert addressingEvaluation.config.networking.hostName == "addressing-check";
        assert addressingEvaluation.config.networking.hostId == "01234567";
        assert
          addressingEvaluation.config.networking.nameservers == [
            "1.1.1.1"
            "2606:4700:4700::1111"
          ];
        assert addressingEvaluation.config.networking.defaultGateway.address == "192.0.2.1";
        assert addressingEvaluation.config.networking.defaultGateway6.address == "2001:db8::1";
        assert !addressingEvaluation.config.networking.interfaces.enp1s0.useDHCP;
        assert
          addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.addresses == [
            {
              address = "192.0.2.10";
              prefixLength = 24;
            }
          ];
        assert builtins.length addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes == 1;
        assert
          (builtins.head addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes).address
          == "198.51.100.0";
        assert
          (builtins.head addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes).prefixLength
          == 24;
        assert
          (builtins.head addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes).via
          == "192.0.2.1";
        assert networkmanagerFeature.supportedEnvironments == [ "nixos" ];
        assert networkmanagerEvaluation.config.networking.networkmanager.enable;
        assert !networkmanagerEvaluation.config.networking.useDHCP;
        assert networkmanagerEvaluation.config.networking.networkmanager.unmanaged == [ "usb0" ];
        assert
          networkmanagerEvaluation.config.networking.networkmanager.plugins
          == [ pkgs.networkmanager-openvpn ];
        assert networkmanagerEvaluation.config.programs.nm-applet.enable;
        assert
          networkmanagerEvaluation.config.qnix.persist.root.directories
          == [ "/etc/NetworkManager/system-connections" ];
        assert
          gpgFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert gpgNixosEvaluation.config.programs.gnupg.agent.enable;
        assert !gpgNixosEvaluation.config.programs.gnupg.agent.enableSSHSupport;
        assert gpgNixosEvaluation.config.qnix.persist.users."*".directories == [ ".gnupg" ];
        assert gpgHomeEvaluation.config.programs.gpg.enable;
        assert gpgHomeEvaluation.config.services.gpg-agent.enable;
        assert !gpgHomeEvaluation.config.services.gpg-agent.enableSshSupport;
        assert gpgHomeEvaluation.config.programs.gpg.settings.use-agent;
        assert builtins.length gpgHomeEvaluation.config.programs.gpg.publicKeys == 1;
        assert
          (builtins.elemAt gpgHomeEvaluation.config.programs.gpg.publicKeys 0).text == "test-public-key";
        assert (builtins.elemAt gpgHomeEvaluation.config.programs.gpg.publicKeys 0).trust == 4;
        assert gnomeKeyringFeature.supportedEnvironments == [ "nixos" ];
        assert gnomeKeyringEvaluation.config.services.gnome.gnome-keyring.enable;
        assert gnomeKeyringEvaluation.config.security.pam.services.login.enableGnomeKeyring;
        assert gnomeKeyringEvaluation.config.security.pam.services.sddm.enableGnomeKeyring;
        assert
          gnomeKeyringEvaluation.config.qnix.persist.users."*".directories == [ ".local/share/keyrings" ];
        assert !(builtins.elem pkgs.seahorse gnomeKeyringEvaluation.config.environment.systemPackages);
        assert builtins.elem pkgs.seahorse gnomeKeyringGuiEvaluation.config.environment.systemPackages;
        assert polkitFeature.supportedEnvironments == [ "nixos" ];
        assert polkitEvaluation.config.security.polkit.enable;
        assert polkitEvaluation.config.qnix.security.polkit.allowUserPowerCommands;
        assert
          builtins.match ".*org.freedesktop.login1.reboot.*" polkitEvaluation.config.security.polkit.extraConfig
          != null;
        assert !polkitDisabledEvaluation.config.qnix.security.polkit.allowUserPowerCommands;
        assert
          builtins.match ".*org.freedesktop.login1.reboot.*" polkitDisabledEvaluation.config.security.polkit.extraConfig
          == null;
        assert sopsFeature.supportedEnvironments == [ "nixos" ];
        assert secretsProfileEvaluation.config.qnix.security.sops.validateSopsFiles == false;
        assert secretsProfileEvaluation.config.sops.validateSopsFiles == false;
        assert sopsEvaluation.config.sops.defaultSopsFile == /dev/null;
        assert !sopsEvaluation.config.sops.validateSopsFiles;
        assert sopsEvaluation.config.sops.age.generateKey;
        assert sopsEvaluation.config.sops.age.keyFile == "/var/lib/sops/age/keys.txt";
        assert sopsEvaluation.config.sops.secrets.example.key == "example";
        assert sopsEvaluation.config.sops.secrets.example.path == "/run/secrets/example";
        assert sopsEvaluation.config.sops.secrets.example.owner == "check";
        assert sopsEvaluation.config.sops.secrets.example.group == "users";
        assert sopsEvaluation.config.sops.secrets.example.mode == "0440";
        assert sopsEvaluation.config.sops.secrets.example.neededForUsers;
        assert sopsEvaluation.config.sops.secrets.example.restartUnits == [ "example.service" ];
        assert yubikeyFeature.supportedEnvironments == [ "nixos" ];
        assert yubikeyEvaluation.config.services.pcscd.enable;
        assert yubikeyEvaluation.config.hardware.gpgSmartcards.enable;
        assert yubikeyEvaluation.config.security.pam.u2f.enable;
        assert yubikeyEvaluation.config.security.pam.u2f.settings.cue == false;
        assert yubikeyEvaluation.config.security.pam.u2f.settings.origin == "pam://check";
        assert yubikeyEvaluation.config.security.pam.services.login.u2f.enable;
        assert yubikeyEvaluation.config.security.pam.services.sudo.u2f.enable;
        assert yubikeyEvaluation.config.qnix.security.yubikey.gui;
        assert builtins.elem pkgs.yubioath-flutter yubikeyEvaluation.config.environment.systemPackages;
        assert
          fontsFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert builtins.elem pkgs.nerd-fonts.jetbrains-mono fontsNixosEvaluation.config.fonts.packages;
        assert builtins.elem pkgs.nerd-fonts.jetbrains-mono fontsHomeEvaluation.config.home.packages;
        assert
          stylixFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert stylixNixosEvaluation.config.stylix.enable;
        assert stylixNixosEvaluation.config.stylix.polarity == "dark";
        assert stylixNixosEvaluation.config.stylix.cursor.name == "Simp1e-Solarized-Dark";
        assert stylixHomeEvaluation.config.stylix.enable;
        assert stylixHomeEvaluation.config.stylix.targets.kitty.variant256Colors;
        assert zfsFeature.supportedEnvironments == [ "nixos" ];
        assert
          zfsImpermanenceEvaluation.config.boot.initrd.systemd.services.qnix-impermanence-reset.before
          == [ "sysroot.mount" ];
        assert
          zfsImpermanenceEvaluation.config.boot.initrd.systemd.services.qnix-impermanence-reset.after == [
            "zfs-import.target"
            "systemd-cryptsetup@cryptroot.service"
          ];
        assert
          builtins.match ".*zfs rollback -r zroot/root@blank.*" zfsImpermanenceEvaluation.config.boot.initrd.systemd.services.qnix-impermanence-reset.script
          != null;
        assert persistEvaluation.config.qnix.persist.root.directories == [ ];
        assert persistEvaluation.config.qnix.persist.users == { };
        assert persistConfiguredEvaluation.config.qnix.persist.root.directories == [ "/var/lib/example" ];
        assert persistConfiguredEvaluation.config.qnix.persist.root.files == [ "/etc/example.conf" ];
        assert
          persistConfiguredEvaluation.config.qnix.persist.root.cache.directories == [ "/var/cache/example" ];
        assert
          persistConfiguredEvaluation.config.qnix.persist.root.cache.files == [ "/var/cache/example.state" ];
        assert
          persistConfiguredEvaluation.config.qnix.persist.users.tester.directories
          == [ ".local/share/example" ];
        assert
          persistConfiguredEvaluation.config.qnix.persist.users.tester.files == [ ".config/example.conf" ];
        assert
          persistConfiguredEvaluation.config.qnix.persist.users.tester.cache.directories
          == [ ".cache/example" ];
        assert
          persistConfiguredEvaluation.config.qnix.persist.users.tester.cache.files
          == [ ".cache/example.state" ];
        assert !invalidPersistPath.success;
        assert
          impermanenceFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert impermanenceEvaluation.config.fileSystems."/persist".neededForBoot;
        assert impermanenceEvaluation.config.fileSystems."/cache".neededForBoot;
        assert impermanenceEvaluation.config.services.journald.storage == "persistent";
        assert
          directoryPaths impermanenceEvaluation.config.environment.persistence."/persist".directories == [
            "/var/lib/nixos"
            "/var/lib/example"
          ];
        assert
          directoryPaths impermanenceEvaluation.config.environment.persistence."/cache".directories == [
            "/var/log"
            "/var/log/journal"
            "/var/cache/example"
          ];
        assert impermanenceEvaluation.config.environment.persistence."/persist".allowTrash;
        assert impermanenceEvaluation.config.environment.persistence."/cache".allowTrash;
        assert
          filePaths impermanenceEvaluation.config.environment.persistence."/persist".files
          == [ "/etc/example.conf" ];
        assert
          filePaths impermanenceEvaluation.config.environment.persistence."/cache".files
          == [ "/var/cache/example.state" ];
        assert
          directoryPaths
            impermanenceEvaluation.config.environment.persistence."/persist".users.tester.directories == [
            "Projects"
            ".ssh"
            ".local/share/example"
          ];
        assert
          filePaths impermanenceEvaluation.config.environment.persistence."/persist".users.tester.files
          == [ ".config/example.conf" ];
        assert
          directoryPaths
            impermanenceEvaluation.config.environment.persistence."/cache".users.tester.directories == [
            ".cache"
            ".gradle"
            ".cache/example"
          ];
        assert
          filePaths impermanenceEvaluation.config.environment.persistence."/cache".users.tester.files == [
            ".cache/example.state"
            ".cache/tester.state"
          ];
        assert
          directoryPaths
            impermanenceEvaluation.config.environment.persistence."/persist".users.alice.directories == [
            "Projects"
            ".ssh"
            ".local/share/example"
            "alice-data"
          ];
        assert
          directoryPaths
            impermanenceEvaluation.config.environment.persistence."/cache".users.alice.directories == [
            ".cache"
            ".gradle"
            ".cache/example"
          ];
        assert impermanenceEvaluation.config.environment.etc."impermanence.json".source != null;
        assert builtins.elem "/var/lib/nixos" impermanenceManifest.directories;
        assert builtins.elem "/etc/example.conf" impermanenceManifest.files;
        assert builtins.elem "/home/tester/.local/share/example" impermanenceManifest.directories;
        assert builtins.elem "/home/tester/.cache/tester.state" impermanenceManifest.files;
        assert builtins.elem "/home/alice/alice-data" impermanenceManifest.directories;
        assert
          fishFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert fishNixosEvaluation.config.programs.fish.enable;
        assert fishHomeEvaluation.config.programs.fish.enable;
        assert fishNixosEvaluation.config.qnix.persist.users."*".directories == [ ".local/share/fish" ];
        assert
          shellPackagesFeature.supportedEnvironments == [
            "integrated-home"
            "standalone-home"
          ];
        assert builtins.hasAttr "derivation" shellPackagesEvaluation.config.qnix.shell.packages.packages;
        assert builtins.hasAttr "string" shellPackagesEvaluation.config.qnix.shell.packages.packages;
        assert builtins.hasAttr "attrset" shellPackagesEvaluation.config.qnix.shell.packages.packages;
        assert
          starshipFeature.supportedEnvironments == [
            "integrated-home"
            "standalone-home"
          ];
        assert starshipEvaluation.config.programs.starship.enable;
        assert starshipEvaluation.config.programs.starship.settings.add_newline == false;
        assert starshipEvaluation.config.programs.starship.settings.format == "$directory$character";
        assert
          zshFeature.supportedEnvironments == [
            "nixos"
            "integrated-home"
            "standalone-home"
          ];
        assert zshNixosEvaluation.config.programs.zsh.enable;
        assert zshNixosEvaluation.config.programs.zsh.autosuggestions.enable;
        assert zshNixosEvaluation.config.programs.zsh.syntaxHighlighting.enable;
        assert zshNixosEvaluation.config.programs.zsh.enableCompletion;
        assert zshHomeEvaluation.config.programs.zsh.enable;
        assert zshHomeEvaluation.config.programs.zsh.autosuggestion.enable;
        assert zshNixosEvaluation.config.qnix.persist.users."*".files == [ ".zsh_history" ];
        assert builtins.hasAttr "show-root-filesystem"
          impermanenceHomeEvaluation.config.qnix.shell.packages.packages;
        assert userFeature.supportedEnvironments == [ "nixos" ];
        assert userEvaluation.config.users.mutableUsers == false;
        assert userEvaluation.config.users.defaultUserShell == pkgs.bash;
        assert userEvaluation.config.users.users.root.isSystemUser;
        assert userEvaluation.config.users.users.alice.isNormalUser;
        assert userEvaluation.config.users.users.alice.group == "alice";
        assert
          userEvaluation.config.users.users.alice.extraGroups == [
            "wheel"
            "audio"
          ];
        assert userEvaluation.config.users.users.alice.home == "/home/alice";
        assert userEvaluation.config.users.users.alice.description == "Alice";
        assert userEvaluation.config.users.users.alice.shell == pkgs.zsh;
        assert
          userEvaluation.config.users.users.alice.openssh.authorizedKeys.keys == [ "ssh-ed25519 AAAA alice" ];
        assert userEvaluation.config.users.users.service.isSystemUser;
        assert userEvaluation.config.users.users.service.group == "svc";
        assert builtins.hasAttr "alice" userEvaluation.config.users.groups;
        assert builtins.hasAttr "svc" userEvaluation.config.users.groups;
        assert impermanenceProfileEvaluation.config.qnix.storage.impermanence.enable;
        assert impermanenceProfileEvaluation.config.qnix.persist.root.directories == [ "/var/lib/nixos" ];
        assert defaultEvaluation.config.qnix.system.localisation.enable;
        assert
          defaultEvaluation.config.qnix.appearance.fonts.packages == [ pkgs.nerd-fonts.jetbrains-mono ];
        assert defaultEvaluation.config.qnix.system.users.defaultExtraGroups == [ "wheel" ];
        assert defaultEvaluation.config.qnix.system.users.defaultShell == "fish";
        assert defaultEvaluation.config.qnix.network.addressing.enable;
        assert workstationProfileEvaluation.config.qnix.hardware.bluetooth.enable;
        assert workstationProfileEvaluation.config.qnix.hardware.thunderbolt.enable;
        assert workstationProfileEvaluation.config.qnix.network.networkmanager.enable;
        assert laptopProfileEvaluation.config.qnix.hardware.laptop.enable;
        assert laptopProfileEvaluation.config.qnix.hardware.power-management.enable;
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
