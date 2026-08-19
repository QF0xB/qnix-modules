{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".files = [ ".zsh_history" ];

  options =
    { lib, ... }:
    {
      autosuggestions = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Zsh autosuggestions are enabled.";
      };

      syntaxHighlighting = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Zsh syntax highlighting is enabled.";
      };

      enableCompletion = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Zsh completion is enabled.";
      };
    };

  nixos =
    { cfg, ... }:
    {
      programs.zsh = {
        enable = true;
        autosuggestions.enable = cfg.autosuggestions;
        syntaxHighlighting.enable = cfg.syntaxHighlighting;
        enableCompletion = cfg.enableCompletion;
      };
    };

  home =
    { cfg, ... }:
    {
      programs.zsh = {
        enable = true;
        autosuggestions.enable = cfg.autosuggestions;
        syntaxHighlighting.enable = cfg.syntaxHighlighting;
        enableCompletion = cfg.enableCompletion;
      };
    };
}
