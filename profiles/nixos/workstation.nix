{ lib, config, ... }:
{
  config = {
    qnix.system.headless = lib.mkDefault false;
  };
}
