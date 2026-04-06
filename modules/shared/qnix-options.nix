{ lib, pkgs, ... }:
{
  options.qnix = {
    profiles = {
      base.enable = lib.mkEnableOption "base profile";
      server.enable = lib.mkEnableOption "server profile";
      workstation.enable = lib.mkEnableOption "workstation profile";
      laptop.enable = lib.mkEnableOption "laptop profile";
    };

    services = {
      openssh.enable = lib.mkEnableOption "openssh";
      fail2ban.enable = lib.mkEnableOption "fail2ban";
      docker.enable = lib.mkEnableOption "docker";
      netbird.enable = lib.mkEnableOption "netbird";
    };

    system = {
      headless = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      primaryUser = lib.mkOption {
        type = lib.types.str;
        default = null;
      };
    }
  }
}