# Pinned upstream plugins, skills, and rules for coding agents that are not
# packaged in nixpkgs or llm-agents.
{
  callPackage,
  fetchFromGitHub,
  jq,
  lib,
  llm-agents,
  nodejs,
  runCommand,
  writeShellScript,
}:

let
  cavemanSrc = fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    tag = "v4.0.1";
    hash = "sha256-2xZHdWkWJrPAJ8++qW0Xmb3eORZ41e+GsZjIphqTtlI=";
  };

  mattpocockSrc = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    tag = "v1.3.1";
    hash = "sha256-/mAmj7QFdyOWhLmy3Rt2/Hfsh5qwirTRax7hmQffFdo=";
  };

  aislop = callPackage ./aislop.nix { };

  # Mirrors the `skills` list in the upstream `.claude-plugin/plugin.json`.
  mattpocockSkillNames = {
    engineering = [
      "ask-matt"
      "code-review"
      "codebase-design"
      "diagnosing-bugs"
      "domain-modeling"
      "grill-with-docs"
      "implement"
      "implement-spec"
      "improve-codebase-architecture"
      "pr"
      "prototype"
      "research"
      "retro"
      "setup-matt-pocock-skills"
      "tdd"
      "to-spec"
      "to-tickets"
      "triage"
      "wayfinder"
      "wizard"
    ];
    productivity = [
      "grill-me"
      "grilling"
      "handoff"
      "teach"
      "to-questionnaire"
      "wait-what"
      "writing-for-agents"
    ];
  };

  # Caveman skills that work without the Claude Code hooks and session logs.
  cavemanSkillNames = [
    "caveman"
    "caveman-commit"
    "caveman-compress"
    "caveman-review"
    "megacave"
    "ultracave"
  ];
in
{
  inherit aislop;

  claudePlugins = {
    # The upstream hooks skip themselves when `node` is not on PATH, so pin it.
    caveman = runCommand "caveman-claude-plugin" { } ''
      cp -r ${cavemanSrc} $out
      chmod -R u+w $out
      sed -i \
        -e 's#command -v node >/dev/null 2>&1 || exit 0; ##' \
        -e 's#; node #; ${lib.getExe nodejs} #' \
        $out/.claude-plugin/plugin.json
      if grep -q 'command -v node' $out/.claude-plugin/plugin.json; then
        echo "caveman plugin hooks changed shape; update the node substitution" >&2
        exit 1
      fi
    '';

    # Home Manager links plugin files into the store, and Claude Code rejects
    # explicit manifest paths that resolve outside the plugin directory. The
    # skills move to the default `skills/` folder, which is discovered through
    # the links, and the explicit list is dropped.
    mattpocock-skills = runCommand "mattpocock-skills-claude-plugin" { } ''
      mkdir -p $out/.claude-plugin $out/skills
      ${lib.getExe jq} 'del(.skills)' ${mattpocockSrc}/.claude-plugin/plugin.json \
        > $out/.claude-plugin/plugin.json
      for skill in $(${lib.getExe jq} -r '.skills[]' ${mattpocockSrc}/.claude-plugin/plugin.json); do
        cp -r ${mattpocockSrc}/$skill $out/skills/
      done
    '';

    # Same constraint for the hook module, which only makes plan review
    # non-blocking. Without it, Claude waits until the review is submitted.
    plannotator = runCommand "plannotator-claude-plugin" { } ''
      mkdir $out
      cp -r ${llm-agents.plannotator.src}/apps/hook/{.claude-plugin,hooks} -t $out
      chmod -R u+w $out
      rm -r $out/hooks/mod
      ${lib.getExe jq} 'del(.modules)' ${llm-agents.plannotator.src}/apps/hook/hooks/hooks.json \
        > $out/hooks/hooks.json
    '';
  };

  # Plain skill directories for agents without Claude Code plugin support.
  skills =
    lib.genAttrs cavemanSkillNames (name: "${cavemanSrc}/skills/${name}")
    // lib.concatMapAttrs (
      group: names: lib.genAttrs names (name: "${mattpocockSrc}/skills/${group}/${name}")
    ) mattpocockSkillNames;

  claudeStatusLine = "bash ${cavemanSrc}/src/hooks/caveman-statusline.sh";

  # aislop reports on every edit, even when nothing was found. Dropping the
  # clean reports keeps them out of the agent context.
  aislopClaudeHook = writeShellScript "aislop-claude-hook" ''
    output="$(${lib.getExe aislop} hook claude)" || exit 0
    if ${lib.getExe jq} -e \
      '.hookSpecificOutput.additionalContext | fromjson | (.counts.total // 1) > 0' \
      <<<"$output" >/dev/null 2>&1; then
      printf '%s' "$output"
    fi
  '';

  # Only refreshes the score baseline. aislop labels its report as a
  # PostToolUse result, which does not match the FileChanged event.
  aislopClaudeFileChangedHook = "${lib.getExe aislop} hook claude --on-file-changed >/dev/null";

  # Always-on instructions for agents that load a global AGENTS.md.
  # `rules/caveman.md` is a copy of `src/rules/caveman-activate.md` from the
  # pinned caveman tag. It is vendored because the context options need text,
  # and reading it from the fetched source would require import from
  # derivation. `rules/rtk.md` is the RTK.md that `rtk init` writes.
  agentsContext = lib.concatStringsSep "\n" [
    (builtins.readFile ../rules/caveman.md)
    (builtins.readFile ../rules/aislop.md)
    (builtins.readFile ../rules/rtk.md)
  ];

  aislopClaudeRule = ../rules/aislop-claude.md;
  rtkRule = ../rules/rtk.md;

  # The aislop Claude hook writes per-session state next to the project's
  # committed config.
  gitIgnores = [
    ".aislop/baseline.json"
    ".aislop/history.jsonl"
    ".aislop/hook.lock"
    ".aislop/session.jsonl"
  ];
}
