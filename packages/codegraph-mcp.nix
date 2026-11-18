{ llm-agents }:

llm-agents.codegraph.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    mcp="$out/lib/node_modules/@colbymchenry/codegraph/dist/mcp"
    substituteInPlace "$mcp/tools.js" \
      --replace-fail \
        'PRIMARY TOOL — call FIRST for almost any question OR before an edit:' \
        'INDEXED PROJECTS ONLY — use native filesystem tools to confirm a .codegraph/ directory at the target or an ancestor before the first query; cache that result per project for the session. Without an index, use Read/Grep/Glob directly without a Codegraph probe. Create an index only on explicit user request. For a confirmed indexed project, prefer this tool for structural questions or before an edit:'
    substituteInPlace "$mcp/server-instructions.js" \
      --replace-fail \
        '# Codegraph — code intelligence over an indexed knowledge graph' \
        '# Codegraph — code intelligence over an indexed knowledge graph\n\nIndex prerequisite: All guidance below applies only to confirmed indexed projects. Before the first query for a target, use native filesystem tools to check for .codegraph/ at that directory or an ancestor. Cache the result per project for the session. For an unindexed target, use Read/Grep/Glob directly without a Codegraph probe. Index creation requires an explicit user request.' \
      --replace-fail \
        '# Codegraph — available (per-project; pass projectPath)' \
        '# Codegraph — available (per-project; pass projectPath)\n\nBefore the first query for a target, confirm .codegraph/ at that directory or an ancestor with native filesystem tools. Cache the result per project for the session. Use Read/Grep/Glob directly for unindexed targets, without probing Codegraph. Index creation requires an explicit user request.'
  '';
})
