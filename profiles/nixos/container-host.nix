{ lib, ... }:
{
  imports = [ ./server.nix ] ++ lib.concatLists [
    (lib.qnix.mkNixosFeatureImports {
      category = "runtime";
      name = "docker";
    })
  ];

  config.qnix = {
    runtime.docker.enable = lib.mkDefault true;
  };
}
