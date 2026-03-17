## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## apps\.browser



The default browser



*Type:*
package



*Default:*

```nix
<derivation brave-1.88.132>
```



## apps\.file-manager



The default file-manager



*Type:*
package



*Default:*

```nix
<derivation nemo-6.6.4>
```



## apps\.notes



Notetaking app



*Type:*
package



*Default:*

```nix
<derivation obsidian-1.12.4>
```



## apps\.terminal



The default terminal emulator



*Type:*
package



*Default:*

```nix
<derivation kitty-0.46.0>
```



## core\.boot\.efiSupport



Enable EFI support



*Type:*
boolean



*Default:*

```nix
true
```



## core\.boot\.encrypted



Whether to enable encrypted boot\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.boot\.encryptedDevice



Device to use for encrypted boot



*Type:*
string



*Default:*

```nix
"/dev/disk/by-label/NIXBOOT"
```



## core\.boot\.grub\.enable



Whether to enable grub bootloader\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/boot/options/grub-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/boot/options/grub-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/boot/options/grub-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/boot/options/grub-options.nix)



## core\.boot\.grub\.device



Device to use for GRUB



*Type:*
string



*Default:*

```nix
"nodev"
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/boot/options/grub-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/boot/options/grub-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/boot/options/grub-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/boot/options/grub-options.nix)



## core\.boot\.systemd-boot\.enable



Whether to enable systemd-boot bootloader\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/boot/options/systemd-boot-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/boot/options/systemd-boot-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/boot/options/systemd-boot-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/boot/options/systemd-boot-options.nix)



## core\.boot\.timeout



Timeout for Boot



*Type:*
signed integer



*Default:*

```nix
3
```



## core\.boot\.zfsSupport



Enable ZFS support



*Type:*
boolean



*Default:*

```nix
true
```



## core\.fail2ban\.enable



Whether to enable fail2ban\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.fail2ban\.banTime



Time to ban for



*Type:*
string



*Default:*

```nix
"1h"
```



## core\.fail2ban\.banTimeIncrement



Whether to enable fail2ban ban time increment\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.fingerprint\.enable



Whether to enable fingerprint authentication (fprintd)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.fingerprint\.login



Whether to enable fingerprint for login (PAM)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.fingerprint\.sudo



Whether to enable fingerprint for sudo (PAM)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.fingerprint\.tod\.enable



Whether to enable Touch OEM Driver (for some laptop readers)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.fingerprint\.tod\.driver



TOD driver package when tod\.enable is true (e\.g\. libfprint-2-tod1-goodix, libfprint-2-tod1-elan)\.



*Type:*
null or package



*Default:*

```nix
null
```



*Example:*

```nix
pkgs.libfprint-2-tod1-goodix
```



## core\.git\.enable



Whether to enable git\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.git\.lfs



Whether to enable git lfs



*Type:*
boolean



*Default:*

```nix
false
```



## core\.git\.signing



Whether to enable git signing



*Type:*
boolean



*Default:*

```nix
false
```



## core\.git\.signingKey



The key to use for git signing



*Type:*
string



*Default:*

```nix
""
```



## core\.git\.userEmail



The email to use for git commits



*Type:*
string



*Default:*

```nix
""
```



## core\.git\.userName



The name to use for git commits



*Type:*
string



*Default:*

```nix
""
```



## core\.gpg\.enable



Whether to enable GPG with SSH agent support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.gpg\.enableSSH



Enable GPG as SSH agent



*Type:*
boolean



*Default:*

```nix
true
```



## core\.gpg\.pinentryPackage



Pinentry package to use for password entry



*Type:*
null or package



*Default:*

```nix
pkgs.pinentry-tty
```



## core\.gpg\.publicKeys



List of public GPG keys to import: URLs (with sha256), literal key data (strings), file paths, or attrsets with optional trust\.



*Type:*
list of (absolute path or string or (submodule))



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
    trust = "ultimate";
    url = "https://keys.openpgp.org/vks/v1/by-fingerprint/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  }
  {
    source = /nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/gpg/options/pubkey.asc;
    source = /nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/gpg/options/pubkey.asc;
    trust = "full";
  }
  ''
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    ...''
]
```



## core\.impermanence\.enable



Whether to enable impermanence\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.localisation\.enable



Whether to enable localisation\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.localisation\.localeSettings



Locale environment variables (LANG, LC_\*)



*Type:*
attribute set of string



*Default:*

```nix
{
  LANG = "en_US.UTF-8";
  LC_ADDRESS = "de_DE.UTF-8";
  LC_COLLATE = "en_US.UTF-8";
  LC_CTYPE = "en_US.UTF-8";
  LC_IDENTIFICATION = "en_US.UTF-8";
  LC_MEASUREMENT = "de_DE.UTF-8";
  LC_MESSAGES = "en_US.UTF-8";
  LC_MONETARY = "de_DE.UTF-8";
  LC_NAME = "en_US.UTF-8";
  LC_NUMERIC = "de_DE.UTF-8";
  LC_PAPER = "en_US.UTF-8";
  LC_TELEPHONE = "en_US.UTF-8";
  LC_TIME = "de_DE.UTF-8";
}
```



*Example:*

```nix
{
  LANG = "en_US.UTF-8";
  LC_MONETARY = "de_DE.UTF-8";
  LC_TIME = "de_DE.UTF-8";
}
```



## core\.localisation\.timezone



The timezone to use



*Type:*
string



*Default:*

```nix
"Europe/Berlin"
```



## core\.localisation\.xkb\.console-bridge



Whether to use the xkb-console-bridge



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.localisation\.xkb\.layout



The keyboard layout to use



*Type:*
string



*Default:*

```nix
"de,de,us"
```



## core\.localisation\.xkb\.variant



The keyboard variant to use



*Type:*
string



*Default:*

```nix
"koy, ,"
```



## core\.lsd\.enable



Whether to enable lsd\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.network\.firewall\.enable



Whether to enable firewall\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.firewall\.allowPing



Whether to allow ping



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.firewall\.allowedTCPPortRanges



List of TCP port ranges to allow



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.firewall\.allowedTCPPorts



List of TCP ports to allow



*Type:*
list of signed integer



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.firewall\.allowedUDPPortRanges



List of UDP port ranges to allow



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.firewall\.allowedUDPPorts



List of UDP ports to allow



*Type:*
list of signed integer



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.firewall\.rejectPackets



Whether to reject packets



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/firewall/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/firewall/options.nix)



## core\.network\.nm\.enable



Whether to enable NetworkManager\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options.nix)



## core\.network\.nm\.extraPlugins



List of extra NetworkManager plugins to install



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "nm-openvpn"
  "nm-openvpn-sniffer"
  "nm-openvpn-sniffer"
]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options.nix)



## core\.network\.nm\.gui



Whether to enable Networkmanager gui components\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options.nix)



## core\.network\.nm\.unmanaged



List of network interfaces to not manage with NetworkManager



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/network/options/nm/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/network/options/nm/options.nix)



## core\.nix-helpers\.devenv\.enable



Whether to install devenv\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nix-helpers\.direnv\.enable



Whether to install direnv\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nix-helpers\.nh\.enable



Whether to enable nh\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nix-helpers\.nh\.clean\.enable



Whether to enable periodic nh clean user (garbage collection)\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nix-helpers\.nh\.clean\.dates



How often to run nh clean (systemd timer calendar)\.



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
"weekly"
```



## core\.nix-helpers\.nh\.clean\.extraArgs



Extra arguments passed to nh clean\.



*Type:*
(optionally newline-terminated) single-line string



*Default:*

```nix
""
```



*Example:*

```nix
"--keep 5 --keep-since 3d"
```



## core\.nix-helpers\.nixfmt\.enable



Whether to install nixfmt\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nvf\.enable



Whether to enable nvf\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nvf\.spellcheck\.enable



Whether to enable spellcheck\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.nvf\.spellcheck\.additionalWords



Additional words to add to the spellcheck dictionary



*Type:*
list of string



*Default:*

```nix
[
  "nvf"
  "qnix"
  "qf0xb"
  "QPC"
  "QConfigVM"
  "QFrame13"
]
```



## core\.nvf\.spellcheck\.languages



Languages to add to the spellcheck dictionary



*Type:*
list of string



*Default:*

```nix
[
  "en"
  "de"
]
```



## core\.passwords\.bitwarden\.cli\.enable



Whether to enable bitwarden nixos\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/bitwarden/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/bitwarden/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/bitwarden/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/bitwarden/options.nix)



## core\.passwords\.bitwarden\.desktop\.enable



Whether to enable bitwarden desktop\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/bitwarden/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/bitwarden/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/bitwarden/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/bitwarden/options.nix)



## core\.passwords\.keyring\.gnome\.enable



Whether to enable gnome keyring\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/keyring/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/keyring/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/keyring/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/keyring/options.nix)



## core\.passwords\.keyring\.gnome\.gui



Whether to enable gnome keyring gui\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/keyring/options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/core/passwords/options/keyring/options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/keyring/options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/core/passwords/options/keyring/options.nix)



## core\.plymouth\.enable



Whether to enable plymouth\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.polkit\.enable



Whether to enable polkit\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.polkit\.allowUserPowerCommands



Whether to allow user to execute power commands



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.shell\.enable



Whether to enable shell managerment



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.shell\.packages



Attrset of shell packages to install and add to pkgs\.custom overlay (for compatibility across multiple shells)\.
Both string and attr values will be passed as arguments to writeShellApplicationCompletions



*Type:*
attribute set of (string or (attribute set) or package)



*Default:*

```nix
{ }
```



*Example:*

```nix
''
  shell.packages = {
    myPackage1 = "echo 'Hello, World!'";
    myPackage2 = {
      runtimeInputs = [ pkgs.hello ];
      text = "hello --greeting 'Hi'";
    };
  };
''
```



## core\.shell\.aliases



Whether to enable aliases



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.shell\.defaultShell



Whether to enable default shell



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.shell\.fish\.enable



Whether to enable fish



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.shell\.qnixAliases



Whether to enable aliases for qnix-system



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.sops\.enable



Whether to enable sops\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.sops\.age\.generateKey



Whether to generate an age key automatically\.



*Type:*
boolean



*Default:*

```nix
false
```



## core\.sops\.age\.keyFile



Path to the age key file\. Defaults to /persist/home/\<user>/\.config/age/keys\.txt if user is available\.



*Type:*
null or string



*Default:*

```nix
null
```



## core\.sops\.defaultSopsFile



Default Sops File to decrypt and use\. Can be overridden per-secret with sopsFile\.



*Type:*
null or absolute path



*Default:*

```nix
null
```



## core\.sops\.secrets



Secrets to decrypt and provision\. Each secret maps to sops\.secrets\.\*



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



## core\.sops\.secrets\.\<name>\.format



Format of the secret\. ‘binary’ for raw bytes, ‘yaml’ for YAML parsing\.



*Type:*
null or one of “binary”, “yaml”



*Default:*

```nix
null
```



## core\.sops\.secrets\.\<name>\.group



Group of the decrypted secret file\.



*Type:*
null or string



*Default:*

```nix
null
```



## core\.sops\.secrets\.\<name>\.key



Key name in the sops file\. Defaults to the secret name\.



*Type:*
null or string



*Default:*

```nix
null
```



## core\.sops\.secrets\.\<name>\.mode



File mode (permissions) for the decrypted secret file\.



*Type:*
string



*Default:*

```nix
"0400"
```



## core\.sops\.secrets\.\<name>\.neededBy



List of systemd units that need this secret\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



## core\.sops\.secrets\.\<name>\.neededForUsers



Whether this secret is needed for user creation\. Automatically set to true if referenced via passwordFromSops\.



*Type:*
boolean



*Default:*

```nix
false
```



## core\.sops\.secrets\.\<name>\.owner



Owner of the decrypted secret file\.



*Type:*
null or string



*Default:*

```nix
null
```



## core\.sops\.secrets\.\<name>\.path



Path where the decrypted secret will be placed\. Defaults to /run/secrets/\<name>\.



*Type:*
null or string



*Default:*

```nix
null
```



## core\.sops\.secrets\.\<name>\.reloadUnits



List of systemd units to reload when this secret changes\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



## core\.sops\.secrets\.\<name>\.restartUnits



List of systemd units to restart when this secret changes\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



## core\.sops\.secrets\.\<name>\.sopsFile



Path to the sops file containing this secret\. Defaults to defaultSopsFile\.



*Type:*
null or absolute path



*Default:*

```nix
null
```



## core\.sops\.secrets\.\<name>\.wantedBy



List of systemd units that want this secret\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



## core\.ssh-server\.enable



Whether to enable ssh-server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.ssh-server\.allowPasswordAuthentication



Whether to allow password authentication



*Type:*
boolean



*Default:*

```nix
false
```



## core\.ssh-server\.allowRootLogin



Whether to allow root login



*Type:*
boolean



*Default:*

```nix
false
```



## core\.ssh-server\.port



Port to listen on for SSH connections



*Type:*
signed integer



*Default:*

```nix
22
```



## core\.ssh-server\.sshAgent



Whether to start the ssh agent



*Type:*
boolean



*Default:*

```nix
true
```



## core\.starship\.enable



Whether to enable starship\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.starship\.qnixFormat



Whether to enable qnix format\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.stylix\.enable



Whether to enable stylix\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.stylix\.colorScheme



The color scheme to use, must be in base16scheme repo



*Type:*
string



*Default:*

```nix
"solarized-dark"
```



## core\.stylix\.colorSchemeOverrides



Override the color scheme with custom colors



*Type:*
attribute set



*Default:*

```nix
{ }
```



## core\.stylix\.cursor

The cursor to use



*Type:*
attribute set



*Default:*

```nix
{
  package = pkgs.simp1e-cursors;
  name = "Simp1e-Solarized-Dark";
  size = 24;
}

```



## core\.stylix\.fonts\.emoji



The emoji font to use



*Type:*
attribute set



*Default:*

```nix
{
  package = pkgs.noto-fonts-color-emoji;
  name = "Noto Color Emoji";
}

```



## core\.stylix\.fonts\.monospace



The monospace font to use



*Type:*
attribute set



*Default:*

```nix
{
  package = pkgs.nerd-fonts.jetbrains-mono;
  name = "JetBrains Mono Nerd Font";
}

```



## core\.stylix\.fonts\.sansSerif



The sans-serif font to use



*Type:*
attribute set



*Default:*

```nix
{
  package = pkgs.fira-sans;
  name = "Fira Sans";
}

```



## core\.stylix\.fonts\.serif



The serif font to use



*Type:*
attribute set



*Default:*

```nix
{
  package = pkgs.fira-sans;
  name = "Fira Sans";
}

```



## core\.stylix\.fonts\.sizes



The sizes of the fonts



*Type:*
attribute set



*Default:*

```nix
{
  applications = 16;
  desktop = 16;
  popups = 16;
  terminal = 16;
}
```



## core\.stylix\.icons



The icons to use



*Type:*
attribute set



*Default:*

```nix
{
  enable = true;
  package = pkgs.fluent-icon-theme;
  dark = "Fluent-dark";
  light = "Fluent-light";
}

```



## core\.stylix\.opacity\.applications



The opacity of the applications



*Type:*
floating point number



*Default:*

```nix
0.5
```



## core\.stylix\.opacity\.terminal



The opacity of the terminal



*Type:*
floating point number



*Default:*

```nix
0.5
```



## core\.stylix\.solarizedColors



Colors converted from stylix base16 to solarized naming scheme (base03, base02, base01, base00, base0, base1, base2, base3, red, orange, yellow, green, cyan, blue, violet, magenta)



*Type:*
attribute set of string *(read only)*



## core\.stylix\.wallpapers\.enable



Whether to enable wallpapers\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.stylix\.wallpapers\.wallpapersPath



Path to the stylix wallpapers directory\. Contents are copied to ~/Pictures/wallpaper when stylix is enabled\.



*Type:*
absolute path



*Default:*

```nix
../wallpapers
```



## core\.user\.enable



Whether to enable user\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.user\.defaultExtraGroups



Groups to add to all users by default (e\.g\., \[ “video” “audio” ])



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "video"
  "audio"
  "users"
]
```



## core\.user\.root\.enable



Whether to enable root user\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.user\.root\.password



The hashed password for the root user (mutually exclusive with passwordFromSops)



*Type:*
null or string



*Default:*

```nix
null
```



## core\.user\.root\.passwordFromSops



Name of the sops secret containing the root user’s hashed password (mutually exclusive with password)



*Type:*
null or string



*Default:*

```nix
null
```



## core\.user\.users



Users to create (attrset: username -> user config)



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



## core\.user\.users\.\<name>\.description



User description/comment



*Type:*
null or string



*Default:*

```nix
null
```



## core\.user\.users\.\<name>\.extraGroups



Additional groups for the user



*Type:*
list of string



*Default:*

```nix
[ ]
```



## core\.user\.users\.\<name>\.group



Primary group for the user (required)



*Type:*
string



## core\.user\.users\.\<name>\.home



Home directory path



*Type:*
null or string



*Default:*

```nix
null
```



## core\.user\.users\.\<name>\.ignoreShellProgramCheck



Ignore shell program check



*Type:*
boolean



*Default:*

```nix
true
```



## core\.user\.users\.\<name>\.initialHashedPassword



Initial hashed password (mutually exclusive with passwordFromSops)



*Type:*
null or string



*Default:*

```nix
null
```



## core\.user\.users\.\<name>\.isNormalUser



Whether this is a normal user (exactly one of isNormalUser or isSystemUser must be set)



*Type:*
boolean



*Default:*

```nix
true
```



## core\.user\.users\.\<name>\.isSystemUser



Whether this is a system user (exactly one of isNormalUser or isSystemUser must be set)



*Type:*
boolean



*Default:*

```nix
false
```



## core\.user\.users\.\<name>\.openssh\.authorizedKeys\.keys



SSH authorized keys



*Type:*
list of string



*Default:*

```nix
[ ]
```



## core\.user\.users\.\<name>\.passwordFromSops



Name of the sops secret containing this user’s hashed password (mutually exclusive with initialHashedPassword)



*Type:*
null or string



*Default:*

```nix
null
```



## core\.virtualisation\.virt-manager\.enable



Whether to enable virt-manager\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.virtualisation\.virt-manager\.gui



Whether to enable virt-manager gui\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.virtualisation\.virt-manager\.passthrough



Whether to enable passthrough\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.yubikey\.enable



Whether to enable yubikey integration\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.yubikey\.autolock



Whether to enable autolock on yubikey removal\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.yubikey\.gui



Whether to enable yubikey management guis\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.yubikey\.login



Whether to enable login with yubikey\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## core\.yubikey\.sudo



Whether to enable sudo with yubikey\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.zfs\.enable



Whether to enable zfs\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.zfs\.scrub\.enable



Whether to enable zfs scrub\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## core\.zfs\.scrub\.interval



Interval for ZFS scrub



*Type:*
string



*Default:*

```nix
"12"
```



## desktop\.browser\.enable



Whether to enable browser\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.browser\.brave\.enable



Whether to enable Brave browser (annoying features disabled via policy)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.browser\.firefox\.enable



Whether to enable Firefox browser\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.dev-utilities\.enable



Whether to enable dev-utilities\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.dev-utilities\.postman\.enable



Whether to enable Postman development utility\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.dev-utilities\.wireshark\.enable



Whether to enable Wireshark development utility\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.displaymanager\.enable



Whether to enable displaymanager\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.displaymanager\.sddm\.enable



Whether to enable SDDM display manager\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options.nix)



## desktop\.displaymanager\.sddm\.theme\.package



SDDM theme package



*Type:*
null or package



*Default:*

```nix
pkgs.sddm-astronaut
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options.nix)



## desktop\.displaymanager\.sddm\.theme\.embeddedTheme



Embedded theme variant for the theme package



*Type:*
string



*Default:*

```nix
"black_hole"
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options.nix)



## desktop\.displaymanager\.sddm\.theme\.name



SDDM theme name



*Type:*
string



*Default:*

```nix
"sddm-astronaut-theme"
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/displaymanager/options/sddm-options.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/displaymanager/options/sddm-options.nix)



## desktop\.hyprdesktop\.enable



Whether to enable hyprdesktop\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.hyprdesktop\.ags\.enable



Whether to enable ags\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags.nix)



## desktop\.hyprdesktop\.ags\.configDir



Path to the AGS configuration (git checkout of qnix-ags or similar)\. If null, the qnix-ags flake’s configDir is used\.



*Type:*
null or absolute path



*Default:*

```nix
null
```



*Example:*

```nix
"/home/user/projects/qnix-ags"
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags.nix)



## desktop\.hyprdesktop\.ags\.displays\.large



Outputs that should use the wide AGS bar layout\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "eDP-1"
  "HDMI-A-1"
]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags.nix)



## desktop\.hyprdesktop\.ags\.displays\.small



Outputs that should use the condensed AGS bar layout\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "DP-1"
]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags.nix)



## desktop\.hyprdesktop\.ags\.extraPackages



Extra packages to use when overriding ags in dev shells or elsewhere\. Note: hyprland, battery, notifd, tray, and wireplumber are always included\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/ags.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/ags.nix)



## desktop\.hyprdesktop\.hyprsuite\.hyprland\.enable



Whether to enable hyprland\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)



## desktop\.hyprdesktop\.hyprsuite\.hyprland\.noHardwareCursors



Whether to enable no hardware cursors\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)



## desktop\.hyprdesktop\.hyprsuite\.hyprland\.setDefaultAnimations



Whether to enable set default animations\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)



## desktop\.hyprdesktop\.hyprsuite\.hyprland\.setDefaultKeybinds



Whether to enable set default keybinds\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)



## desktop\.hyprdesktop\.hyprsuite\.hyprland\.setDefaultSpecialWorkspace



Whether to enable set default special workspace settings\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)



## desktop\.hyprdesktop\.hyprsuite\.hyprland\.setDefaultWindowRules



Whether to enable set default window rules\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/hyprsuite/hyprland.nix)



## desktop\.hyprdesktop\.noctalia\.enable



Whether to enable noctalia\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/noctalia\.nix](file:///nix/store/gdd7fj5xk86hw82r0q7v7a66fl4nrxd1-source/modules/desktop/hyprdesktop/options/noctalia.nix)
 - [/nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/noctalia\.nix](file:///nix/store/ds4scs4j6m5cps8np5lggzfg58r7n4sh-source/modules/desktop/hyprdesktop/options/noctalia.nix)



## desktop\.jetbrains\.enable



Whether to enable jetbrains\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.clion\.enable



Whether to enable CLion\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.datagrip\.enable



Whether to enable DataGrip\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.dataspell\.enable



Whether to enable DataSpell\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.idea\.enable



Whether to enable IntelliJ IDEA\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.phpstorm\.enable



Whether to enable PHPStorm\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.pycharm\.enable



Whether to enable PyCharm\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.rider\.enable



Whether to enable Rider\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.ruby-mine\.enable



Whether to enable RubyMine\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.rust-rover\.enable



Whether to enable Rust Rover\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.jetbrains\.webstorm\.enable



Whether to enable WebStorm\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.laptop-specifics\.enable



Whether to enable laptop-specific services (Tuned, upower)\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## desktop\.laptop-specifics\.tuned\.enable



Whether to enable TuneD for power/performance profiles (replaces power-profiles-daemon)\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## desktop\.laptop-specifics\.tuned\.profile



Default TuneD profile\. quiet = custom profile stricter than powersave (CPU cap + power hints);
full-power = maximum throughput (throughput-performance)\.



*Type:*
one of “quiet”, “powersave”, “balanced”, “performance”, “full-power”



*Default:*

```nix
"balanced"
```



## desktop\.laptop-specifics\.tuned\.quietMaxPerfPct



When using the quiet profile, cap CPU at this percentage of max frequency (Intel P-State / AMD)\.
Lower = cooler/quieter, higher = more headroom (e\.g\. 50 = very quiet, 70 = balanced quiet)\.



*Type:*
integer between 10 and 100 (both inclusive)



*Default:*

```nix
70
```



## desktop\.laptop-specifics\.upower



Whether to enable upower (battery/power info; required by TuneD when using PPD compatibility)\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## desktop\.obsidian\.enable



Whether to enable obsidian\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.periphery\.thunderbolt\.enable



Whether to enable thunderbolt\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## desktop\.sound\.enable



Whether to enable sound\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## desktop\.sound\.gui\.enable



Whether to enable GUI sound applications\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## desktop\.terminal\.enable



Whether to enable terminal\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.tidal-hifi\.enable



Whether to enable tidal-hifi\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.vscode\.enable



Whether to enable VS Code / Cursor\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## desktop\.vscode\.package



VS Code package to install via the Home Manager vscode module
(for example, pkgs\.vscode, pkgs\.vscodium or pkgs\.cursor)\.
If not set, the default package will be pkgs\.cursor\.



*Type:*
package



*Default:*

```nix
<derivation cursor-2.6.19>
```



## desktop\.vscode\.agentPanelSize



Default width (in pixels) for the Cursor agent panel/sidebar



*Type:*
signed integer



*Default:*

```nix
400
```



## desktop\.xdg-folders\.enable



Whether to enable xdg-folders\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## development



Enable development tools\.



*Type:*
boolean



*Default:*

```nix
true
```



## headless



Run system without graphical environment\.



*Type:*
boolean



*Default:*

```nix
false
```



## persist\.home\.cache\.directories



Directories to cache in home filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## persist\.home\.cache\.files



Files to cache in home filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## persist\.home\.defaultFolders



Whether to enable default folders\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## persist\.home\.directories



Directories to persist in home filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## persist\.home\.files



Files to persist in home filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## persist\.root\.cache\.directories



Directories to cache in root filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## persist\.root\.cache\.files



Files to cache in root filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## persist\.root\.defaultFolders



Whether to enable default folders\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```



## persist\.root\.directories

Directories to persist in root filesystem



*Type:*
list of string



*Default:*

```nix
[
  "/var/log"
  "/var/lib/nixos"
]
```



## persist\.root\.files



Files to persist in root filesystem



*Type:*
list of string



*Default:*

```nix
[ ]
```



## server



Is this a server?



*Type:*
boolean



*Default:*

```nix
false
```



## wayland



Is wayland running?



*Type:*
boolean



*Default:*

```nix
false
```



## work



Enable work-related programs and services\.



*Type:*
boolean



*Default:*

```nix
false
```


