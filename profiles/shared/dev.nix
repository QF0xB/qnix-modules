{ lib }:
{
  dev = {
    codex.enable = lib.mkDefault true;

    cursor = {
      enable = lib.mkDefault true;
      agentPanelSize = lib.mkDefault 100;
    };

    direnv.enable = lib.mkDefault true;
    postman.enable = lib.mkDefault true;

    kubernetesCli.enable = lib.mkDefault true;

    git = {
      lfs = lib.mkDefault true;
      signing = lib.mkDefault true;
      signingKey = lib.mkDefault "90360B7DB6B78B75E9013D113FF8C23C46F2CC90";
      userName = lib.mkDefault "Quirin Brändli";
      userEmail = lib.mkDefault "qbraendli@pm.me";
    };

    jetbrains = {
      enable = lib.mkDefault true;
      idea.enable = lib.mkDefault true;
    };
  };
}
