{ lib }:
{
  desktop.hyprland.enable = lib.mkDefault true;
  desktop.noctalia.enable = lib.mkDefault true;

  # PRs that touch flake.lock (e.g. Garnix / lockfile cache updates) on the client flake repo
  desktop.clientPrNotify = {
    enable = lib.mkDefault true;
    owner = lib.mkDefault "QF0xB";
    repo = lib.mkDefault "qnix-client";
    sopsSecretName = lib.mkDefault "github_token";
    titleContains = lib.mkDefault "flake lock update";
  };
}
