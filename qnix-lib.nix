{ lib, pkgs, ... }:
lib.extend (
  _: libprev: {
    # Namespace
    qnix-lib = rec {
      # writeShellApplication with support for completions
      writeShellApplicationCompletions =
        {
          name,
          bashCompletion ? null,
          zshCompletion ? null,
          fishCompletion ? null,
          ...
        }@shellArgs:
        let
          inherit (pkgs) writeShellApplication writeTextFile symlinkJoin;
          # get the needed arguments for writeShellApplication
          app = writeShellApplication (lib.intersectAttrs (lib.functionArgs writeShellApplication) shellArgs);
          completions =
            lib.optional (bashCompletion != null) (writeTextFile {
              name = "${name}.bash";
              destination = "/share/bash-completion/completions/${name}.bash";
              text = bashCompletion;
            })
            ++ lib.optional (zshCompletion != null) (writeTextFile {
              name = "${name}.zsh";
              destination = "/share/zsh/site-functions/_${name}";
              text = zshCompletion;
            })
            ++ lib.optional (fishCompletion != null) (writeTextFile {
              name = "${name}.fish";
              destination = "/share/fish/vendor_completions.d/${name}.fish";
              text = fishCompletion;
            });
        in
        if lib.length completions == 0 then
          app
        else
          symlinkJoin {
            inherit name;
            inherit (app) meta;
            paths = [ app ] ++ completions;
          };

      # produces an attrset shell package with completions from either a string / writeShellApplication attrset / package
      mkShellPackages = lib.mapAttrs (
        name: value:
        if lib.isString value then
          pkgs.writeShellApplication {
            inherit name;
            text = value;
          }
        # packages
        else if lib.isDerivation value then
          value
      # attrs to pass to writeShellApplication
      else
        writeShellApplicationCompletions (value // { inherit name; })
      );

      # Convert stylix base16 colors to solarized naming scheme
      # Takes stylix's base16 color set and returns colors in solarized format
      # Usage: lib.qnix-lib.stylixToSolarized config.stylix.base16
      stylixToSolarized = base16: {
        # Base colors (direct mapping)
        base03 = base16.base03 or "";
        base02 = base16.base02 or "";
        base01 = base16.base01 or "";
        base00 = base16.base00 or "";
        
        # Light colors (base16 -> solarized mapping)
        base0 = base16.base04 or "";
        base1 = base16.base05 or "";
        base2 = base16.base06 or "";
        base3 = base16.base07 or "";
        
        # Accent colors (base16 -> solarized mapping)
        red = base16.base08 or "";
        orange = base16.base09 or "";
        yellow = base16.base0A or "";
        green = base16.base0B or "";
        cyan = base16.base0C or "";
        blue = base16.base0D or "";
        violet = base16.base0E or "";
        magenta = base16.base0F or "";
      };
    };
  }
)
