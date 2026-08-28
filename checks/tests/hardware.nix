{ ctx }:
with ctx;
assert bluetoothFeature.supportedEnvironments == [ "nixos" ];
assert bluetoothEvaluation.config.hardware.bluetooth.enable;
assert !bluetoothEvaluation.config.hardware.bluetooth.powerOnBoot;
assert bluetoothEvaluation.config.hardware.bluetooth.settings.General.Experimental;
assert bluetoothEvaluation.config.services.blueman.enable;
assert !laptopBluetoothEvaluation.config.hardware.bluetooth.powerOnBoot;
assert laptopFeature.supportedEnvironments == [ "nixos" ];
assert laptopEvaluation.config.services.libinput.enable;
assert !laptopEvaluation.config.services.libinput.touchpad.tapping;
assert !laptopEvaluation.config.services.libinput.touchpad.naturalScrolling;
assert laptopEvaluation.config.services.logind.settings.Login.HandleLidSwitch == "hibernate";
assert
  laptopEvaluation.config.services.logind.settings.Login.HandleLidSwitchExternalPower == "lock";
assert laptopEvaluation.config.services.logind.settings.Login.HandleLidSwitchDocked == "ignore";
assert laptopEvaluation.config.services.logind.settings.Login.HandlePowerKey == "suspend";
assert powerManagementFeature.supportedEnvironments == [ "nixos" ];
assert powerManagementEvaluation.config.services.upower.enable;
assert powerManagementEvaluation.config.services.power-profiles-daemon.enable;
assert powerManagementEvaluation.config.powerManagement.cpuFreqGovernor == "schedutil";
assert thunderboltFeature.supportedEnvironments == [ "nixos" ];
assert thunderboltEvaluation.config.services.hardware.bolt.enable;
assert thunderboltEvaluation.config.services.hardware.bolt.package == pkgs.bolt;
pkgs.runCommand "qnix-hardware-check" { } "touch $out"
