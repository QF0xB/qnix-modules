{
  nixpkgs,
  home-manager,
  impermanence,
  stylix,
  sops-nix,
  llm-agents,
  mcp-servers-nix,
  nvf,
  qnix-modules,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ llm-agents.overlays.shared-nixpkgs ];
  };
  qnix = qnix-modules.lib.mkQNix {
    context = {
      hostname = "check";
      inherit mcp-servers-nix;
    };
  };
  laptopQnix = qnix-modules.lib.mkQNix {
    context = {
      hostname = "laptop-check";
      laptop = true;
      inherit mcp-servers-nix;
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
  browserFeature = qnix.features."apps.browser";
  chatgptFeature = qnix.features."apps.chatgpt";
  vscodeFeature = qnix.features."dev.vscode";
  mcpFeature = qnix.features."dev.mcp";
  aiToolsFeature = qnix.features."dev.ai-tools";
  gitFeature = qnix.features."dev.git";
  direnvFeature = qnix.features."dev.direnv";
  nhFeature = qnix.features."dev.nh";
  nixfmtFeature = qnix.features."dev.nixfmt";
  devenvFeature = qnix.features."dev.devenv";
  nvfFeature = qnix.features."dev.nvf";
  fileManagerFeature = qnix.features."apps.file-manager";
  bootFeature = qnix.features."system.boot";
  plymouthFeature = qnix.features."system.plymouth";
  waylandFeature = qnix.features."desktop.wayland";
  displayManagerFeature = qnix.features."desktop.displaymanager";
  lockFeature = qnix.features."desktop.lock";
  localisationFeature = qnix.features."system.localisation";
  hyprlandFeature = qnix.features."desktop.hyprland";
  hyprlandKeybindsFeature = qnix.features."desktop.hyprland.keybinds";
  hyprlandMonitorsFeature = qnix.features."desktop.hyprland.monitors";
  hyprlandRulesFeature = qnix.features."desktop.hyprland.rules";
  hyprlandSpecialWorkspacesFeature = qnix.features."desktop.hyprland.special-workspaces";
  clipboardFeature = qnix.features."desktop.clipboard";
  screenshotsFeature = qnix.features."desktop.screenshots";
  noctaliaFeature = qnix.features."desktop.noctalia";
  soundFeature = qnix.features."desktop.sound";
  terminalFeature = qnix.features."desktop.terminal";
  xdgFoldersFeature = qnix.features."desktop.xdg-folders";
  displayManagerEvaluation = mkNixos (
    waylandFeature.optionModules
    ++ waylandFeature.nixosModules
    ++ displayManagerFeature.optionModules
    ++ displayManagerFeature.nixosModules
  );
  lockNixosEvaluation = mkNixos (
    waylandFeature.optionModules
    ++ waylandFeature.nixosModules
    ++ lockFeature.optionModules
    ++ lockFeature.nixosModules
  );
  lockHomeEvaluation = mkHome (
    waylandFeature.optionModules
    ++ waylandFeature.__homeModuleFor "standalone-home"
    ++ hyprlandFeature.optionModules
    ++ hyprlandFeature.__homeModuleFor "standalone-home"
    ++ lockFeature.optionModules
    ++ lockFeature.__homeModuleFor "standalone-home"
  );
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
  zfsWithoutImpermanenceEvaluation = mkNixos (zfsFeature.optionModules ++ zfsFeature.nixosModules);
  zfsResetDisabledEvaluation = mkNixos (
    zfsFeature.optionModules
    ++ zfsFeature.nixosModules
    ++ impermanenceFeature.optionModules
    ++ [
      {
        qnix.storage.impermanence.enable = true;
        qnix.storage.zfs.impermanenceReset.enable = false;
      }
    ]
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
    localisationFeature.optionModules
    ++ localisationFeature.__homeModuleFor "standalone-home"
    ++ waylandFeature.optionModules
    ++ waylandFeature.__homeModuleFor "standalone-home"
    ++ hyprlandFeature.optionModules
    ++ hyprlandFeature.__homeModuleFor "standalone-home"
    ++ [
      {
        qnix.desktop.hyprland = {
          noHardwareCursors = true;
          devices."test-mouse".sensitivity = -0.5;
        };
      }
    ]
  );
  hyprlandFullHomeEvaluation = mkHome (
    localisationFeature.optionModules
    ++ localisationFeature.__homeModuleFor "standalone-home"
    ++ waylandFeature.optionModules
    ++ waylandFeature.__homeModuleFor "standalone-home"
    ++ hyprlandFeature.optionModules
    ++ hyprlandFeature.__homeModuleFor "standalone-home"
    ++ terminalFeature.optionModules
    ++ terminalFeature.__homeModuleFor "standalone-home"
    ++ hyprlandKeybindsFeature.optionModules
    ++ hyprlandKeybindsFeature.__homeModuleFor "standalone-home"
    ++ hyprlandMonitorsFeature.optionModules
    ++ hyprlandMonitorsFeature.__homeModuleFor "standalone-home"
    ++ hyprlandRulesFeature.optionModules
    ++ hyprlandRulesFeature.__homeModuleFor "standalone-home"
    ++ hyprlandSpecialWorkspacesFeature.optionModules
    ++ hyprlandSpecialWorkspacesFeature.__homeModuleFor "standalone-home"
    ++ [
      {
        qnix.desktop.hyprland.keybinds.additionalKeybinds = [ "SUPER, F12, exec, true" ];
        qnix.desktop.hyprland.rules.additionalRules = [ "match:class ^test$, float on" ];
        qnix.system.localisation.xkb.layout = "de,de,us";
      }
    ]
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
  hyprlandProfileEvaluation = mkNixos (qnix.modulesFor.nixos [ "hyprland" ]);
  noctaliaStub =
    { lib, ... }:
    {
      options.programs.noctalia-shell = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        systemd.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };
      };
    };
  noctaliaHomeEvaluation = mkHome (
    [ noctaliaStub ]
    ++ waylandFeature.optionModules
    ++ waylandFeature.__homeModuleFor "standalone-home"
    ++ hyprlandFeature.optionModules
    ++ hyprlandFeature.__homeModuleFor "standalone-home"
    ++ terminalFeature.optionModules
    ++ terminalFeature.__homeModuleFor "standalone-home"
    ++ noctaliaFeature.optionModules
    ++ noctaliaFeature.__homeModuleFor "standalone-home"
  );
  soundNixosEvaluation = mkNixos (
    persistFeature.optionModules
    ++ soundFeature.optionModules
    ++ soundFeature.nixosModules
    ++ [ { qnix.desktop.sound.gui = true; } ]
  );
  soundIntegratedEvaluation = mkNixos (
    [ home-manager.nixosModules.home-manager ]
    ++ persistFeature.optionModules
    ++ soundFeature.optionModules
    ++ soundFeature.nixosModules
    ++ [
      {
        home-manager.extraSpecialArgs = { inherit pkgs; };
        home-manager.users.check = {
          home.stateVersion = "26.11";
          imports = soundFeature.__homeModuleFor "integrated-home";
        };
      }
    ]
  );
  terminalHomeEvaluation = mkHome (
    terminalFeature.optionModules ++ terminalFeature.__homeModuleFor "standalone-home"
  );
  terminalFallbackHomeEvaluation = mkHome (
    terminalFeature.optionModules
    ++ terminalFeature.__homeModuleFor "standalone-home"
    ++ [ { qnix.desktop.terminal.server = false; } ]
  );
  xdgFoldersHomeEvaluation = mkHome (
    xdgFoldersFeature.optionModules ++ xdgFoldersFeature.__homeModuleFor "standalone-home"
  );
  browserHomeEvaluation = mkHome (
    browserFeature.optionModules ++ browserFeature.__homeModuleFor "standalone-home"
  );
  chatgptHomeEvaluation = mkHome (
    chatgptFeature.optionModules ++ chatgptFeature.__homeModuleFor "standalone-home"
  );
  vscodeHomeEvaluation = mkHome (
    vscodeFeature.optionModules ++ vscodeFeature.__homeModuleFor "standalone-home"
  );
  mcpHomeEvaluation = mkHome (
    xdgFoldersFeature.optionModules
    ++ xdgFoldersFeature.__homeModuleFor "standalone-home"
    ++ mcpFeature.optionModules
    ++ mcpFeature.__homeModuleFor "standalone-home"
  );
  aiToolsHomeEvaluation = mkHome (
    aiToolsFeature.optionModules ++ aiToolsFeature.__homeModuleFor "standalone-home"
  );
  gitNixosEvaluation = mkNixos (
    persistFeature.optionModules ++ gitFeature.optionModules ++ gitFeature.nixosModules
  );
  gitHomeEvaluation = mkHome (
    gitFeature.optionModules
    ++ gitFeature.__homeModuleFor "standalone-home"
    ++ [
      {
        qnix.dev.git = {
          lfs = true;
          userName = "QNix Check";
          userEmail = "check@example.test";
          signingKey = "0123456789ABCDEF";
          aliases.ci = "commit";
        };
      }
    ]
  );
  direnvNixosEvaluation = mkNixos (
    persistFeature.optionModules ++ direnvFeature.optionModules ++ direnvFeature.nixosModules
  );
  direnvHomeEvaluation = mkHome (
    direnvFeature.optionModules ++ direnvFeature.__homeModuleFor "standalone-home"
  );
  nhEvaluation = mkNixos (
    nhFeature.optionModules
    ++ nhFeature.nixosModules
    ++ [
      {
        qnix.dev.nh.clean = {
          enable = true;
          dates = "daily";
        };
      }
    ]
  );
  nixfmtNixosEvaluation = mkNixos (nixfmtFeature.optionModules ++ nixfmtFeature.nixosModules);
  nixfmtHomeEvaluation = mkHome (
    nixfmtFeature.optionModules ++ nixfmtFeature.__homeModuleFor "standalone-home"
  );
  devenvHomeEvaluation = mkHome (
    devenvFeature.optionModules ++ devenvFeature.__homeModuleFor "standalone-home"
  );
  nvfHomeEvaluation = mkHome (
    [ nvf.homeManagerModules.default ]
    ++ nvfFeature.optionModules
    ++ nvfFeature.__homeModuleFor "standalone-home"
  );
  fileManagerHomeEvaluation = mkHome (
    xdgFoldersFeature.optionModules
    ++ xdgFoldersFeature.__homeModuleFor "standalone-home"
    ++ fileManagerFeature.optionModules
    ++ fileManagerFeature.__homeModuleFor "standalone-home"
  );
  clipboardHomeEvaluation = mkHome (
    waylandFeature.optionModules
    ++ waylandFeature.__homeModuleFor "standalone-home"
    ++ clipboardFeature.optionModules
    ++ clipboardFeature.__homeModuleFor "standalone-home"
  );
  screenshotsHomeEvaluation = mkHome (
    localisationFeature.optionModules
    ++ localisationFeature.__homeModuleFor "standalone-home"
    ++ waylandFeature.optionModules
    ++ waylandFeature.__homeModuleFor "standalone-home"
    ++ hyprlandFeature.optionModules
    ++ hyprlandFeature.__homeModuleFor "standalone-home"
    ++ xdgFoldersFeature.optionModules
    ++ xdgFoldersFeature.__homeModuleFor "standalone-home"
    ++ screenshotsFeature.optionModules
    ++ screenshotsFeature.__homeModuleFor "standalone-home"
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
  shellHomeProfileEvaluation = mkHome (qnix.modulesFor.standaloneHome [ "shell" ]);
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
  inherit
    system
    pkgs
    qnix
    laptopQnix
    mkNixos
    mkHome
    persistFeature
    browserFeature
    chatgptFeature
    vscodeFeature
    mcpFeature
    aiToolsFeature
    gitFeature
    direnvFeature
    nhFeature
    nixfmtFeature
    devenvFeature
    nvfFeature
    fileManagerFeature
    bootFeature
    plymouthFeature
    waylandFeature
    displayManagerFeature
    lockFeature
    localisationFeature
    hyprlandFeature
    hyprlandKeybindsFeature
    hyprlandMonitorsFeature
    hyprlandRulesFeature
    hyprlandSpecialWorkspacesFeature
    clipboardFeature
    screenshotsFeature
    noctaliaFeature
    soundFeature
    terminalFeature
    xdgFoldersFeature
    displayManagerEvaluation
    lockNixosEvaluation
    lockHomeEvaluation
    laptopFeature
    powerManagementFeature
    bluetoothFeature
    laptopBluetoothFeature
    thunderboltFeature
    fontsFeature
    gpgFeature
    gnomeKeyringFeature
    polkitFeature
    sopsFeature
    yubikeyFeature
    stylixFeature
    fishFeature
    shellPackagesFeature
    starshipFeature
    zshFeature
    userFeature
    impermanenceFeature
    addressingFeature
    firewallFeature
    networkmanagerFeature
    zfsFeature
    persistEvaluation
    persistConfiguredEvaluation
    invalidPersistPath
    impermanenceFileSystems
    impermanenceEvaluation
    impermanenceManifest
    directoryPaths
    filePaths
    userEvaluation
    fontsNixosEvaluation
    fontsHomeEvaluation
    stylixNixosEvaluation
    sopsEvaluation
    gpgNixosEvaluation
    gpgHomeEvaluation
    gnomeKeyringEvaluation
    gnomeKeyringGuiEvaluation
    yubikeyEvaluation
    polkitEvaluation
    polkitDisabledEvaluation
    stylixHomeEvaluation
    fishNixosEvaluation
    fishHomeEvaluation
    shellPackagesEvaluation
    starshipEvaluation
    zshNixosEvaluation
    zshHomeEvaluation
    impermanenceHomeEvaluation
    zfsImpermanenceEvaluation
    zfsWithoutImpermanenceEvaluation
    zfsResetDisabledEvaluation
    firewallEvaluation
    addressingEvaluation
    networkmanagerEvaluation
    bootEvaluation
    plymouthEvaluation
    waylandNixosEvaluation
    waylandHomeEvaluation
    hyprlandNixosEvaluation
    hyprlandHomeEvaluation
    hyprlandFullHomeEvaluation
    hyprlandPersistenceEvaluation
    hyprlandProfileEvaluation
    noctaliaStub
    noctaliaHomeEvaluation
    soundNixosEvaluation
    soundIntegratedEvaluation
    terminalHomeEvaluation
    terminalFallbackHomeEvaluation
    xdgFoldersHomeEvaluation
    browserHomeEvaluation
    chatgptHomeEvaluation
    vscodeHomeEvaluation
    mcpHomeEvaluation
    aiToolsHomeEvaluation
    gitNixosEvaluation
    gitHomeEvaluation
    direnvNixosEvaluation
    direnvHomeEvaluation
    nhEvaluation
    nixfmtNixosEvaluation
    nixfmtHomeEvaluation
    devenvHomeEvaluation
    nvfHomeEvaluation
    fileManagerHomeEvaluation
    clipboardHomeEvaluation
    screenshotsHomeEvaluation
    bluetoothEvaluation
    laptopBluetoothEvaluation
    laptopEvaluation
    powerManagementEvaluation
    thunderboltEvaluation
    grubBootEvaluation
    defaultEvaluation
    shellHomeProfileEvaluation
    workstationProfileEvaluation
    laptopProfileEvaluation
    secretsProfileEvaluation
    impermanenceProfileEvaluation
    overrideEvaluation
    ;
}
