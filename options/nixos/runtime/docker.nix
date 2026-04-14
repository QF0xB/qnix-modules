{ lib, ... }:
{
  options.qnix.runtime.docker = {
    enable = lib.mkEnableOption "Docker runtime";

    addManagedUsersToGroup = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to add the docker group to qnix-managed normal users by default.";
    };
  };
}
