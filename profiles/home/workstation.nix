{
  lib,
  config,
  osConfig ? null,
  qnixLib,
  ...
}:

{
  imports = lib.concatLists [
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "security";
      name = "gpg";
    })
  ];

  config = {
    qnix = {
      security.gpg = {
        enable = lib.mkDefault true;
      };
    };
  };
}
