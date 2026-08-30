{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  options =
    { lib, ... }:
    {
      packages = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.str
            lib.types.attrs
            lib.types.package
          ]
        );
        default = { };
        description = "Helper shell packages installed through Home Manager.";
      };
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    let
      mkShellPackage =
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
          throw "qnix.shell.packages.packages.${name} must be a package, string, or attrset for writeShellApplication.";
    in
    {
      home.packages = lib.attrValues (lib.mapAttrs mkShellPackage cfg.packages);
    };
}
