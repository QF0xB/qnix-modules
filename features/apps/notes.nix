{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/obsidian" ];
  persistence.users."*".cache.directories = [
    ".config/obsidian/Cache"
    ".config/obsidian/Code Cache"
    ".config/obsidian/GPUCache"
    ".config/obsidian/DawnGraphiteCache"
    ".config/obsidian/DawnWebGPUCache"
  ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.obsidian;
        description = "Notes application package to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
