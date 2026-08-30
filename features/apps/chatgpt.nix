{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.llm-agents.chatgpt ];
    };
}
