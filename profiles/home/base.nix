{
  lib,
  config,
  qnixLib,
  ...
}:
{
  imports = lib.concatLists [
    (qnixLib.qnix.mkHomeFeatureImports {
      category = "system";
      name = "shell";
    })
  ];

  config = {
    qnix.system.shell.enable = lib.mkDefault true;
  };
}
