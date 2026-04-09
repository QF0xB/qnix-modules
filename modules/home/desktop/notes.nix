{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.desktop.notes or { enable = false; };
  isObsidian = lib.hasInfix "obsidian" (lib.getName cfg.package);
in
{
  config = lib.mkIf cfg.enable {
    programs.obsidian = lib.mkIf isObsidian {
      enable = true;
      package = cfg.package;
    };

    home.packages = lib.optionals (!isObsidian) [ cfg.package ];
  };
}
