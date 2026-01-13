{ config, lib, ... }:

let
  treesitterLanguages = [
    "bash"
    "clang"
    "css"
    "go"
    "html"
    "java"
    "lua"
    "markdown"
    "nix"
    "python"
    "rust"
    "sql"
    "yaml"
  ];

  treeSitterEnables = builtins.listToAttrs (
    builtins.map (lang: {
      name = lang;
      value = {
        treesitter.enable = true;
      };
    }) treesitterLanguages
  );
in
{
  config = lib.mkIf config.qnix.core.nvf.enable {
    programs.nvf.settings.vim = {
      treesitter = {
        enable = true;
        fold = true;

        highlight = {
          enable = true;
        };

        indent = {
          enable = true;
        };

        addDefaultGrammars = true;

        autotagHtml = true;

        context = {
          enable = true;
          setupOpts = {
            line_numbers = true;
          };
        };
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;
      }
      // treeSitterEnables;
    };
  };
}
