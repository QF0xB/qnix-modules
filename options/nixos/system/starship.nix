{ lib, ... }:
{
  options.qnix.system.starship = {
    enable = lib.mkEnableOption "starship prompt";

    showIcons = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the starship prompt should use icon glyphs.";
    };

    qnixFormat = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use the custom QNix starship format.";
    };
  };
}
