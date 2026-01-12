{ lib, ... }:

{
  options.qnix.core.shell = {
    enable = lib.mkEnableOption "shell managerment" // {
      default = true;
      description = "Whether to enable shell managerment";
    };

    fish = {
      enable = lib.mkEnableOption "fish" // {
        default = true;
        description = "Whether to enable fish";
      };
    };

    defaultShell = lib.mkEnableOption "default shell" // {
      default = true;
      description = "Whether to enable default shell";
    };

    aliases = lib.mkEnableOption "aliases" // {
      default = true;
      description = "Whether to enable aliases";
    };

    qnix-aliases = lib.mkEnableOption "aliases for qnix-system" // {
      default = true;
      description = "Whether to enable aliases for qnix-system";
    };
  };
}
