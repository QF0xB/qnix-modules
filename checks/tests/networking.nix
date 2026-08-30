{ ctx }:
with ctx;
assert firewallFeature.supportedEnvironments == [ "nixos" ];
assert firewallEvaluation.config.networking.firewall.enable;
assert
  firewallEvaluation.config.networking.firewall.allowedTCPPorts == [
    22
    443
  ];
assert firewallEvaluation.config.networking.firewall.allowedUDPPorts == [ 51820 ];
assert firewallEvaluation.config.networking.firewall.allowPing;
assert addressingFeature.supportedEnvironments == [ "nixos" ];
assert addressingEvaluation.config.networking.hostName == "addressing-check";
assert addressingEvaluation.config.networking.hostId == "01234567";
assert
  addressingEvaluation.config.networking.nameservers == [
    "1.1.1.1"
    "2606:4700:4700::1111"
  ];
assert addressingEvaluation.config.networking.defaultGateway.address == "192.0.2.1";
assert addressingEvaluation.config.networking.defaultGateway6.address == "2001:db8::1";
assert !addressingEvaluation.config.networking.interfaces.enp1s0.useDHCP;
assert
  addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.addresses == [
    {
      address = "192.0.2.10";
      prefixLength = 24;
    }
  ];
assert builtins.length addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes == 1;
assert
  (builtins.head addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes).address
  == "198.51.100.0";
assert
  (builtins.head addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes).prefixLength
  == 24;
assert
  (builtins.head addressingEvaluation.config.networking.interfaces.enp1s0.ipv4.routes).via
  == "192.0.2.1";
assert networkmanagerFeature.supportedEnvironments == [ "nixos" ];
assert networkmanagerEvaluation.config.networking.networkmanager.enable;
assert !networkmanagerEvaluation.config.networking.useDHCP;
assert networkmanagerEvaluation.config.networking.networkmanager.unmanaged == [ "usb0" ];
assert
  networkmanagerEvaluation.config.networking.networkmanager.plugins
  == [ pkgs.networkmanager-openvpn ];
assert networkmanagerEvaluation.config.programs.nm-applet.enable;
assert
  networkmanagerEvaluation.config.qnix.persist.root.directories
  == [ "/etc/NetworkManager/system-connections" ];
pkgs.runCommand "qnix-networking-check" { } "touch $out"
