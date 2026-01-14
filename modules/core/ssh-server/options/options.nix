{ lib, ... }:

{
  options.qnix.core.ssh-server = {
    enable = lib.mkEnableOption "ssh-server" // {
      default = false;
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 22;
      description = "Port to listen on for SSH connections";
    };

    allowRootLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow root login";
    };

    allowPasswordAuthentication = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow password authentication";
    };

    sshAgent = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to start the ssh agent";
    };
  };
}
