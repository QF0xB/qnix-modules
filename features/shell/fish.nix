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
      config,
      lib,
      pkgs,
      ...
    }:
    let
      qnixRoot = "${config.home.homeDirectory}/Projects/qnix";
    in
    {
      home.packages = [
        pkgs.fzf
        pkgs.lsd
      ];

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

          # Git workflow shortcuts retained from the pre-SDK configuration.
          ga = "git add .";
          gc = "git commit";
          gp = "git push";
          gacp = "git add . && git commit && git push";

          # QNix maintenance shortcuts. Point these at the client flake so they
          # work regardless of the current directory.
          nuq = "nix flake update qnix-modules --flake ${qnixRoot}/client";
          nhs = "nh os switch ${qnixRoot}/client";
          nbv = "nix build ${qnixRoot}/client#nixosConfigurations.QTestVM.config.system.build.vm";
          qnix = "cd ${qnixRoot}";

          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";

          dots = "cd ${qnixRoot}";
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
