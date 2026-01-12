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
` <derivation brave-1.85.120> `



## apps\.file-manager



The default file-manager



*Type:*
package



*Default:*
` <derivation nemo-6.6.3> `



## apps\.notes



Notetaking app



*Type:*
package



*Default:*
` <derivation obsidian-1.10.6> `



## apps\.terminal



The default terminal emulator



*Type:*
package



*Default:*
` <derivation kitty-0.45.0> `



## core\.boot\.efiSupport



Enable EFI support



*Type:*
boolean



*Default:*
` true `



## core\.boot\.encrypted



Whether to enable encrypted boot\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.boot\.encryptedDevice



Device to use for encrypted boot



*Type:*
string



*Default:*
` "/dev/disk/by-label/NIXBOOT" `



## core\.boot\.grub\.enable



Whether to enable grub bootloader\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/b2ir1pf87llnxxn319k834i3cm5sjsx8-source/modules/core/boot/options/grub-options\.nix](file:///nix/store/b2ir1pf87llnxxn319k834i3cm5sjsx8-source/modules/core/boot/options/grub-options.nix)



## core\.boot\.grub\.device



Device to use for GRUB



*Type:*
string



*Default:*
` "nodev" `

*Declared by:*
 - [/nix/store/b2ir1pf87llnxxn319k834i3cm5sjsx8-source/modules/core/boot/options/grub-options\.nix](file:///nix/store/b2ir1pf87llnxxn319k834i3cm5sjsx8-source/modules/core/boot/options/grub-options.nix)



## core\.boot\.systemd-boot\.enable



Whether to enable systemd-boot bootloader\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/b2ir1pf87llnxxn319k834i3cm5sjsx8-source/modules/core/boot/options/systemd-boot-options\.nix](file:///nix/store/b2ir1pf87llnxxn319k834i3cm5sjsx8-source/modules/core/boot/options/systemd-boot-options.nix)



## core\.boot\.timeout



Timeout for Boot



*Type:*
signed integer



*Default:*
` 3 `



## core\.boot\.zfsSupport



Enable ZFS support



*Type:*
boolean



*Default:*
` true `



## core\.impermanence\.enable



Whether to enable impermanence\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



## core\.localisation\.enable



Whether to enable localisation\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.localisation\.localeSettings



Locale environment variables (LANG, LC_\*)



*Type:*
attribute set of string



*Default:*

```
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

```
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
` "Europe/Berlin" `



## core\.localisation\.xkb\.console-bridge



Whether to use the xkb-console-bridge



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.localisation\.xkb\.layout



The keyboard layout to use



*Type:*
string



*Default:*
` "de,de,us" `



## core\.localisation\.xkb\.variant



The keyboard variant to use



*Type:*
string



*Default:*
` "koy, ," `



## core\.lsd\.enable



Whether to enable lsd\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.polkit\.enable



Whether to enable polkit\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.polkit\.allowUserPowerCommands



Whether to allow user to execute power commands



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.shell\.enable



Whether to enable shell managerment



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.shell\.packages



Attrset of shell packages to install and add to pkgs\.custom overlay (for compatibility across multiple shells)\.
Both string and attr values will be passed as arguments to writeShellApplicationCompletions



*Type:*
attribute set of (string or (attribute set) or package)



*Default:*
` { } `



*Example:*

```
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
` true `



*Example:*
` true `



## core\.shell\.defaultShell



Whether to enable default shell



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.shell\.fish\.enable



Whether to enable fish



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.shell\.qnix-aliases



Whether to enable aliases for qnix-system



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.starship\.enable



Whether to enable starship\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.starship\.qnixFormat



Whether to enable qnix format\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.stylix\.enable



Whether to enable stylix\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.stylix\.colorScheme



The color scheme to use, must be in base16scheme repo



*Type:*
string



*Default:*
` "solarized-dark" `



## core\.stylix\.colorSchemeOverrides



Override the color scheme with custom colors



*Type:*
attribute set



*Default:*
` { } `



## core\.stylix\.cursor



The cursor to use



*Type:*
attribute set



*Default:*

```
{
  name = "Simp1e-Solarized-Dark";
  package = <derivation simp1e-cursors-20250223>;
  size = 24;
}
```



## core\.stylix\.fonts\.emoji



The emoji font to use



*Type:*
attribute set



*Default:*

```
{
  name = "Noto Color Emoji";
  package = <derivation noto-fonts-color-emoji-2.051>;
}
```



## core\.stylix\.fonts\.monospace



The monospace font to use



*Type:*
attribute set



*Default:*

```
{
  name = "JetBrains Mono Nerd Font";
  package = <derivation nerd-fonts-jetbrains-mono-3.4.0+2.304>;
}
```



## core\.stylix\.fonts\.sansSerif



The sans-serif font to use



*Type:*
attribute set



*Default:*

```
{
  name = "Fira Sans";
  package = <derivation fira-sans-4.301>;
}
```



## core\.stylix\.fonts\.serif



The serif font to use



*Type:*
attribute set



*Default:*

```
{
  name = "Fira Sans";
  package = <derivation fira-sans-4.301>;
}
```



## core\.stylix\.fonts\.sizes



The sizes of the fonts



*Type:*
attribute set



*Default:*

```
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

```
{
  dark = "Fluent-dark";
  enable = true;
  light = "Fluent-light";
  package = <derivation Fluent-icon-theme-2025-08-21>;
}
```



## core\.stylix\.opacity\.applications



The opacity of the applications



*Type:*
floating point number



*Default:*
` 0.5 `



## core\.stylix\.opacity\.terminal



The opacity of the terminal



*Type:*
floating point number



*Default:*
` 0.5 `



## core\.stylix\.solarizedColors



Colors converted from stylix base16 to solarized naming scheme (base03, base02, base01, base00, base0, base1, base2, base3, red, orange, yellow, green, cyan, blue, violet, magenta)



*Type:*
attribute set of string *(read only)*



*Default:*
` { } `



## core\.user\.enable



Whether to enable user\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



## core\.user\.defaultExtraGroups



Groups to add to all users by default (e\.g\., \[ “video” “audio” ])



*Type:*
list of string



*Default:*
` [ ] `



*Example:*

```
[
  "video"
  "audio"
]
```



## core\.user\.root\.enable



Whether to enable root user\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



## core\.user\.root\.password



The password for the root user



*Type:*
string



*Default:*
` "" `



## core\.user\.users



Users to create (attrset: username -> user config)



*Type:*
attribute set of (submodule)



*Default:*
` { } `



## core\.user\.users\.\<name>\.description



User description/comment



*Type:*
null or string



*Default:*
` null `



## core\.user\.users\.\<name>\.extraGroups



Additional groups for the user



*Type:*
list of string



*Default:*
` [ ] `



## core\.user\.users\.\<name>\.group



Primary group for the user (required)



*Type:*
string



## core\.user\.users\.\<name>\.home



Home directory path



*Type:*
null or string



*Default:*
` null `



## core\.user\.users\.\<name>\.ignoreShellProgramCheck



Ignore shell program check



*Type:*
boolean



*Default:*
` true `



## core\.user\.users\.\<name>\.initialHashedPassword



Initial hashed password



*Type:*
null or string



*Default:*
` null `



## core\.user\.users\.\<name>\.isNormalUser



Whether this is a normal user (exactly one of isNormalUser or isSystemUser must be set)



*Type:*
boolean



*Default:*
` true `



## core\.user\.users\.\<name>\.isSystemUser



Whether this is a system user (exactly one of isNormalUser or isSystemUser must be set)



*Type:*
boolean



*Default:*
` false `



## core\.user\.users\.\<name>\.openssh\.authorizedKeys\.keys



SSH authorized keys



*Type:*
list of string



*Default:*
` [ ] `



## core\.zfs\.enable



Whether to enable zfs\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.zfs\.scrub\.enable



Whether to enable zfs scrub\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## core\.zfs\.scrub\.interval



Interval for ZFS scrub



*Type:*
string



*Default:*
` "12" `



## development



Enable development tools\.



*Type:*
boolean



*Default:*
` true `



## headless



Run system without graphical environment\.



*Type:*
boolean



*Default:*
` false `



## persist\.home\.cache\.directories



Directories to cache in home filesystem



*Type:*
list of string



*Default:*
` [ ] `



## persist\.home\.cache\.files



Files to cache in home filesystem



*Type:*
list of string



*Default:*
` [ ] `



## persist\.home\.defaultFolders



Whether to enable default folders\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## persist\.home\.directories



Directories to persist in home filesystem



*Type:*
list of string



*Default:*
` [ ] `



## persist\.home\.files



Files to persist in home filesystem



*Type:*
list of string



*Default:*
` [ ] `



## persist\.root\.cache\.directories



Directories to cache in root filesystem



*Type:*
list of string



*Default:*
` [ ] `



## persist\.root\.cache\.files



Files to cache in root filesystem



*Type:*
list of string



*Default:*
` [ ] `



## persist\.root\.defaultFolders



Whether to enable default folders\.



*Type:*
boolean



*Default:*
` true `



*Example:*
` true `



## persist\.root\.directories



Directories to persist in root filesystem



*Type:*
list of string



*Default:*

```
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
` [ ] `



## server



Is this a server?



*Type:*
boolean



*Default:*
` false `



## wayland



Is wayland running?



*Type:*
boolean



*Default:*
` false `



## work



Enable work-related programs and services\.



*Type:*
boolean



*Default:*
` false `


