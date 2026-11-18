---
name: git-workflow-and-versioning
description: Use for requested commits, branching, conflict resolution, pull requests, releases, version bumps, or changelogs. Routine code edits do not need this workflow.
---

# Git workflow and versioning

## Scope and authority

Use this workflow for the Git operation the user requested. A request to edit
code authorizes edits and verification, not commits, pushes, releases, or
destructive recovery. Preserve unrelated work. Ask before discarding changes,
rewriting published history, or changing Git configuration.

## Requested commits

1. Inspect status, the intended diff, and recent commit messages.
2. Run checks appropriate to the change. Review staged content for secrets.
3. Stage only intended files. Keep unrelated changes separate.
4. Load `git-signing` and follow its signed-commit and verification workflow.
5. Use a scoped Conventional Commit subject describing intent. Mark breaking
   changes with `!` and explain compatibility impact in the body.

If signing or hooks fail, fix the cause and retry with signing enabled. Preserve
the staged changes while waiting for user action. Do not bypass hooks or signing.

## Branches and pull requests

Follow the repository's existing branch policy. Create or switch branches only
when needed for the requested operation. Before opening a pull request, inspect
the full diff from its base and all included commits. Use `gh` for GitHub work.
Report the resulting URL. Push only when requested.

## Conflicts and recovery

Inspect both sides and existing user changes before resolving conflicts. Prefer
small, reversible edits. Never use a destructive reset as automatic recovery.
Ask when the intended resolution cannot be established from the code or request.

## Requested releases

Check consumer-visible compatibility before choosing a semantic version bump:
major for breaking changes, minor for compatible features, patch for compatible
fixes. Follow the repository's release and changelog conventions. Explain user
impact and migration steps. Create tags or publish artifacts only when requested.
