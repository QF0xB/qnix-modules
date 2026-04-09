{ lib }:
{
  dev = {
    git = {
      enable = lib.mkDefault true;
      lfs = lib.mkDefault true;
      signing = lib.mkDefault true;
      signingKey = lib.mkDefault "90360B7DB6B78B75E9013D113FF8C23C46F2CC90";
      userName = lib.mkDefault "Quirin Brändli";
      userEmail = lib.mkDefault "qbraendli@pm.me";
    };
  };

  system = {
    packages.nerdFonts.enable = lib.mkOverride 900 true;

    starship.enable = lib.mkOverride 900 true;

    shell = {
      showIcons = lib.mkDefault true;
    };

    starship.showIcons = lib.mkDefault true;
  };

  security.gpg.enable = lib.mkDefault true;
}
