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
  cfg =
    if lib.hasAttrByPath [ "desktop" "terminal" ] qconfig then
      qconfig.desktop.terminal
    else
      { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = cfg.package;
      shellIntegration.enableFishIntegration = true;
      shellIntegration.enableZshIntegration = true;
    };
  };
}
