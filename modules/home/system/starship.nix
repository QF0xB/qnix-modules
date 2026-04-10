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
    if lib.hasAttrByPath [ "system" "starship" ] qconfig then
      qconfig.system.starship
    else
      {
      enable = false;
      showIcons = true;
      qnixFormat = true;
    };

  colors = {
    fg = "#002b36";
    violet = "#6c71c4";
    cyan = "#2aa198";
    blue = "#268bd2";
    green = "#859900";
    red = "#dc322f";
    yellow = "#b58900";
  };

  icons =
    if cfg.showIcons then
      {
        branch = "";
        nix = "";
        ssh = "󰣀 ";
        ok = "";
        err = " ";
        time = "";
      }
    else
      {
        branch = "git";
        nix = "nix";
        ssh = "ssh ";
        ok = ">";
        err = "x ";
        time = "time";
      };

  separators =
    if cfg.showIcons then
      {
        right = "";
        left = "";
      }
    else
      {
        right = "";
        left = "|";
      };
in
{
  config = lib.mkIf cfg.enable {
    programs.starship =
      let
        text = "fg:${colors.fg}";
      in
      {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableTransience = true;

        settings = lib.mkIf cfg.qnixFormat {
          add_newline = false;
          format = lib.concatStrings [
            "$username"
            (lib.optionalString (separators.right != "") "[${separators.right}](${colors.violet})")

            (lib.optionalString (separators.left != "") "[${separators.left}](${colors.cyan})")
            "$hostname"
            (lib.optionalString (separators.right != "") "[${separators.right}](${colors.cyan})")

            (lib.optionalString (separators.left != "") "[${separators.left}](${colors.blue})")
            "$directory"
            (lib.optionalString (separators.right != "") "[${separators.right}](${colors.blue})")

            (lib.optionalString (separators.left != "") "[${separators.left}](${colors.green})")
            "$git_branch"
            "$git_state"
            "$git_status"
            "$nix_shell"
            (lib.optionalString (separators.right != "") "[${separators.right}](${colors.green})")
            " "
          ];

          character = {
            error_symbol = "[${icons.err}](bold ${colors.red})";
            success_symbol = "[${icons.ok}](bold ${colors.violet})";
            vimcmd_symbol = "[V](bold ${colors.green})";
          };

          username = {
            style_root = "bg:${colors.violet} fg:bold ${colors.fg}";
            style_user = "bg:${colors.violet} fg:bold ${colors.fg}";
            format = "[ $user ]($style)";
            show_always = true;
          };

          hostname = {
            style = "bg:${colors.cyan} ${text}";
            ssh_symbol = icons.ssh;
            ssh_only = false;
            format = "[ $ssh_symbol$hostname ]($style)";
          };

          directory = {
            format = "[ $path ]($style)";
            truncation_length = 1;
            style = "bg:${colors.blue} ${text}";
          };

          git_branch = {
            symbol = icons.branch;
            format = "[ $symbol $branch ]($style)";
            style = "bg:${colors.green} ${text}";
          };

          git_state = {
            format = "( [$state( $progress_current/$progress_total)]($style))";
            style = "bg:${colors.green} ${text}";
          };

          git_status = {
            format = "[($all_status$ahead_behind)]($style)";
            style = "bg:${colors.green} ${text}";
          };

          nix_shell = {
            format = "[ ${icons.nix} ]($style)";
            style = "bg:${colors.green} fg:bold ${colors.fg}";
          };
        };
      };

    programs.fish = lib.mkIf config.programs.fish.enable {
      shellInit = lib.mkAfter ''
        function prompt_newline --on-event fish_postexec
          echo ""
        end
      '';

      interactiveShellInit = lib.mkAfter ''
        function starship_transient_prompt_func
          starship module character
        end
      '';
    };
  };
}
