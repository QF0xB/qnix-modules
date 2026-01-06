{ pkgs, lib, ... }:

{
  networking.hostName = "myhost";
  networking.hostId = "01234567";  # Generate with: head -c 8 /etc/machine-id

  system.stateVersion = "24.11";
}

