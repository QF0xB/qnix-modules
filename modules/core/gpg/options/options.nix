{ lib, pkgs, ... }:

{
  options.qnix.core.gpg = {
    enable = lib.mkEnableOption "GPG with SSH agent support" // {
      default = false;
    };

    enableSSH = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GPG as SSH agent";
    };

    pinentryPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pinentry-tty;
      description = "Pinentry package to use for password entry";
    };

    publicKeys = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
      default = [ ];
      description = "List of public GPG keys to import. Can be key data (strings) or file paths.";
      example = [
        "-----BEGIN PGP PUBLIC KEY BLOCK-----\n..."
        "/path/to/public-key.asc"
      ];
    };
  };
}
