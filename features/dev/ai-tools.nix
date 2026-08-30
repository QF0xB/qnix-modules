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
        ck
        codegraph
        ctx
        fence
        git-ai
        gitnexus
        gno
        nono
        officecli
        pdfvision
        qmd
        rtk
        skills
      ];
    };
}
