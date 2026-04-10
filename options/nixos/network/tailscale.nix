{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tailscale;
      defaultText = lib.literalExpression "pkgs.tailscale";
      description = "Tailscale package used for the daemon and CLI.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the firewall for Tailscale.";
    };

    extraUpFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra flags passed to `tailscale up` through `services.tailscale.extraUpFlags`.";
    };
  };
}
