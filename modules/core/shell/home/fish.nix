{
  lib,
  osConfig,
  config,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.core.shell.fish;
in
{
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      preferAbbrs = true;
      shellAbbrs = lib.mkForce config.home.shellAliases;
      shellInit = ''
        # shut up welcoming
        set fish_greeting
      '';

      plugins = with pkgs.fishPlugins; [
        {
          name = "sponge";
          src = sponge.src;
        }
        {
          name = "forgit";
          src = forgit.src;
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
      ];
    };
  };

  #  osConfig.qnix.persist.home.cache.directories = lib.mkIf cfg.enable [
  #   ".local/share/fish"
  # ];
}
