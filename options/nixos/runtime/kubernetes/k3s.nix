{
  lib,
  pkgs,
  ...
}:
{
  options.qnix.runtime.k3s = {
    enable = lib.mkEnableOption "k3s Kubernetes runtime";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.k3s;
      defaultText = lib.literalExpression "pkgs.k3s";
      description = "k3s package used for the system service.";
    };

    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "agent"
      ];
      default = "server";
      description = "Node role in the k3s cluster.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing the shared cluster token.";
    };

    serverAddr = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://10.10.10.10:6443";
      description = "k3s server URL used by agent nodes.";
    };

    clusterInit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this server should initialize a new HA k3s cluster.";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional flags appended to the k3s ExecStart command.";
    };
  };
}
