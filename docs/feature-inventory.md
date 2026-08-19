# Feature Inventory

This document tracks the migration from the legacy modules to the QNix SDK
feature and profile model.

This is an intentionally approximate planning inventory. Confirm environment
support and dependencies before turning a row into a detailed contract. The
authoritative contract for an implemented feature is its descriptor under
`features/`.

All entries initially have status `planned`. Values marked with `?` require
confirmation.

## Boot and system

| Feature               | Likely environment | Profiles              | Dependencies | Persistence | Status   | Notes                               |
|-----------------------|--------------------|-----------------------|--------------|-------------|----------|-------------------------------------|
| `system.boot`         | NixOS              | `base`                | —            | —           | planned  | Bootloader and system boot settings |
| `system.localisation` | NixOS              | `base`, `workstation` | —            | —           | finished | Locale, timezone, keyboard          |
| `system.packages`     | NixOS              | `base`                | —            | —           | planned  | Shared system packages              |
| `system.users`        | NixOS              | `base`                | —            | —           | planned  | User declarations and defaults      |
| `system.plymouth`     | NixOS              | `desktop`             | —            | —           | planned  | Boot splash                         |

## Shell and user environment

| Feature          | Likely environment | Profiles              | Dependencies | Persistence       | Status  | Notes                |
|------------------|--------------------|-----------------------|--------------|-------------------|---------|----------------------|
| `shell.fish`     | NixOS + Home       | `base`, `workstation` | —            | Home shell state? | planned | Fish shell setup     |
| `shell.starship` | Home               | `base`, `workstation` | `shell.fish` | —                 | planned | Prompt configuration |

## Hardware and power

| Feature                   | Likely environment | Profiles                | Dependencies    | Persistence | Status  | Notes                     |
|---------------------------|--------------------|-------------------------|-----------------|-------------|---------|---------------------------|
| `hardware.bluetooth`      | NixOS              | `workstation`, `laptop` | —               | —           | planned | Hardware/service          |
| `system.laptop`           | NixOS              | `laptop`                | —               | —           | planned | Laptop-specific behavior  |
| `system.power-management` | NixOS              | `laptop`                | `system.laptop` | —           | planned | Power, upower, and tuning |
| `system.thunderbolt`      | NixOS              | `laptop`                | `system.laptop` | —           | planned | Hardware/service          |

## Networking

| Feature                  | Likely environment | Profiles                        | Dependencies    | Persistence    | Status  | Notes                            |
|--------------------------|--------------------|---------------------------------|-----------------|----------------|---------|----------------------------------|
| `network.addressing`     | NixOS              | `base`                          | —               | —              | planned | Hostname, interfaces, and routes |
| `network.firewall`       | NixOS              | `base`                          | —               | —              | planned | Base firewall                    |
| `network.networkmanager` | NixOS              | `desktop`, `workstation`        | —               | —              | planned | Desktop networking               |
| `network.tailscale`      | NixOS              | `base`, `workstation`, `laptop` | —               | Service state? | planned | VPN/service                      |
| `network.wireguard`      | NixOS              | `base`, `workstation`, `laptop` | `security.sops` | Keys/config?   | planned | VPN/service and secrets          |

## Security and identity

| Feature                  | Likely environment | Profiles                 | Dependencies   | Persistence    | Status  | Notes                            |
|--------------------------|--------------------|--------------------------|----------------|----------------|---------|----------------------------------|
| `security.polkit`        | NixOS              | `desktop`, `workstation` | —              | —              | planned | Desktop dependency               |
| `security.sops`          | NixOS              | `base`, `workstation`    | —              | `.config/sops` | planned | Secrets and persistence          |
| `security.gpg`           | NixOS + Home       | `workstation`            | —              | GPG home       | planned | Key setup and Home configuration |
| `security.gnome-keyring` | NixOS + Home       | `hyprland`               | —              | Keyring        | planned | Desktop session integration      |
| `security.yubikey`       | NixOS + Home       | `workstation`, `laptop`  | `security.gpg` | GPG/U2F state  | planned | Login, sudo, and GPG integration |

## Storage

| Feature                | Likely environment | Profiles               | Dependencies | Persistence          | Status  | Notes               |
|------------------------|--------------------|------------------------|--------------|----------------------|---------|---------------------|
| `persist`              | NixOS              | `base`, `impermanence` | —            | Option-only contract | planned | Persistence schema  |
| `storage.impermanence` | NixOS              | `impermanence`         | `persist`    | Consumes `persist`   | planned | Persistence backend |
| `storage.zfs`          | NixOS              | `base`                 | —            | Pool/system state    | planned | Filesystem/storage  |

## Desktop session

| Feature                               | Likely environment | Profiles   | Dependencies        | Persistence        | Status  | Notes                            |
|---------------------------------------|--------------------|------------|---------------------|--------------------|---------|----------------------------------|
| `desktop.displaymanager`              | NixOS              | `hyprland` | `desktop.wayland`   | —                  | planned | Display manager                  |
| `desktop.wayland`                     | NixOS + Home       | `hyprland` | Desktop foundation? | —                  | planned | Session foundation               |
| `desktop.hyprland`                    | NixOS + Home       | `hyprland` | `desktop.wayland`   | —                  | planned | Main compositor                  |
| `desktop.hyprland.keybinds`           | Home               | `hyprland` | `desktop.hyprland`  | —                  | planned | Hyprland subconfiguration        |
| `desktop.hyprland.rules`              | Home               | `hyprland` | `desktop.hyprland`  | —                  | planned | Hyprland subconfiguration        |
| `desktop.hyprland.special-workspaces` | Home               | `hyprland` | `desktop.hyprland`  | —                  | planned | Hyprland subconfiguration        |
| `desktop.noctalia`                    | NixOS + Home       | `hyprland` | `desktop.wayland`   | Shell state?       | planned | Shell/session integration        |
| `desktop.sound`                       | NixOS + Home       | `desktop`  | `security.polkit`   | —                  | planned | Audio                            |
| `desktop.terminal`                    | NixOS + Home       | `desktop`  | —                   | Terminal config    | planned | Terminal package/config          |
| `desktop.xdg-folders`                 | NixOS + Home       | `desktop`  | —                   | —                  | planned | XDG directories                  |
| `desktop.clipboard`                   | Home               | `desktop`  | `desktop.wayland`   | —                  | planned | Clipboard manager                |
| `desktop.lock`                        | Home               | `desktop`  | `desktop.wayland`   | —                  | planned | Screen locking                   |
| `desktop.screenshots`                 | Home               | `desktop`  | `desktop.wayland`   | Screenshot config? | planned | Screenshot tooling               |
| `desktop.client-pr-notify`            | Home               | `hyprland` | `security.sops`     | —                  | planned | Repository-specific notification |

## Appearance and theming

| Feature             | Likely environment | Profiles     | Dependencies | Persistence  | Status  | Notes   |
|---------------------|--------------------|--------------|--------------|--------------|---------|---------|
| `appearance.stylix` | NixOS + Home       | `appearance` | —            | Theme state? | planned | Theming |

## Applications

| Feature             | Likely environment | Profiles                | Dependencies | Persistence        | Status  | Notes                                                            |
|---------------------|--------------------|-------------------------|--------------|--------------------|---------|------------------------------------------------------------------|
| `apps.browser`      | NixOS + Home       | `desktop`, `personal`   | —            | Browser profile    | planned | Browser package/config                                           |
| `apps.file-manager` | Home               | `desktop`               | —            | —                  | planned | File manager                                                     |
| `apps.chatgpt`      | NixOS + Home       | `personal`, `developer` | —            | ChatGPT app state? | planned | GPT desktop application; package and platform support to confirm |
| `apps.bitwarden`    | NixOS + Home       | `personal`              | —            | Vault/config?      | planned | Package/config; package availability uncertain                   |
| `apps.music`        | NixOS + Home       | `personal`              | —            | Music client state | planned | Music client                                                     |
| `apps.notes`        | NixOS + Home       | `personal`              | —            | Notes data         | planned | Notes application                                                |
| `apps.obs`          | NixOS + Home       | `creator`               | —            | OBS config         | planned | Creator tooling                                                  |
| `apps.social`       | NixOS + Home       | `personal`              | —            | Application state  | planned | Social application                                               |

## Development tools

| Feature              | Likely environment | Profiles                   | Dependencies   | Persistence        | Status  | Notes                                          |
|----------------------|--------------------|----------------------------|----------------|--------------------|---------|------------------------------------------------|
| `dev.codex`          | NixOS + Home       | `developer`                | —              | Codex config?      | planned | Package/config                                 |
| `dev.vscode`         | NixOS + Home       | `developer`, `editor`      | —              | Editor config      | planned | VS Code or another selected editor alternative |
| `dev.devenv`         | NixOS              | `developer`                | —              | —                  | planned | Development environment                        |
| `dev.direnv`         | Home               | `developer`                | `shell.fish`   | —                  | planned | Shell integration                              |
| `dev.git`            | NixOS + Home       | `developer`, `workstation` | `security.gpg` | Git config         | planned | Git, GitHub CLI (`gh`), and signing            |
| `dev.jetbrains`      | NixOS + Home       | `developer`                | —              | IDE config         | planned | IDEs                                           |
| `dev.kubernetes-cli` | NixOS + Home       | `developer`                | —              | Kubernetes config  | planned | Local Kubernetes CLI tooling                   |
| `dev.nh`             | NixOS              | `workstation`              | —              | —                  | planned | Nix maintenance                                |
| `dev.nixfmt`         | NixOS + Home       | `developer`                | —              | —                  | planned | Formatting tools                               |
| `dev.nvf`            | NixOS + Home       | `editor`                   | —              | Editor config      | planned | Editor configuration                           |
| `dev.postman`        | NixOS + Home       | `developer`                | —              | Postman data       | planned | API tooling                                    |
| `dev.docker`         | NixOS + Home       | `developer`                | —              | `/var/lib/docker`? | planned | Local development containers                   |

## Pentesting

| Feature                | Likely environment | Profiles       | Dependencies           | Persistence | Status  | Notes                                                   |
|------------------------|--------------------|----------------|------------------------|-------------|---------|---------------------------------------------------------|
| `pentest.gpu-cracking` | NixOS              | `pentest-host` | GPU hardware           | —           | planned | Host-only GPU cracking tasks                            |
| `pentest.hash-testing` | NixOS              | `pentest-host` | `pentest.gpu-cracking` | —           | planned | Host-only hash testing                                  |
| `pentest.usb-access`   | NixOS              | `pentest-host` | —                      | —           | planned | Host-side USB/device access for passthrough and capture |

## Profiles

Profiles compose features into usable roles. The Kali VM is not represented by a
QNix profile: Kali provides its own operating system, desktop, and pentesting
tool suite.

| Profile        | Environment             | Includes                                                                     | Purpose                                 |
|----------------|-------------------------|------------------------------------------------------------------------------|-----------------------------------------|
| `base`         | NixOS                   | System, shell, networking, and secrets foundation                            | Common host baseline                    |
| `workstation`  | NixOS                   | `base`, hardware basics, NetworkManager, desktop security                    | General workstation                     |
| `laptop`       | NixOS                   | `workstation`, laptop, power, and Thunderbolt features                       | Physical laptop host                    |
| `desktop`      | NixOS                   | `workstation`, desktop session foundations, sound, terminal, and XDG folders | Graphical host baseline                 |
| `hyprland`     | NixOS + standalone Home | Wayland, Hyprland, display/session features                                  | Hyprland desktop environment            |
| `appearance`   | NixOS + standalone Home | Stylix and theming features                                                  | Optional appearance configuration       |
| `developer`    | NixOS + Home            | Development tools and local Docker                                           | Development environment                 |
| `editor`       | NixOS + Home            | NVF/editor features                                                          | Optional editor configuration           |
| `personal`     | NixOS + Home            | Personal applications                                                        | Personal user environment               |
| `creator`      | NixOS + Home            | OBS and creator applications                                                 | Creator workstation                     |
| `pentest-host` | NixOS                   | GPU cracking, hash testing, and USB access                                   | Host-only hardware-dependent pentesting |
| `impermanence` | NixOS                   | Persistence backend and `persist` contract                                   | Optional host storage policy            |

Kali’s own installation determines which pentesting packages are available.
Kali’s own installation determines which pentesting packages and desktop are
available. The selected Kali metapackage should be documented with the VM setup
rather than installed by QNix. If Home Manager is added to the VM later, it can
select ordinary profiles such as `hyprland` without introducing a VM-specific
QNix profile.

## Status values

- `planned` — identified but not started
- `implemented` — feature descriptor exists
- `finished` — evaluation coverage exists
