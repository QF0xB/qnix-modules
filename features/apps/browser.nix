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

  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/BraveSoftware" ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.brave-origin ];
    };
}
