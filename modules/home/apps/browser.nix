{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg = qconfig.apps.browser or { enable = false; };
  isBrave = lib.hasInfix "brave" (lib.getName cfg.package);
in
{
  config = lib.mkIf cfg.enable {
    programs.chromium = lib.mkIf isBrave {
      enable = true;
      package = cfg.package;
      commandLineArgs = [
        "--disable-features=AIChat,BraveVPN,Ipfs,BraveNativeWallet,BraveRewards"
      ];
    };

    home.packages = lib.optionals (!isBrave) [ cfg.package ];

    home.sessionVariables = lib.mkIf isBrave {
      DEFAULT_BROWSER = lib.getExe cfg.package;
      BROWSER = lib.getExe cfg.package;
    };

    xdg.mimeApps.defaultApplications = lib.mkIf isBrave {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };
}
