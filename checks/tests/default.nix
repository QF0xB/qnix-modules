{ ctx }:
{
  repository = import ./repository.nix { inherit ctx; };
  system = import ./system.nix { inherit ctx; };
  desktop = import ./desktop.nix { inherit ctx; };
  hardware = import ./hardware.nix { inherit ctx; };
  networking = import ./networking.nix { inherit ctx; };
  security = import ./security.nix { inherit ctx; };
  appearance = import ./appearance.nix { inherit ctx; };
  storage = import ./storage.nix { inherit ctx; };
  shell = import ./shell.nix { inherit ctx; };
  profiles = import ./profiles.nix { inherit ctx; };
}
