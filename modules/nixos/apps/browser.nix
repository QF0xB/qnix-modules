{ lib, config, ... }:
let
  cfg = config.qnix.apps.browser;
  isBrave = lib.hasInfix "brave" (lib.getName cfg.package);
in
{
  config = lib.mkIf cfg.enable {
    programs.chromium = lib.mkIf isBrave {
      enable = true;
      extraOpts = {
        BraveWalletDisabled = true;
        BraveRewardsDisabled = true;
        BraveVPNDisabled = true;
        BraveAIChatEnabled = false;
        RestoreOnStartup = 6;
        PromptForDownloadLocation = false;
      };
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
        "dneaehbmnbhcippjikoajpoabadpodje" # Old Reddit Redirect
        "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
        "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
    };

    qnix.persist.users."*" = {
      directories = lib.optionals isBrave [
        ".config/BraveSoftware"
      ];
      cache.directories = lib.optionals isBrave [
        ".cache/BraveSoftware"
      ];
    };
  };
}
