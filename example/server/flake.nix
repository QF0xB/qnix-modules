{
  description = "Example QNix Server Configuration";

  inputs = {
    # Use stable nixpkgs for servers
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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

    # Server dependencies
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
        # Pass categories for server (core + server services)
        categories = ["core", "server"];
        
        # Pass only selected inputs that modules need
        # Modules access these via: inputs.something
        inputs = {
          # Add inputs here if server modules need them
          # Example: nextcloud = inputs.nextcloud;
        };
      };
    };
  in
  {
    nixosConfigurations = nixosConfs;
  };
}

