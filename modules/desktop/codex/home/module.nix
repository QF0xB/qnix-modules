{ lib, osConfig, ... }:

let
  cfg = osConfig.qnix.desktop.codex;
in
{
  config = lib.mkIf cfg.enable {
    programs.codex = {
      enable = true;
      package = cfg.package;
      enableMcpIntegration = cfg.enableMcpIntegration;
      settings = cfg.settings;
      custom-instructions = cfg.customInstructions;
      skills = cfg.skills;
    };
  };
}
