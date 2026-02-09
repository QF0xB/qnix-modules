{
  lib,
  osConfig,
  config,
  inputs ? null,
  ...
}:

let
  cfg = osConfig.qnix.core.starship;

  # Convert stylix base16 colors to solarized naming scheme
  stylixToSolarized = base16: {
    base03 = base16.base03 or "";
    base02 = base16.base02 or "";
    base01 = base16.base01 or "";
    base00 = base16.base00 or "";
    base0 = base16.base04 or "";
    base1 = base16.base05 or "";
    base2 = base16.base06 or "";
    base3 = base16.base07 or "";
    red = base16.base08 or "";
    orange = base16.base09 or "";
    yellow = base16.base0A or "";
    green = base16.base0B or "";
    cyan = base16.base0C or "";
    blue = base16.base0D or "";
    violet = base16.base0E or "";
    magenta = base16.base0F or "";
  };

  # Try to get colors from stylix
  # First try the exposed solarizedColors, then try base16 directly
  solarizedColors = osConfig.qnix.core.stylix.solarizedColors or null;
  stylixBase16 = osConfig.stylix.base16 or { };
  
  # Convert base16 if we have it but not solarizedColors
  convertedColors = if solarizedColors == null && stylixBase16 != { } then
    stylixToSolarized stylixBase16
  else if solarizedColors != null then
    solarizedColors
  else
    { };
  
  # Check if colors are actually populated (not empty strings)
  hasColors = (convertedColors.base03 or "") != "";
  
  # Fallback solarized-dark colors if stylix colors aren't available
  fallbackColors = {
    base03 = "#002b36";
    base02 = "#073642";
    base01 = "#586e75";
    base00 = "#657b83";
    base0 = "#839496";
    base1 = "#93a1a1";
    base2 = "#eee8d5";
    base3 = "#fdf6e3";
    red = "#dc322f";
    orange = "#cb4b16";
    yellow = "#b58900";
    green = "#859900";
    cyan = "#2aa198";
    blue = "#268bd2";
    violet = "#6c71c4";
    magenta = "#d33682";
  };
  
  colors = if hasColors then convertedColors else fallbackColors;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      starship =
        let
          text = "fg:${colors.base03}";
        in
        {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableTransience = true;

          settings = lib.mkIf cfg.qnixFormat {
            add_newline = false;
            format = lib.concatStrings [
              "$username"
              "[](${colors.violet})"

              "[](${colors.cyan})"
              "$hostname"
              "[](${colors.cyan})"

              "[](${colors.blue})"
              "$directory"
              "[](${colors.blue})"

              "[](${colors.green})"
              "$git_branch"
              "$git_state"
              "$git_status"
              "$nix_shell"
              "[](${colors.green}) "
            ];

            # modules
            character = {
              error_symbol = "[ ](bold red)";
              success_symbol = "[](purple)";
              vimcmd_symbol = "[](green)";
            };
            username = {
              style_root = "bg:${colors.violet} fg:bold ${colors.base03}";
              style_user = "bg:${colors.violet} fg:bold ${colors.base03}";
              format = lib.concatStrings [
                "[ $user ]($style)"
              ];
              show_always = true;
            };
            hostname = {
              style = "bg:${colors.cyan} ${text}";
              ssh_symbol = "󰣀 ";
              ssh_only = false;
              format = "[ $ssh_symbol$hostname ]($style)";
            };
            directory = {
              format = "[ $path ]($style)";
              truncation_length = 1;
              style = "bg:${colors.blue} ${text}";
            };
            git_branch = {
              symbol = "";
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
              format = "[ $symbol ]($style)";
              symbol = "";
              style = "bg:${colors.green} fg:bold ${colors.base03}";
            };
            fill = {
              symbol = " ";
            };
            line_break = {
              disabled = false;
            };
            time = {
              format = "[ $time ]($style)";
              disabled = false;
              time_format = " %H:%M";
              style = "bg:${colors.violet} ${text}";
            };
          };
        };

      fish = {
        # fix starship prompt to only have newlines after the first command
        # https://github.com/starship/starship/issues/560#issuecomment-1465630645
        shellInit = # fish
          ''
            function prompt_newline --on-event fish_postexec
              echo ""
            end
          '';
        interactiveShellInit =
          # fish
          lib.mkAfter ''
            function starship_transient_prompt_func
              starship module character
            end
          '';
      };
    };
  };
}
