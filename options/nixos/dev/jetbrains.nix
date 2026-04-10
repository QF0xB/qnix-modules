{ lib, ... }:

{
  options.qnix.dev.jetbrains = {
    enable = lib.mkEnableOption "JetBrains IDEs";

    clion.enable = lib.mkEnableOption "CLion";
    datagrip.enable = lib.mkEnableOption "DataGrip";
    dataspell.enable = lib.mkEnableOption "DataSpell";
    idea.enable = lib.mkEnableOption "IntelliJ IDEA";
    phpstorm.enable = lib.mkEnableOption "PHPStorm";
    pycharm.enable = lib.mkEnableOption "PyCharm";
    rider.enable = lib.mkEnableOption "Rider";
    ruby-mine.enable = lib.mkEnableOption "RubyMine";
    rust-rover.enable = lib.mkEnableOption "RustRover";
    webstorm.enable = lib.mkEnableOption "WebStorm";
  };
}
