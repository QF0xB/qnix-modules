# config.sops is set by sops-integration.nix (add inputs.qnix-modules.nixosModules.qnixSopsIntegration after sops-nix).
# Core only loads qnix.core.sops options via options/options.nix.
{ ... }:
{
  config = { };
}
