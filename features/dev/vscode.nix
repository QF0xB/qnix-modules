{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [
    ".config/Code"
    ".vscode/extensions"
  ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.vscode ];
    };
}
