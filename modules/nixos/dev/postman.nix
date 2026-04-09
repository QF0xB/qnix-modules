{ lib, config, ... }:
let
  cfg = config.qnix.dev.postman;
in
{
  config = lib.mkIf cfg.enable {
    qnix.persist.users."*".directories = [
      ".config/Postman"
    ];
  };
}
