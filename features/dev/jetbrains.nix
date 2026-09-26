{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [
    ".config/JetBrains"
    ".java/.userPrefs"
  ];
  persistence.users."*".cache.directories = [ ".local/share/JetBrains" ];

  options =
    { lib, ... }:
    {
      ideaPro = lib.mkEnableOption "IntelliJ IDEA" // {
        default = true;
      };
      clion = lib.mkEnableOption "CLion";
      rider = lib.mkEnableOption "Rider";
      webstorm = lib.mkEnableOption "WebStorm";
      goland = lib.mkEnableOption "GoLand";
      pycharm = lib.mkEnableOption "PyCharm";
      phpstorm = lib.mkEnableOption "PhpStorm";
      datagrip = lib.mkEnableOption "DataGrip";
      dataspell = lib.mkEnableOption "DataSpell";
      rubymine = lib.mkEnableOption "RubyMine";
      rustrover = lib.mkEnableOption "RustRover";
    };

  home =
    {
      cfg,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages =
        lib.optionals cfg.ideaPro [ pkgs.jetbrains.idea ]
        ++ lib.optionals cfg.clion [ pkgs.jetbrains.clion ]
        ++ lib.optionals cfg.rider [ pkgs.jetbrains.rider ]
        ++ lib.optionals cfg.webstorm [ pkgs.jetbrains.webstorm ]
        ++ lib.optionals cfg.goland [ pkgs.jetbrains.goland ]
        ++ lib.optionals cfg.pycharm [ pkgs.jetbrains.pycharm ]
        ++ lib.optionals cfg.phpstorm [ pkgs.jetbrains.phpstorm ]
        ++ lib.optionals cfg.datagrip [ pkgs.jetbrains.datagrip ]
        ++ lib.optionals cfg.dataspell [ pkgs.jetbrains.dataspell ]
        ++ lib.optionals cfg.rubymine [ pkgs.jetbrains.ruby-mine ]
        ++ lib.optionals cfg.rustrover [ pkgs.jetbrains.rust-rover ];
    };
}
