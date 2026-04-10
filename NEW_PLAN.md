# QNix Rework Target

  ## Goal
  Rework `qnix-modules` from a category-based module library into a profiles-and-services system that still
  covers:

  - all current client functionality
  - server roles
  - NetBird
  - Kubernetes
  - future NixOS VM/server deployments

  ## Core Design

  ### Principles
  - `profiles` describe **roles**
  - `modules` describe **capabilities**
  - `nixos` profiles are for **machine roles**
  - `home` profiles are for **user roles**
  - keep consuming repos thin
  - keep environment-specific values out of `qnix-modules`

  ### High-level split
  - `profiles/nixos` = machine composition
  - `profiles/home` = user composition
  - `modules/nixos` = reusable NixOS capabilities
  - `modules/home` = reusable Home Manager capabilities
  - `modules/shared` = top-level public option schema

  ---

  ## Target File Structure

  ```text
  modules/
  ├── flake.nix
  ├── loader/
  │   ├── nixos.nix
  │   └── home.nix
  ├── profiles/
  │   ├── nixos/
  │   │   ├── base.nix
  │   │   ├── server.nix
  │   │   ├── workstation.nix
  │   │   ├── laptop.nix
  │   │   ├── vm.nix
  │   │   ├── vpn-node.nix
  │   │   ├── kubernetes-control-plane.nix
  │   │   ├── kubernetes-worker.nix
  │   │   └── container-host.nix
  │   └── home/
  │       ├── base.nix
  │       ├── developer.nix
  │       ├── workstation.nix
  │       └── writer.nix
  ├── modules/
  │   ├── shared/
  │   │   └── qnix-options.nix
  │   ├── nixos/
  │   │   ├── system/
  │   │   │   ├── boot.nix
  │   │   │   ├── localisation.nix
  │   │   │   ├── users.nix
  │   │   │   ├── nix-settings.nix
  │   │   │   └── state-version.nix
  │   │   ├── networking/
  │   │   │   ├── networkmanager.nix
  │   │   │   ├── firewall.nix
  │   │   │   ├── tailscale.nix
  │   │   │   ├── netbird.nix
  │   │   │   ├── openvpn-client.nix
  │   │   │   └── kubernetes-networking.nix
  │   │   ├── security/
  │   │   │   ├── openssh.nix
  │   │   │   ├── fail2ban.nix
  │   │   │   ├── gpg.nix
  │   │   │   ├── yubikey.nix
  │   │   │   └── sops.nix
  │   │   ├── storage/
  │   │   │   ├── impermanence.nix
  │   │   │   └── zfs.nix
  │   │   ├── runtime/
  │   │   │   ├── docker.nix
  │   │   │   ├── virt-manager.nix
  │   │   │   └── microcontroller.nix
  │   │   ├── desktop/
  │   │   │   ├── displaymanager.nix
  │   │   │   ├── sound.nix
  │   │   │   ├── hyprland.nix
  │   │   │   ├── laptop-hardware.nix
  │   │   │   ├── thunderbolt.nix
  │   │   │   ├── openrgb.nix
  │   │   │   └── stylix.nix
  │   │   └── cluster/
  │   │       ├── k3s-server.nix
  │   │       ├── k3s-agent.nix
  │   │       └── kube-tools.nix
  │   └── home/
  │       ├── shell/
  │       │   ├── fish.nix
  │       │   ├── git.nix
  │       │   ├── starship.nix
  │       │   ├── lsd.nix
  │       │   └── terminal-tools.nix
  │       ├── editors/
  │       │   ├── nvf.nix
  │       │   ├── vscode.nix
  │       │   └── jetbrains.nix
  │       ├── apps/
  │       │   ├── browser.nix
  │       │   ├── obsidian.nix
  │       │   ├── tidal-hifi.nix
  │       │   ├── bitwarden.nix
  │       │   └── codex.nix
  │       ├── desktop/
  │       │   ├── xdg-folders.nix
  │       │   ├── hyprdesktop.nix
  │       │   └── noctalia.nix
  │       └── development/
  │           ├── developer-tools.nix
  │           └── kubernetes-cli.nix

  ———

  ## NixOS Profiles

  These are host or machine roles.

  ### base

  Shared baseline for all NixOS hosts.

  Should include:

  - timezone defaults
  - nix settings baseline
  - common state/defaults
  - no heavy role assumptions

  ### server

  Headless server baseline.

  Should include:

  - base
  - SSH enabled by default
  - fail2ban enabled by default
  - headless mode
  - no desktop stack

  ### workstation

  Desktop machine baseline.

  Should include:

  - base
  - desktop-oriented defaults
  - NetworkManager
  - sound
  - polkit
  - graphical host assumptions

  ### laptop

  Laptop-specific additions.

  Should include:

  - workstation
  - laptop hardware handling
  - power/periphery
  - optional fingerprint/yubikey/lid behavior

  ### vm

  Virtual machine baseline.

  Should include:

  - qemu/VM guest assumptions
  - no laptop-specific behavior

  ### vpn-node

  VPN-oriented host.

  Should include:

  - networking baseline for NetBird / Tailscale / OpenVPN
  - useful for access nodes and remote access hosts

  ### container-host

  Container runtime host.

  Should include:

  - Docker or related runtime defaults

  ### kubernetes-control-plane

  Kubernetes control plane node.

  Should include:

  - server baseline
  - k3s/k8s control plane features
  - optional kube admin tooling

  ### kubernetes-worker

  Kubernetes worker node.

  Should include:

  - server baseline
  - k3s/k8s worker features

  ———

  ## Home Profiles

  These are user/session roles.

  ### base

  Shared user baseline.

  Should include:

  - shell basics
  - git
  - starship
  - terminal tooling

  ### workstation

  Desktop user baseline.

  Should include:

  - browser
  - obsidian
  - xdg-folders
  - desktop-user defaults

  ### developer

  Developer user profile.

  Should include:

  - nvf
  - vscode
  - jetbrains
  - codex
  - development tooling

  ### writer

  Writing-focused user profile.

  Should include:

  - browser
  - obsidian
  - terminal basics
  - minimal editing tools
  - intentionally less heavy than developer

  ———

  ## NixOS Modules

  ### System

  - boot.nix
  - localisation.nix
  - users.nix
  - nix-settings.nix
  - state-version.nix

  ### Networking

  - networkmanager.nix
  - firewall.nix
  - tailscale.nix
  - netbird.nix
  - openvpn-client.nix
  - kubernetes-networking.nix

  ### Security

  - openssh.nix
  - fail2ban.nix
  - gpg.nix
  - yubikey.nix
  - sops.nix

  ### Storage

  - impermanence.nix
  - zfs.nix

  ### Runtime

  - docker.nix
  - virt-manager.nix
  - microcontroller.nix

  ### Desktop / Hardware

  - displaymanager.nix
  - sound.nix
  - hyprland.nix
  - laptop-hardware.nix
  - thunderbolt.nix
  - openrgb.nix
  - stylix.nix

  ### Cluster

  - k3s-server.nix
  - k3s-agent.nix
  - kube-tools.nix

  ———

  ## Home Modules

  ### Shell

  - fish.nix
  - git.nix
  - starship.nix
  - lsd.nix
  - terminal-tools.nix

  ### Editors

  - nvf.nix
  - vscode.nix
  - jetbrains.nix

  ### Apps

  - browser.nix
  - obsidian.nix
  - tidal-hifi.nix
  - bitwarden.nix
  - codex.nix

  ### Desktop

  - xdg-folders.nix
  - hyprdesktop.nix
  - noctalia.nix

  ### Development

  - developer-tools.nix
  - kubernetes-cli.nix

  ———

  ## Public Option Shape

  The new public API should be grouped by concern, not by old category.

  ### NixOS-side

  qnix = {
    profiles.nixos = {
      base.enable = true;
      server.enable = false;
      workstation.enable = false;
      laptop.enable = false;
      vm.enable = false;
      vpnNode.enable = false;
      containerHost.enable = false;
      kubernetesControlPlane.enable = false;
      kubernetesWorker.enable = false;
    };

    system = {
      headless = false;
      stateVersion = "24.11";
      boot = { ... };
      localisation = { ... };
      nix = { ... };
    };

    users = {
      enable = true;
      primaryUser = "q.braendli";
      root = { ... };
      users = { ... };
    };

    networking = {
      networkmanager = { ... };
      firewall = { ... };
      openvpnClient = { ... };
      netbird = { ... };
      tailscale = { ... };
    };

    security = {
      openssh = { ... };
      fail2ban = { ... };
      gpg = { ... };
      sops = { ... };
      yubikey = { ... };
    };

    storage = {
      impermanence = { ... };
      zfs = { ... };
    };

    runtime = {
      docker = { ... };
      virtManager = { ... };
      microcontroller = { ... };
    };

    desktop = {
      displaymanager = { ... };
      sound = { ... };
      hyprland = { ... };
      laptopHardware = { ... };
      thunderbolt = { ... };
      openrgb = { ... };
      stylix = { ... };
    };

    cluster = {
      k3s = {
        enable = false;
        role = "server";
      };
      tools.enable = false;
    };
  };

  ### Home-side

  qnix = {
    profiles.home = {
      base.enable = true;
      workstation.enable = false;
      developer.enable = false;
      writer.enable = false;
    };

    shell = {
      fish.enable = true;
      git = { ... };
      starship.enable = true;
      lsd.enable = true;
      terminalTools.enable = true;
    };

    editors = {
      nvf = { ... };
      vscode = { ... };
      jetbrains = { ... };
    };

    apps = {
      browser = { ... };
      obsidian = { ... };
      tidalHifi.enable = true;
      bitwarden = { ... };
      codex.enable = true;
    };

    desktop = {
      hyprdesktop = { ... };
      noctalia.enable = true;
      xdgFolders.enable = true;
    };

    development = {
      tools.enable = true;
      kubernetesCli.enable = false;
    };
  };

  ———

  ## Current Client Coverage Mapping

  The new design must cover all currently used client features.

  ### Currently used NixOS-side features

  - boot
  - docker
  - fail2ban
  - gpg
  - impermanence
  - localisation
  - lsd
  - microcontroller
  - networkmanager
  - firewall
  - nvf
  - passwords / bitwarden
  - plymouth
  - polkit
  - shell / fish
  - sops
  - ssh-server
  - starship
  - stylix
  - user management
  - virt-manager
  - openvpn client
  - yubikey
  - zfs

  ### Currently used Home / desktop-side features

  - browser
  - displaymanager / sddm
  - hyprdesktop
  - noctalia
  - codex
  - jetbrains
  - laptop specifics
  - obsidian
  - openrgb
  - thunderbolt / periphery
  - sound
  - terminal
  - tidal-hifi
  - vscode
  - xdg-folders

  ### Planned future features

  - NetBird
  - Kubernetes control plane / worker roles
  - server deployment roles
  - NixOS VM/server composition in foundation

  ———

  ## qnix-client Migration Target

  ### Replace category loading

  Remove:

  - defaultCategories
  - categoryOverrides
  - categories

  Replace with:

  - defaultNixosProfiles
  - defaultHomeProfiles
  - nixosProfileOverrides
  - homeProfileOverrides

  ### Example target

  specialArgs = {
    defaultNixosProfiles = [
      "base"
      "workstation"
    ];

    defaultHomeProfiles = [
      "base"
      "workstation"
      "developer"
    ];
  };

  ### Example host overrides

  nixosProfileOverrides = {
    QConfigVM = [ "base" "workstation" "vm" ];
    QTestVM = [ "base" "workstation" "vm" ];
    QFrame13 = [ "base" "workstation" "laptop" ];
    QPCv1 = [ "base" "workstation" ];
    QPCv2 = [ "base" "workstation" ];
  };

  homeProfileOverrides = {
    QConfigVM = [ "base" "workstation" "developer" ];
    QTestVM = [ "base" "workstation" "developer" ];
    QFrame13 = [ "base" "workstation" "developer" ];
    QPCv1 = [ "base" "workstation" "developer" ];
    QPCv2 = [ "base" "workstation" "developer" ];
  };

  ———

  ## Migration Rule

  Do the migration in this order:

  1. stabilize the new loader
  2. define the new public option tree
  3. add the new profiles
  4. add the missing modules behind that tree
  5. migrate one test host
  6. migrate all client hosts
  7. migrate server/foundation consumers
  8. delete old category-based structure only after the new path evaluates cleanly