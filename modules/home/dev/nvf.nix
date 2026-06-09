{
  lib,
  config,
  osConfig ? null,
  pkgs,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.dev.nvf or { enable = false; };

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
  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true;
      settings.vim = {
        autocomplete.blink-cmp = {
          enable = true;
          mappings = {
            close = "<C-e>";
            complete = "<C-Space>";
            confirm = "<CR>";
            next = "<Tab>";
            previous = "<S-Tab>";
            scrollDocsDown = "<C-f>";
            scrollDocsUp = "<C-d>";
          };
          sourcePlugins = {
            emoji.enable = true;
            ripgrep.enable = true;
            spell.enable = true;
          };
          setupOpts = {
            signature = {
              enabled = true;
              trigger.enabled = true;
            };
            sources = {
              default = [
                "lsp"
                "snippets"
                "spell"
                "path"
                "buffer"
              ];
              providers = {
                lsp = {
                  min_keyword_length = 3;
                  score_offset = 5;
                };
                snippets = {
                  min_keyword_length = 2;
                  score_offset = 4;
                };
                spell = {
                  min_keyword_length = 3;
                  score_offset = 3;
                };
                path = {
                  min_keyword_length = 3;
                  score_offset = 2;
                };
                buffer = {
                  min_keyword_length = 5;
                  score_offset = 1;
                };
              };
            };
            cmdline.keymap.preset = "none";
            completion = {
              documentation.auto_show = true;
              menu.auto_show = true;
            };
          };
        };

        autopairs.nvim-autopairs.enable = true;

        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };

        keymaps = [
          {
            key = "<leader>nn";
            mode = "n";
            silent = true;
            action = "<cmd>Neotree toggle<CR>";
            desc = "Toggle Neotree filesystem show";
          }
          {
            key = "<leader>ht";
            mode = "n";
            silent = true;
            action = "<cmd>Hardtime toggle<CR>";
            desc = "Toggle HardTime";
          }
        ];

        options = {
          number = true;
          relativenumber = true;
          tabstop = 2;
          softtabstop = 2;
          showtabline = 2;
          expandtab = true;
          autoindent = true;
          smartindent = true;
          shiftwidth = 2;
          breakindent = true;
          foldcolumn = "1";
          foldlevel = 99;
          foldlevelstart = 99;
          foldenable = false;
          wrap = false;
        };

        binds = {
          whichKey = {
            enable = true;
            register = {
              "<leader>f" = "+files";
              "<leader>s" = "+splits/session";
              "<leader>m" = "+minimap/buffers";
              "<leader>b" = "+buffers";
              "<leader>g" = "+git";
            };
            setupOpts = {
              preset = "modern";
              notify = true;
              win.border = "rounded";
            };
          };

          hardtime-nvim.enable = false;
        };

        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            default_format_opts = {
              lsp_format = "fallback";
            };
            formatters_by_ft = {
              java = [ "google_java_format" ];
            };
          };
        };

        filetree.neo-tree.enable = true;

        git = {
          enable = true;
          neogit.enable = true;
        };

        languages = lib.recursiveUpdate {
          enableFormat = true;
          enableDAP = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          bash = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
          };

          clang = {
            enable = true;
            cHeader = true;
            dap.enable = true;
            lsp.enable = true;
          };

          css = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
          };

          go = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            dap.enable = true;
          };

          java = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };

          lua = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
          };

          nix = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            lsp.servers = [ "nixd" ];
            extraDiagnostics.enable = true;
            extraDiagnostics.types = [
              "statix"
              "deadnix"
            ];
          };

          markdown = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            extensions.markview-nvim.enable = true;
            extensions.render-markdown-nvim.enable = true;
          };

          python = {
            enable = true;
            format.enable = true;
          };

          rust = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
          };

          sql = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
          };

          yaml = {
            enable = true;
            lsp.enable = true;
          };
        } treeSitterEnables;

        lsp = {
          enable = true;
          lspconfig.enable = true;
          formatOnSave = true;
          lspSignature.enable = false;
          lspkind.enable = true;
          lspsaga = {
            enable = true;
            setupOpts.lightbulb.enable = false;
          };
          inlayHints.enable = true;
          lightbulb.enable = false;
        };

        notify.nvim-notify.enable = true;

        projects.project-nvim = {
          enable = true;
          setupOpts = {
            detection_methods = [
              "lsp"
              "pattern"
            ];
            patterns = [
              ".git"
              "flake.nix"
              "Cargo.toml"
              "CMakeLists.txt"
              "Makefile"
              "stack.yaml"
              "*.cabal"
              "package.yaml"
              "package.json"
              "yarn.lock"
              ".project"
              ".solution"
              ".solution.toml"
            ];
            exclude_dirs = [
              "~/"
              "~/.config"
              "~/.nixpkgs"
            ];
            manual_mode = true;
            silent_chdir = true;
            scope_chdir = "global";
          };
        };

        spellcheck = {
          enable = cfg.spellcheck.enable;
          languages = cfg.spellcheck.languages;
          vim-dirtytalk.enable = true;
          programmingWordlist.enable = true;
          extraSpellWords = {
            "en.utf-8" = cfg.spellcheck.additionalWords;
          };
        };

        treesitter = {
          enable = true;
          fold = true;
          highlight.enable = true;
          indent.enable = true;
          addDefaultGrammars = true;
          autotagHtml = true;
          context = {
            enable = true;
            setupOpts.line_numbers = true;
          };
        };

        startPlugins = with pkgs.vimPlugins; [
          barbecue-nvim
          nvim-navic
        ];

        pluginRC.barbecue-nvim = ''
          vim.opt.updatetime = 200

          require("barbecue").setup({
            attach_navic = true,
            theme = "auto",
            show_modified = true,
          })
        '';

        pluginRC.nix-braces = ''
          -- In Nix files, let `=` followed by `{` expand to `{  };` and keep the cursor inside.
          local npairs = require("nvim-autopairs")
          local Rule = require("nvim-autopairs.rule")
          local cond = require("nvim-autopairs.conds")

          npairs.add_rules({
            Rule("=%s*{$", "  };", "nix")
              :use_regex(true, "{")
              :set_end_pair_length(3)
              :with_move(cond.none()),
          })

          -- In Nix files, turn `{  };` into a multiline attrset on <CR> and keep the trailing `;`.
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "nix",
            callback = function(ev)
              local termcodes = function(keys)
                return vim.api.nvim_replace_termcodes(keys, true, false, true)
              end

              vim.keymap.set("i", "<CR>", function()
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                local line = vim.api.nvim_get_current_line()
                local before = line:sub(1, col)
                local after = line:sub(col + 1)

                if before:match("{%s*$") and after:match("^%s*};") then
                  local base_indent = line:match("^%s*") or ""
                  local shiftwidth = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
                  local inner_indent = base_indent .. string.rep(" ", shiftwidth)
                  local open_line = before:gsub("%s*$", "")
                  local close_suffix = after:match("^%s*(};.*)$")

                  vim.schedule(function()
                    if not vim.api.nvim_buf_is_valid(ev.buf) then
                      return
                    end

                    vim.api.nvim_buf_set_lines(ev.buf, row - 1, row, false, {
                      open_line,
                      inner_indent,
                      base_indent .. close_suffix,
                    })
                    vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
                  end)

                  return ""
                end

                return termcodes("<CR>")
              end, {
                buffer = ev.buf,
                expr = true,
                noremap = true,
                silent = true,
              })
            end,
          })
        '';

        statusline.lualine = {
          enable = true;
          disabledFiletypes.statusline = [ "alpha" ];
        };

        tabline.nvimBufferline = {
          enable = true;
          setupOpts.options = {
            show_buffer_close_icons = true;
            show_close_icon = false;
            show_filename_only = true;
            numbers = "none";
            modified_icon = "●";
            show_modified_icon = {
              __raw = ''
                function(buf)
                  return buf.modified
                end
              '';
            };
            show_tab_indicators = false;
            separator_style = "thin";
            diagnostics = false;
            indicator.style = "none";
          };
          mappings = {
            cycleNext = "<leader>bl";
            cyclePrevious = "<leader>bh";
            closeCurrent = "<leader>bx";
            pick = "<leader>bp";
            moveNext = "<leader>me";
            movePrevious = "<leader>mq";
          };
        };

        ui.borders.plugins.lspsaga = {
          enable = true;
          style = "rounded";
        };
      };
    };

    home.packages = [
      pkgs.ripgrep
      pkgs.nixfmt
      pkgs.black
      pkgs.rustfmt
    ];
  };
}
