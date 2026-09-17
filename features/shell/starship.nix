{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "shell.fish" ];

  options =
    { lib, ... }:
    {
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {
          add_newline = false;
          format = "$directory$git_branch$git_status$character";

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
          };

          directory = {
            truncation_length = 3;
            truncate_to_repo = true;
          };

          git_branch = {
            format = " [$branch]($style)";
            style = "bold purple";
          };

          git_status = {
            format = " [$all_status$ahead_behind]($style)";
            style = "bold yellow";
          };
        };
        description = "Starship prompt settings.";
      };
    };

  home =
    {
      cfg,
      ...
    }:
    {
      programs.starship = {
        enable = true;
        settings = cfg.settings;
      };
    };
}
