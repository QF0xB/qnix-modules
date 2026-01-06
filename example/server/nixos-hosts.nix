{
  inputs,
  pkgs,
  lib,
  specialArgs,
  ...
}@args:
let
  mkNixosConfiguration =
    host:
    {
      pkgs ? args.pkgs,
      user ? "admin",
      isVm ? false,
      isInstall ? false,
      isLaptop ? false,
      isNixOS ? true,
      extraConfig ? { },
    }:
    lib.nixosSystem {
      inherit pkgs;

      specialArgs = specialArgs // {
        # Full inputs needed for imports (inputs.qnix-modules, etc.)
        inherit inputs;
        # categories and filtered inputs are already in specialArgs from flake.nix
        inherit
          host
          isVm
          isInstall
          isLaptop
          isNixOS
          user
          ;
        dots = "/persist/home/${user}/projects/dotfiles";
      };

      modules = [
        # Host-specific configuration
        ./${host}/configuration.nix
        ./${host}/hardware.nix

        # Load QNix modules (will use categories from specialArgs - only core)
        inputs.qnix-modules.nixosModules.qnix

        # Home Manager (optional for servers)
        inputs.home-manager.nixosModules.home-manager

        {
          nix.settings.trusted-users = [ user ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = specialArgs // {
              # Full inputs needed for imports
              inherit inputs;
              # categories and filtered inputs are already in specialArgs from flake.nix
              inherit
                host
                isVm
                isInstall
                isLaptop
                isNixOS
                user
                ;
              dots = "/persist/home/${user}/projects/dotfiles";
            };

            users.${user} = {
              imports = [
                # Load QNix Home Manager modules (will use categories from specialArgs)
                inputs.qnix-modules.homeManagerModules.qnix
                ./${host}/home.nix
                ./${host}/qnix.nix  # qnix.* options for this host
              ];
            };
          };
        }

        # Server-specific modules
        inputs.sops-nix.nixosModules.sops

        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])

        extraConfig
      ];
    };
in
{
  myserver = mkNixosConfiguration "myserver" { };
  myserver-install = mkNixosConfiguration "myserver" { isInstall = true; };
}

