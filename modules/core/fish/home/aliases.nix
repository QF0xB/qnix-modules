{ dots, config , ... }:

let
  cfg = config.qnix.core.fish;
in
{
  config = lib.mkIf (cfg.enable && cfg.aliases) {
    home.shellAliases = {
      c = "clear";
      dots = "cd ${dots}";
      qnix = if cfg.qnix-aliases then "cd ~/projects/qnix" else "";
      ls = "clear && lsd -l";
      lss = "lsd -la";
      lsa = "clear && lsd -la";
      mime = "xdg-mime query filetype";
      mkdir = "mkdir -p";
      mount = "mount --mkdir";
      open = "xdg-open";

      # Git
      ga = "git add .";
      gc = "git commit";
      gp = "git push";

      # NIX
      nhs = "nh os switch ${dots}";
      nbv = "nix build .#nixosConfigurations.QConfigVM.config.system.build.vm";

      # cd aliases
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
    };
  };
}