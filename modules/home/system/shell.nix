{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  pkgs,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.system.shell;
  gitEnabled =
    lib.hasAttrByPath [ "dev" "git" "enable" ] qconfig && qconfig.dev.git.enable;
  nhEnabled =
    lib.hasAttrByPath [ "dev" "nh" "enable" ] qconfig && qconfig.dev.nh.enable;
  fishRuntimePackages = [ pkgs.fzf ];

  shellAliases =
    {
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
    }
    // lib.optionalAttrs gitEnabled {
      ga = "git add .";
      gc = "git commit";
      gp = "git push";
      gacp = "git add . && git commit && git push";
    }
    // lib.optionalAttrs (cfg.projectRoot != null && nhEnabled) {
      dots = "cd ${cfg.projectRoot}";
      nhs = "nh os switch ${cfg.projectRoot}";
    }
    // lib.optionalAttrs cfg.qnixAliases {
      qnix = "cd ~/projects/qnix";
      nuq = "nix flake update qnix-modules";
      nbv = "nix build .#nixosConfigurations.QTestVM.config.system.build.vm";
    };

  fishPlugins = with pkgs.fishPlugins; [
    {
      name = "sponge";
      src = sponge.src;
    }
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
  ] ++ lib.optional gitEnabled {
    name = "forgit";
    src = forgit.src;
  };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = lib.attrValues cfg.packages ++ lib.optionals cfg.fish.enable fishRuntimePackages;

    home.shellAliases = lib.mkIf cfg.aliases shellAliases;

    programs.lsd = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      settings.icons.when = if cfg.showIcons then "auto" else "never";
    };

    programs.fish = lib.mkIf cfg.fish.enable {
      enable = true;
      preferAbbrs = false;
      shellAliases = lib.mkForce (if cfg.aliases then shellAliases else { });
      shellInit = ''
        set fish_greeting
      '';
      plugins = fishPlugins;
    };

    programs.zsh = lib.mkIf cfg.zsh.enable {
      enable = true;
      autosuggestion.enable = cfg.zsh.autosuggestions;
      syntaxHighlighting.enable = cfg.zsh.syntaxHighlighting;
      enableCompletion = cfg.zsh.enableCompletion;
      dotDir = "${config.xdg.configHome}/zsh";
    };
  };
}
