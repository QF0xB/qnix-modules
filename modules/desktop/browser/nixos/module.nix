{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.qnix.desktop.browser;
  anyEnabled = cfg.firefox.enable || cfg.brave.enable;
in
{
  config = lib.mkIf anyEnabled {
    # Default browser: brave if enabled, else firefox if enabled
    qnix.apps.browser = lib.mkDefault (
      if cfg.brave.enable then
        pkgs.brave
      else if cfg.firefox.enable then
        pkgs.firefox
      else
        config.qnix.apps.browser
    );

    programs.chromium = lib.mkIf cfg.brave.enable {
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

    qnix.persist.home.directories = lib.mkIf cfg.brave.enable [
      ".cache/BraveSoftware"
      ".config/BraveSoftware"
    ];
  };
}
