{ lib, config, ... }:

{
  imports = [
    ./bitwarden/module.nix
    ./keyring/gnome-keyring.nix
  ];
}
