{ lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.qnix.desktop.dev-utilities;
  enabled = cfg.enable || cfg.postman.enable;
  # Force Wayland: desktop/Exec often doesn't inherit sessionVariables
  postman-wayland = pkgs.symlinkJoin {
    name = "postman-wayland";
    paths = [ pkgs.postman ];
    postBuild = ''
      rm -f $out/bin/postman
      makeWrapper ${pkgs.postman}/bin/postman $out/bin/postman \
        --set NIXOS_OZONE_WL 1 \
        --set ELECTRON_OZONE_PLATFORM_HINT auto \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland"
    '';
    buildInputs = [ pkgs.makeWrapper ];
  };
in
{
  config = lib.mkIf enabled {
    home.packages = [ postman-wayland ];
  };
}

