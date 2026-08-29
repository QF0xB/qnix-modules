{
  description = "QNix modules checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qnix-modules.url = "path:..";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      ctx = import ./context.nix inputs;
    in
    {
      checks.${ctx.system} = import ./tests { inherit ctx; };
    };
}
