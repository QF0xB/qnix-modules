{ lib, ... }:

{
  options.qnix.desktop.jetbrains = {
    enable = lib.mkEnableOption "jetbrains" // {
      default = false;
    };

    clion = {
      enable = lib.mkEnableOption "CLion" // {
        default = false;
      };
    };

    datagrip = {
      enable = lib.mkEnableOption "DataGrip" // {
        default = false;
      };
    };

    dataspell = {
      enable = lib.mkEnableOption "DataSpell" // {
        default = false;
      };
    };

    idea = {
      enable = lib.mkEnableOption "IntelliJ IDEA" // {
        default = false;
      };
    };

    phpstorm = {
      enable = lib.mkEnableOption "PHPStorm" // {
        default = false;
      };
    };

    pycharm = {
      enable = lib.mkEnableOption "PyCharm" // {
        default = false;
      };
    };

    rider = {
      enable = lib.mkEnableOption "Rider" // {
        default = false;
      };
    };

    ruby-mine = {
      enable = lib.mkEnableOption "RubyMine" // {
        default = false;
      };
    };

    rust-rover = {
      enable = lib.mkEnableOption "Rust Rover" // {
        default = false;
      };
    };

    webstorm = {
      enable = lib.mkEnableOption "WebStorm" // {
        default = false;
      };
    };
  };
}
