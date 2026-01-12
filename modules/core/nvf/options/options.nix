{ lib, ... }:

{
  options.qnix.core.nvf = {
    enable = lib.mkEnableOption "nvf" // {
      default = true;
    };

    spellcheck = {
      enable = lib.mkEnableOption "spellcheck" // {
        default = true;
      };
      languages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "en"
          "de"
        ];
        description = "Languages to add to the spellcheck dictionary";
      };

      additionalWords = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "nvf"
          "qnix"
          "qf0xb"
          "QPC"
          "QConfigVM"
          "QFrame13"
        ];
        description = "Additional words to add to the spellcheck dictionary";
      };
    };
  };
}
