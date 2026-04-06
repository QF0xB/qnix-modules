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

  # Return a config fragment only for standalone Home Manager mode.
  # In NixOS + Home Manager setups, the canonical qnix config must come from
  # osConfig, so HM profiles should not define qnix.* again.
  mkStandaloneHomeConfig =
    {
      osConfig ? null,
      value,
    }:
    if osConfig != null && osConfig ? qnix then { } else value;
}
