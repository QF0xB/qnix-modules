{ lib, pkgs, qnixModules }:

let
  eval = lib.evalModules {
    modules = qnixModules;
  };
  
  # nixosOptionsDoc is in pkgs directly, not pkgs.lib
  optionsDoc = pkgs.nixosOptionsDoc {
    options = eval.options;
    transformOptions = opt: opt // {
      # Optional: shorten the path in docs
      name = lib.removePrefix "qnix." opt.name;
    };
  };
in
{
  # optionsCommonMark and optionsJSON are already derivations (built files)
  # Just return them directly - they have outPath pointing to the generated files
  markdown = optionsDoc.optionsCommonMark;
  json = optionsDoc.optionsJSON;
  ascii = optionsDoc.optionsAsciiDoc;
}
