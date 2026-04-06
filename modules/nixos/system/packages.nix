{ lib, config, ... }:
{
  options = {
    qnix.system.packages = {
      editor = lib.mkOption {
        type = lib.types.package;
        default = pkgs.neovim;
        description = "The editor to use for the system";
      };

      extra = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Extra packages to install";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.editor
    ]
    ++ cfg.extra;
  };
}
