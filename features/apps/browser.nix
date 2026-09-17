{
  nixos =
    { lib, ... }:
    let
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "mjcnijlhddpbdemagnpefmlkjdagkogk" # SponsorBlock
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
        "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
      ];
    in
    {
      environment.etc."brave/policies/managed/extensions.json".text = builtins.toJSON {
        ExtensionSettings = lib.genAttrs extensions (_: {
          installation_mode = "normal_installed";
          update_url = "https://clients2.google.com/service/update2/crx";
        });
      };
    };

  options =
    { lib, pkgs, ... }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.brave-origin;
        description = "Browser package to install.";
      };
    };

  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/BraveSoftware" ];

  home =
    { cfg, ... }:
    {
      home.packages = [ cfg.package ];
    };
}
