{ lib, ... }:
{
  options.qnix.status = {
    headless = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    server = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    vm = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
