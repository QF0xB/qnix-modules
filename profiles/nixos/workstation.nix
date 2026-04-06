{ lib, config, ... }:
{
  config = {
    qnix.system.headless = lib.mkDefault false;
    qnix.status.server = lib.mkDefault false;
  };
}
