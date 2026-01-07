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
` <derivation brave-1.85.118> `



## apps\.file-manager



The default file-manager



*Type:*
package



*Default:*
` <derivation nemo-6.6.2> `



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



## boot\.enable



Whether to enable boot\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `



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


