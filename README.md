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

External modules belong in the client’s module composition, not in this flake’s
feature definitions.

## Pentesting host and VM split

Pentesting is split into two QNix profiles:

- `pentest` contains shared configuration, such as Wireshark, and can be used
  by both the host and Kali’s standalone Home Manager setup.
- `pentest-host` contains host-only hardware features such as GPU cracking,
  hash testing, and USB/device access.

The Kali VM is not represented by a separate QNix profile. Kali provides the
operating system and pentesting tool suite; QNix configures the shared user
environment through standalone Home Manager. The inventory and VM setup should
document which Kali metapackage is selected.

## Checks

The nested checks flake evaluates the published factory against this repository:

```bash
nix flake check ./checks
```
