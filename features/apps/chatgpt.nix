{
  environments = [
    "nixos"
    "integrated-home"
    "standalone-home"
  ];

  persistence.users."*".directories = [ ".config/ChatGPT" ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.llm-agents.chatgpt ];
    };
}
