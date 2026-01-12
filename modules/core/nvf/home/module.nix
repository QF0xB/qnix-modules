{ lib, config, ... }:

let
  cfg = config.qnix.core.nvf;
in
{
  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      defaultEditor = true;

      settings = {
        vim = {
          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            nix.enable = true;
            clang.enable = true;
            python.enable = true;
          };

          spellcheck = lib.mkIf cfg.spellcheck.enable {
            enable = true;
            languages = cfg.spellcheck.languages;
            vim-dirtytalk.enable = true;
            programmingWordlist.enable = true;
            extraSpellWords = {
              "en.utf-8" = cfg.spellcheck.additionalWords;
            };
          };

          lsp = {
            enable = true;
            formatOnSave = true;
            lightbulb.enable = true;

            otter-nvim.enable = true;
            lspSignature.enable = true;

            servers = {
              nixd = {
                enable = true;
                cmd = [ "${pkgs.nixd}/bin/nixd" ];
                settings = {
                  nixpkgs = {
                    expr = "import <nixpkgs> { }";
                  };
                  formatting.command = [ "${pkgs.alejandra}/bin/alejandra" ];
                  diagnostics = {
                    suppress = [ "unused_binding" ];
                  };
                };
              };

              nil_ls = {
                enable = true;
                cmd = [ "${pkgs.nil}/bin/nil" ];
                settings = {
                  formatting.command = [ "${pkgs.alejandra}/bin/alejandra" ];
                  nix.flake.autoEvalInputs = true;
                };
              };

              lua_ls.enable = true;
              bashls.enable = true;
              jsonls.enable = true;
              yamlls.enable = true;
              pyright = {
                enable = true;
              };
              clangd = {
                enable = true;
              };
            };
          };

          autopairs.nvim-autopairs.enable = true;

          autocomplete.nvim-cmp = {
            enable = true;
            sources = {
              path = "[Path]";
            };
          };

          luaConfigRC = {
            "qnix-lsp.lua" = ''
              local lspconfig = require("lspconfig")
              local util = require("lspconfig.util")

              -- Automatically detect flake/git root
              local nix_root = util.root_pattern("flake.nix", ".git")

              -- Override default nixd/nil_ls root dirs
              lspconfig.nixd.setup({
                root_dir = nix_root,
              })
              lspconfig.nil_ls.setup({
                root_dir = nix_root,
              })
            '';
          };

          treesitter = {
            enable = true;
            highlight.enable = true;
            indent.enable = true;
            autotagHtml = true;
          };

          git = {
            enable = true;
            neogit.enable = true;
          };

          # visuals = {
          # nvim-cursorline = {
          # enable = true;
          #setupOpts = {
          #cursorline.enable = true;
          #cursorword.enable = true;
          #};
          #};
          # };

          statusline = {
            lualine.enable = true;
          };

          ui = {
            illuminate.enable = true;
          };
        };
      };
    };
    qnix.persist.home.directories = [
      ".local/share/nvf/site/spell"
    ];
  };
}
