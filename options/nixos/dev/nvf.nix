{ lib, ... }:
{
  options.qnix.dev.nvf = {
    enable = lib.mkEnableOption "nvf" // {
      default = false;
    };

    spellcheck = {
      enable = lib.mkEnableOption "nvf spellcheck" // {
        default = true;
      };

      languages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "en"
          "de"
        ];
        description = "Languages to add to the nvf spellcheck dictionary.";
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
        description = "Additional words to add to the nvf spellcheck dictionary.";
      };
    };
  };
}
