{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.qnix.core.nix-helpers;
in
{
  config = {
    environment.systemPackages =
      (lib.optionals cfg.nixfmt.enable [ pkgs.nixfmt ])
      ++ (lib.optionals cfg.direnv.enable [ pkgs.direnv ]);

    programs = {
      nh = lib.mkIf (cfg.nh.enable) {
        enable = true;
        clean = {
          enable = cfg.nh.clean.enable;
          dates = cfg.nh.clean.dates;
        };
      };
    };
  };
}
