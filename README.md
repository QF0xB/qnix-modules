# QNix Modules

This flake publishes reusable QNix feature and profile definitions.

## Rewrite status

This is a full rewrite of `qnix-modules`. The previous loader-, option-, and
profile-based implementation is retained only as a temporary local archive and
is not part of the new public API. New work belongs exclusively in the SDK
feature and profile model described here.

It exports `lib.mkQNix`, a factory that creates one SDK instance and one
repository for a client:

```nix
qnix = inputs.qnix-modules.lib.mkQNix {
  context = {
    laptop = true;
    hostname = "example";
  };
};
```

The client then renders its selected profiles with, for example:

```nix
qnix.modulesFor.nixos [ "laptop" ]
```

`features/` will contain reusable feature descriptors. `profiles/` will contain
profile descriptors that select those features. Neither directory contains
definitions yet.

The migration scope is tracked in [`docs/feature-inventory.md`](./docs/feature-inventory.md).
The configured file-manager workflow is described in
[`docs/yazi.md`](./docs/yazi.md).

External modules belong in the client’s module composition, not in this flake’s
feature definitions.

## Pentesting host and VM split

Pentesting-specific host work is represented by the `pentest-host` profile,
which contains hardware-dependent features such as GPU cracking, hash testing,
and USB/device access.

The Kali VM is not represented by a QNix profile. Kali provides its operating
system, desktop, and pentesting tool suite, including tools such as Wireshark.
If Home Manager is added to the VM later, it can select ordinary profiles such
as `hyprland`. The inventory and VM setup should document which Kali
metapackage is selected.

`pentest.vms` configures a libvirt host and exposes explicit
`qnix-kali-vm-create-<name>` commands for configured Kali installer ISOs. It
does not create guests during activation, so an installed foreign OS is never
overwritten. Each VM supports `isolated-nat`, physical `interface`, or
`air-gapped` networking. After installing Kali, install Nix and Home Manager
inside the guest; the guest can then use the QNix standalone Home modules.

## Checks

The nested checks flake evaluates the published factory against this repository:

```bash
nix flake check ./checks
```
