{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qnix.system.shell;

  loginShellPackage =
    {
      fish = pkgs.fish;
      zsh = pkgs.zsh;
      bash = pkgs.bashInteractive;
    }
    .${cfg.defaultShell.package};

  loginShellBinary =
    "${loginShellPackage}/bin/${
      if cfg.defaultShell.package == "bash" then "bash" else cfg.defaultShell.package
    }";
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.attrValues cfg.packages;

    qnix.persist.users."*".directories = lib.optionals (cfg.fish.enable || cfg.defaultShell.package == "fish") [
      ".local/share/fish"
    ];

    programs.bash.interactiveShellInit = lib.mkIf (cfg.defaultShell.enable && cfg.defaultShell.package != "bash") ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "${cfg.defaultShell.package}" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${loginShellBinary} $LOGIN_OPTION
      fi
    '';

    programs.fish.enable = cfg.fish.enable || cfg.defaultShell.package == "fish";

    programs.zsh = {
      enable = cfg.zsh.enable || cfg.defaultShell.package == "zsh";
      autosuggestions.enable = cfg.zsh.autosuggestions;
      syntaxHighlighting.enable = cfg.zsh.syntaxHighlighting;
      enableCompletion = cfg.zsh.enableCompletion;
    };

    users.defaultUserShell = lib.mkIf cfg.defaultShell.enable loginShellPackage;
  };
}
