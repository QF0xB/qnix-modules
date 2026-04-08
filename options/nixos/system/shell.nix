{ lib, config, pkgs, ... }:
let
  mkShellPackages =
    packages:
    let
      renderPackage =
        name: value:
        if lib.isDerivation value then
          value
        else if lib.isString value then
          pkgs.writeShellApplication {
            inherit name;
            text = value;
          }
        else if builtins.isAttrs value then
          pkgs.writeShellApplication ({ inherit name; } // value)
        else
          throw "qnix.system.shell.packages.${name} must be a package, string, or attrset for writeShellApplication.";
    in
    lib.mapAttrs renderPackage packages;
in
{
  options.qnix.system.shell = {
    enable = lib.mkEnableOption "shell management";

    aliases = lib.mkEnableOption "shell aliases" // {
      default = true;
    };

    qnixAliases = lib.mkEnableOption "QNix-specific aliases" // {
      default = true;
    };

    projectRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional QNix project root used for shell aliases like `dots` and `nhs`.";
    };

    defaultShell = {
      enable = lib.mkEnableOption "default login shell management" // {
        default = true;
      };

      package = lib.mkOption {
        type = lib.types.enum [
          "fish"
          "zsh"
          "bash"
        ];
        default = "zsh";
        description = ''
          Login shell to set through `users.defaultUserShell`.
          `zsh` is the default; `fish` remains opt-in only.
        '';
      };
    };

    fish = {
      enable = lib.mkEnableOption "fish" // {
        default = false;
      };
    };

    zsh = {
      enable = lib.mkEnableOption "zsh" // {
        default = true;
      };

      autosuggestions = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      syntaxHighlighting = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      enableCompletion = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };

    direnv = {
      enable = lib.mkEnableOption "direnv shell hooks" // {
        default = false;
      };
    };

    packages = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.attrs
          lib.types.package
        ]
      );
      apply = mkShellPackages;
      default = { };
      description = ''
        Attrset of helper shell packages to install.
        Strings and attrsets are passed to `writeShellApplication`.
      '';
    };
  };
}
