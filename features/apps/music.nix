{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/tidal-hifi" ];
  persistence.users."*".cache.directories = [
    ".config/tidal-hifi/Cache"
    ".config/tidal-hifi/Code Cache"
    ".config/tidal-hifi/Crashpad"
    ".config/tidal-hifi/DawnGraphiteCache"
    ".config/tidal-hifi/DawnWebGPUCache"
    ".config/tidal-hifi/GPUCache"
    ".config/tidal-hifi/component_crx_cache"
  ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.tidal-hifi;
        description = "Music player package to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
