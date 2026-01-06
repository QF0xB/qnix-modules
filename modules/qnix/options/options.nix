{
  lib,
  pkgs,
  ...
}:

{
  options.qnix = with lib; {
    wayland = mkOption {
      type = types.bool;
      default = false;
      description = "Is wayland running?";
    };

    headless = mkOption {
      type = types.bool;
      default = false;
      description = "Run system without graphical environment.";
    };

    work = mkOption {
      type = types.bool;
      default = false;
      description = "Enable work-related programs and services.";
    };

    development = mkOption {
      type = types.bool;
      default = true;
      description = "Enable development tools.";
    };

    server = mkOption {
      type = types.bool;
      default = false;
      description = "Is this a server?";
    };

    apps = {
      terminal = mkOption {
        type = types.package;
        description = "The default terminal emulator";
        default = pkgs.kitty;
      };
      browser = mkOption {
        type = types.package;
        description = "The default browser";
        default = pkgs.brave;
      };
      file-manager = mkOption {
        type = types.package;
        description = "The default file-manager";
        default = pkgs.nemo;
      };
      notes = mkOption {
        type = types.package;
        description = "Notetaking app";
        default = pkgs.obsidian;
      };
    };
  };
}