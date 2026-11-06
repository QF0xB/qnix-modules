{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/Novalist" ];
  # Re-downloadable AI runtimes and models. The Speech extension folder itself
  # stays persistent because it also holds the Hugging Face token.
  persistence.users."*".cache.directories = [
    ".config/Novalist/Models"
    ".config/Novalist/extensions/com.novalist.speech/models"
    ".config/Novalist/extensions/com.novalist.speech/python"
    ".config/Novalist/extensions/com.novalist.speech/venv"
    ".config/Novalist/extensions/com.novalist.speech/venv-rocm"
  ];

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.callPackage ../../packages/novalist/package.nix { };
        defaultText = lib.literalExpression "pkgs.callPackage ../../packages/novalist/package.nix { }";
        description = "Novalist novel writing application package to install.";
      };
    };

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
