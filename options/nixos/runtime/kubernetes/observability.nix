{
  lib,
  ...
}:
{
  options.qnix.runtime.observability = {
    enable = lib.mkEnableOption "Flux-managed in-cluster observability";

    namespace = lib.mkOption {
      type = lib.types.str;
      default = "observability";
      description = "Namespace where observability resources are deployed.";
    };
  };
}
