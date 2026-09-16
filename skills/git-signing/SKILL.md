---
name: git-signing
description: Use when committing changes in a QNix repository. Stages reviewed changes, verifies them, and creates a YubiKey-signed final commit with a notification.
---

# Signed Git Commits

Use this workflow whenever a user asks to commit changes.

1. Finish implementation and all requested verification before staging anything.
2. Inspect `git status`, the intended diff, and recent commit messages.
3. Stage only the intended files. Do not stage unrelated worktree changes.
4. Make the commit the final action, after all edits and checks are complete.
5. Assess compatibility before writing the commit subject. Use `<type>(<scope>): <summary>` for compatible changes. Use `<type>(<scope>)!: <summary>` for breaking changes, for example `feat(opencode)!: replace the skill registry format`.
6. Run `qnix-signed-commit "<scoped Conventional Commit subject>"` from the repository root.

The helper rejects malformed subjects and sends a persistent critical notification before it opens the GPG prompt. Wait for the user to touch their YubiKey. Never use `git commit`, `git commit --no-gpg-sign`, or a non-signing commit tool as a fallback.

If signing times out, leave the staged changes intact and ask the user to complete a local GPG signing prompt before retrying.
