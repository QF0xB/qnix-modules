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
    ../shared/qnix-options.nix
  ]
  ++ profileModules;
}
