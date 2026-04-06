{
  lib,
  profiles ? [ ],
  ...
}:

let
  profileModules = builtins.map (name: ../profiles/${name}.nix) profiles;
in
{
  imports = [
    ../modules/shared/qnix-options.nix
  ]
  ++ profileModules;
}
