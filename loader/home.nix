{
  lib,
  profiles ? [ ],
  ...
}:

let
  profileModules = builtins.map (name: ../profiles/home/${name}.nix) profiles;
in
{
  imports = [
    ../modules/shared/qnix-options.nix
  ]
  ++ profileModules;
}
