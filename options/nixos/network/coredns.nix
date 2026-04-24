{ lib, pkgs, ... }:
{
  options.qnix.network.coredns = {
    enable = lib.mkEnableOption ''
      CoreDNS as a network DNS resolver (recursive forwarder). Intended for dedicated
      replicas that serve the whole network; point clients at the same upstream list on
      each machine for redundant resolvers.
    '';

    package = lib.mkPackageOption pkgs "coredns" { };

    corefile = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = ''
        Verbatim CoreDNS Corefile. When null, a block for `.:53` is generated from
        `staticHosts`, `forwardUpstreams` (errors, log, health, forward, cache). Override
        this for full control; `staticHosts` is then ignored.
      '';
    };

    staticHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "router.lan" = "192.168.1.1";
        "nas.lan" = "192.168.1.2";
      };
      description = ''
        Static `A` records merged into the generated server block via the `hosts` plugin
        (`IP hostname` per line, then `fallthrough` to `forward`). Unused when `corefile`
        is set.
      '';
    };

    forwardUpstreams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      description = ''
        Resolver addresses for the `forward` plugin when `corefile` is null. Ignored when
        `corefile` is set.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments passed to the `coredns` binary (see `services.coredns.extraArgs`).";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open TCP and UDP port 53 on `qnix.network.firewall`.";
    };
  };
}
