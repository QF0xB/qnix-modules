{
  standaloneHome = true;

  persistence.users."*".directories = [
    ".local/share/fish"
  ];

  options =
    { lib, ... }:
    {
      aliases = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether Fish aliases are enabled.";
      };
    };

  # Persistence contributions require a NixOS-side implementation so the SDK
  # can attach them to the shared qnix.persist contract. This feature does not
  # enable Fish system-wide here; system.users or the host owns that decision.
  nixos =
    { ... }:
    {
      programs.fish.enable = true;
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.fzf ];

      programs.lsd.enable = true;

      programs.fish = {
        enable = true;
        preferAbbrs = false;

        shellInit = ''
          set fish_greeting
        '';

        shellAliases = lib.mkIf cfg.aliases {
          c = "clear";
          ls = "clear && lsd -l";
          lss = "lsd -la";
          lsa = "clear && lsd -la";
          mime = "xdg-mime query filetype";
          mkdir = "mkdir -p";
          mount = "mount --mkdir";
          open = "xdg-open";

          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";
        };

        plugins = with pkgs.fishPlugins; [
          {
            name = "fzf";
            src = fzf.src;
          }
          {
            name = "autopair";
            src = autopair.src;
          }
          {
            name = "done";
            src = done.src;
          }
          {
            name = "sudope";
            src = plugin-sudope.src;
          }
        ];
      };
    };
}
