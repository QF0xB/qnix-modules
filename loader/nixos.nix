{
  lib,
  profiles ? [ ],
  ...
}:

let
  profileModules = builtins.map (name: ../profiles/nixos/${name}.nix) profiles;
in
{
  imports = [
    ../shared/qnix-options.nix
  ]
  ++ profileModules;
}
