# ags and noctalia are optional: add qnixAgsIntegration / qnixNoctaliaIntegration when using those flakes
{ ... }:
{
  imports = [
    ./hyprsuite/module.nix
  ];
}
