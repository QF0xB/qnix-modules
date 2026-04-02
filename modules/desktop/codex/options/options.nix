{
  lib,
  config ? null,
  pkgs ? null,
  ...
}:

{
  options.qnix.desktop.codex = {
    enable = lib.mkEnableOption "Codex" // {
      default = config != null && config.qnix.development && !config.qnix.headless;
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = "Codex package to install via Home Manager.";
      default = if pkgs != null then pkgs.codex else null;
    };

    enableMcpIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Merge programs.mcp.servers into Codex MCP settings.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Settings written to Codex config.toml.";
    };

    customInstructions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Custom instructions written to Codex AGENTS.md.";
    };

    skills = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      description = "Custom Codex skills passed through to Home Manager programs.codex.skills.";
    };
  };
}
