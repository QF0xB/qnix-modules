{ lib }:
{
  status = {
    server = lib.mkDefault false;
  };

  system = {
    starship.enable = lib.mkOverride 900 true;

    shell = {
      showIcons = lib.mkDefault true;
    };

    starship.showIcons = lib.mkDefault true;
  };

  security.gpg = {
    enable = lib.mkDefault true;
    publicKeys = lib.mkDefault [
      {
        url = "https://keys.openpgp.org/vks/v1/by-fingerprint/90360B7DB6B78B75E9013D113FF8C23C46F2CC90";
        sha256 = "sha256-q03XOg1DYUMjF/8r3vJ8OHTcNPJdsNnXNf/ODWiL3vg=";
        trust = "ultimate";
      }
    ];
  };

  dev.git = {
    enable = lib.mkDefault true;
  };
}
