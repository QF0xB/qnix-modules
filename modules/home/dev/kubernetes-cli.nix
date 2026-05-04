{
  lib,
  config,
  pkgs,
  osConfig ? null,
  qnixLib,
  ...
}:
let
  qconfig = qnixLib.qnix.getQnixConfig {
    inherit config osConfig;
  };
  cfg =
    if lib.hasAttrByPath [ "dev" "kubernetesCli" ] qconfig then
      qconfig.dev.kubernetesCli
    else
      { enable = false; };

  # k9s often runs kubeconfig exec plugins and kubectl with a minimal PATH; missing
  # helpers surface as bogus "v1/pods command not found" (see derailed/k9s#3730).
  k9sPackage = pkgs.symlinkJoin {
    name = "k9s-with-qnix-kubernetes-cli-path";
    paths = [ cfg.k9sPackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/k9s --prefix PATH : ${
        lib.makeBinPath (
          [
            cfg.kubectlPackage
            cfg.helmPackage
            cfg.kustomizePackage
            cfg.fluxPackage
            cfg.kubeCtxPackage
          ]
          ++ cfg.k9sExtraPathPackages
        )
      }
    '';
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.k9s = {
      enable = true;
      package = k9sPackage;
    };

    home.packages = [
      cfg.kubectlPackage
      cfg.helmPackage
      cfg.kustomizePackage
      cfg.fluxPackage
      cfg.kubeCtxPackage
    ]
    ++ cfg.k9sExtraPathPackages;
      cfg.freelensPackage
    ];
  };
}
