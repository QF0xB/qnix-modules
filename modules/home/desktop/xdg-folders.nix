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
    if lib.hasAttrByPath [ "desktop" "xdg-folders" ] qconfig then
      qconfig.desktop.xdg-folders
    else
      { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
