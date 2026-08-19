{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    qnix-modules.url = "path:..";
  };

  outputs =
    { nixpkgs, qnix-modules, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qnix = qnix-modules.lib.mkQNix {
        context = {
          hostname = "check";
        };
      };
    in
    {
      checks.${system}.factory =
        assert qnix.featureNames == [ ];
        assert qnix.profileNames == [ ];
        pkgs.runCommand "qnix-modules-factory" { } "touch $out";
    };
}
