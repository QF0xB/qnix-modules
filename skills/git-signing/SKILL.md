---
name: git-signing
description: Use when committing changes in a QNix repository. Stages reviewed changes and requires signed commits with signature verification. Unsigned commits are forbidden.
---

# Signed Git Commits

Use this workflow whenever a user asks to commit changes.

1. Finish implementation and all requested verification before staging anything.
2. Inspect `git status`, the intended diff, and recent commit messages.
3. Stage only the intended files. Do not stage unrelated worktree changes.
4. Commit only after all edits and checks are complete.
5. Assess compatibility before writing the commit subject. Use `<type>(<scope>): <summary>` for compatible changes. Use `<type>(<scope>)!: <summary>` for breaking changes, for example `feat(opencode)!: replace the skill registry format`.
6. Run `git commit -S --signoff -m "<scoped Conventional Commit subject>"` from the repository root. Always explicitly request GPG signing and a `Signed-off-by` trailer, even if Git is configured to sign by default.
7. Run `git verify-commit HEAD` after the commit succeeds. Report completion only after signature verification succeeds. If verification fails, stop and report the failure.

Unsigned commits are NOT allowed. Never disable signing, use `--no-gpg-sign`, set `commit.gpgSign=false`, or fall back to a commit tool that cannot explicitly require signing. Any commit-producing operation, including an amend or merge, must explicitly request signing with `-S`, include `--signoff`, and have its resulting commit verified.

If signing fails or times out, leave the staged changes intact and ask the user to resolve the signing prompt or configuration before retrying with signing enabled. Wait for the user to touch their YubiKey when prompted.
