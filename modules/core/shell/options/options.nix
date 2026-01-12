{ lib, ... }:

{
  options.qnix.core.shell = {
    enable = lib.mkEnableOption "shell managerment" // {
      default = true;
      description = "Whether to enable shell managerment";
    };

    fish = {
      enable = lib.mkEnableOption "fish" // {
        default = true;
        description = "Whether to enable fish";
      };
    };

    defaultShell = lib.mkEnableOption "default shell" // {
      default = true;
      description = "Whether to enable default shell";
    };

    aliases = lib.mkEnableOption "aliases" // {
      default = true;
      description = "Whether to enable aliases";
    };

    qnix-aliases = lib.mkEnableOption "aliases for qnix-system" // {
      default = true;
      description = "Whether to enable aliases for qnix-system";
    };

    packages = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.attrs
          lib.types.package
        ]
      );
      apply = lib.qnix-lib.mkShellPackages;
      default = { };
      description = ''
        Attrset of shell packages to install and add to pkgs.custom overlay (for compatibility across multiple shells).
        Both string and attr values will be passed as arguments to writeShellApplicationCompletions
      '';
      example = ''
        shell.packages = {
          myPackage1 = "echo 'Hello, World!'";
          myPackage2 = {
            runtimeInputs = [ pkgs.hello ];
            text = "hello --greeting 'Hi'";
          };
        };
      '';
    };
  };
}
