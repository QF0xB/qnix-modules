{ lib }:
{
  dev = {
    direnv.enable = lib.mkDefault true;

    git = {
      enable = lib.mkDefault true;
      lfs = lib.mkDefault true;
      signing = lib.mkDefault true;
      signingKey = lib.mkDefault "90360B7DB6B78B75E9013D113FF8C23C46F2CC90";
      userName = lib.mkDefault "Quirin Brändli";
      userEmail = lib.mkDefault "qbraendli@pm.me";
    };
  };
}
