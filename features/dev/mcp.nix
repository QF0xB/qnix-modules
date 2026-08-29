{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.xdg-folders" ];

  home =
    {
      config,
      context,
      lib,
      pkgs,
      osConfig ? null,
      ...
    }:
    let
      mcpPkgs = pkgs.extend context."mcp-servers-nix".overlays.default;
      evaluated = context."mcp-servers-nix".lib.evalModule mcpPkgs {
        flavor = "claude";

        programs = {
          filesystem = {
            enable = true;
            args = [ config.xdg.userDirs.projects ];
          };
          git.enable = true;
          github.enable = true;
        }
        // lib.optionalAttrs (osConfig != null) {
          nixos.enable = true;
        };
      };
    in
    {
      programs.mcp.servers = evaluated.config.settings.servers or { };

      programs.mcp.enable = true;
    };
}
