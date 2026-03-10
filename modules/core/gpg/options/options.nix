{ lib, pkgs, ... }:

let
  trustLevel = lib.types.enum [
    "unknown"
    "never"
    "marginal"
    "full"
    "ultimate"
    1
    2
    3
    4
    5
  ];

  # A single public key: file path, literal key string, or attrset (url+sha256, or source/text, with optional trust)
  publicKeyType = lib.types.oneOf [
    lib.types.path
    lib.types.str
    (lib.types.submodule {
      options = {
        url = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "URL to fetch the key from (e.g. keys.openpgp.org vks URL). Use together with sha256.";
        };
        sha256 = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Hash of the key file. Run: nix-prefetch-url ''<url>''";
        };
        source = lib.mkOption {
          type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path);
          default = null;
          description = "Path to a key file (use this or url+sha256 or text).";
        };
        text = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Literal key block (use this or url+sha256 or source).";
        };
        trust = lib.mkOption {
          type = lib.types.nullOr trustLevel;
          default = null;
          description = "Trust level: unknown, never, marginal, full, ultimate (or 1–5).";
        };
      };
    })
  ];
in
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
      type = lib.types.nullOr lib.types.package;
      default = null;
      defaultText = lib.literalExpression "pkgs.pinentry-tty";
      description = "Pinentry package to use for password entry";
    };

    publicKeys = lib.mkOption {
      type = lib.types.listOf publicKeyType;
      default = [ ];
      description = "List of public GPG keys to import: URLs (with sha256), literal key data (strings), file paths, or attrsets with optional trust.";
      example = [
        {
          url = "https://keys.openpgp.org/vks/v1/by-fingerprint/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
          sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
          trust = "ultimate";
        }
        {
          source = ./pubkey.asc;
          trust = "full";
        }
        "-----BEGIN PGP PUBLIC KEY BLOCK-----\n..."
      ];
    };
  };
}
