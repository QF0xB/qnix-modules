{
  lib,
  pkgs,
  qnixModules,
}:

let
  eval = lib.evalModules {
    modules = qnixModules;
    specialArgs = {
      pkgs = pkgs;
    };
  };

  # nixosOptionsDoc is in pkgs directly, not pkgs.lib
  optionsDoc = pkgs.nixosOptionsDoc {
    options = eval.options;
    transformOptions =
      opt:
      opt
      // {
        # Optional: shorten the path in docs
        name = lib.removePrefix "qnix." opt.name;
      };
  };

  # HTML: convert CommonMark to HTML with pandoc + search bar (template in separate file to avoid Nix string escaping)
  html =
    pkgs.runCommand "qnix-options-html"
      {
        nativeBuildInputs = [ pkgs.pandoc ];
        markdown = optionsDoc.optionsCommonMark;
        template = ./options-template.html;
      }
      ''
        mkdir -p $out
        pandoc -f commonmark -t html $markdown -o body.html
        sed -e '/__BODY_PLACEHOLDER__/r body.html' -e '/__BODY_PLACEHOLDER__/d' $template > $out/options.html
      '';
in
{
  # optionsCommonMark and optionsJSON are already derivations (built files)
  markdown = optionsDoc.optionsCommonMark;
  json = optionsDoc.optionsJSON;
  ascii = optionsDoc.optionsAsciiDoc;
  html = html;
}
