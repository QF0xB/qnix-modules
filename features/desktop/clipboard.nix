{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  requires.home = [ "desktop.wayland" ];

  options =
    { lib, ... }:
    {
      allowImages = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether ClipHist stores copied images in addition to text.";
      };
    };

  home =
    {
      cfg,
      ...
    }:
    {
      services.cliphist = {
        enable = cfg.enable;
        inherit (cfg) allowImages;
      };
    };
}
