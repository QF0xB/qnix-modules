{
  imports = [ "base" ];

  features.nixos = [
    "hardware.bluetooth"
    "hardware.thunderbolt"
    "network.networkmanager"
  ];
}
