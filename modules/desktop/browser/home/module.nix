{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = osConfig.qnix.desktop.browser;
  anyEnabled = cfg.firefox.enable || cfg.brave.enable;
  inherit (lib) getExe;
in
{
  config = lib.mkIf anyEnabled {
    programs.firefox = lib.mkIf cfg.firefox.enable {
      enable = true;
      package = pkgs.firefox;
    };

    programs.chromium = lib.mkIf cfg.brave.enable {
      enable = true;
      package = pkgs.brave;

      commandLineArgs = [
        "--disable-features=AIChat,BraveVPN,Ipfs,BraveNativeWallet,BraveRewards"
      ];

    };

    home.sessionVariables = lib.mkIf cfg.brave.enable {
      DEFAULT_BROWSER = getExe pkgs.brave;
      BROWSER = getExe pkgs.brave;
    };

    xdg.mimeApps.defaultApplications = lib.mkIf cfg.brave.enable {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };

  };
}
