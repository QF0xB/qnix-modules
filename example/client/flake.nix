{
  description = "Example QNix Client Configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Example: Editor
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Example: Desktop environment
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qnix-ags = {
      url = "github:your-org/qnix-ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # QNix modules
    qnix-modules = {
      # Recommended: Use FlakeHub (with version tag)
      url = "flakehub:your-org/qnix-modules/v2025.01.15";
      # Or use github directly: "github:your-org/qnix-modules"
      # Or use a local path during development:
      # url = "path:../qnix-modules"
    };

    # Other dependencies
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Extend nixpkgs.lib with qnix-modules utilities
    lib = inputs.qnix-modules.lib {
      lib = nixpkgs.lib;
      pkgs = pkgs;
    };

    nixosConfs = import ./nixos-hosts.nix {
      inherit inputs pkgs lib;
      specialArgs = {
        # Pass categories for client (core + desktop)
        categories = ["core", "desktop"];
        
        # Pass only selected inputs that modules need
        # Modules access these via: inputs.nvf, inputs.ags, etc.
        inputs = {
          nvf = inputs.nvf;
          ags = inputs.ags;
          qnix-ags = inputs.qnix-ags;
        };
      };
    };
  in
  {
    nixosConfigurations = nixosConfs;
  };
}

