{ lib, ... }:

{
  imports = [
    ./bitwarden/options.nix
    ./keyring/options.nix
  ];
}
