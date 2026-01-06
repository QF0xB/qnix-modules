{ pkgs, lib, ... }:

{
  networking.hostName = "myserver";
  networking.hostId = "01234567";  # Generate with: head -c 8 /etc/machine-id

  system.stateVersion = "25.11";
}

