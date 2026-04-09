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
    if lib.hasAttrByPath [ "dev" "direnv" ] qconfig then
      qconfig.dev.direnv
    else
      { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
