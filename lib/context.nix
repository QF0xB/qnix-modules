{ lib }:
{
  # Return the canonical qnix config for Home Manager modules.
  #
  # Usage:
  # - in NixOS + HM setups, the source of truth is `osConfig.qnix`
  # - in standalone HM setups, fall back to `config.qnix`
  getQnixConfig =
    {
      config,
      osConfig ? null,
    }:
    if osConfig != null && osConfig ? qnix then osConfig.qnix else config.qnix;
}
