{
  environments = [
    "integrated-home"
    "standalone-home"
  ];

  home =
    { pkgs, ... }:
    {
      home.packages = with pkgs.llm-agents; [
        agent-browser
        agentsview
        ccusage
        codegraph
        ctx
        fence
        git-ai
        officecli
        pdfvision
        rtk
        skills
      ];
    };
}
