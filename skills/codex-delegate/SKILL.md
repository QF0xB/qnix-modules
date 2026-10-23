---
name: codex-delegate
description: Use when the user asks to hand work to Codex, wants a second opinion or review from Codex, or asks to save Claude usage on a self-contained task such as a bulk mechanical change, a focused investigation, or a code review. Runs Codex non-interactively on the ChatGPT subscription.
---

# Delegate to Codex

Codex runs on the user's ChatGPT subscription, so delegated work does not use Claude usage. Delegate self-contained tasks with a clear goal and a checkable result. Keep work that needs this conversation's context or design judgment.

## Review

Review uncommitted changes:

```bash
codex review --uncommitted "<focus, if any>"
```

Review the branch against its base with `--base <branch>` instead of `--uncommitted`.

## Task

```bash
out="$(mktemp)"
codex exec --ephemeral -s workspace-write -C "<repo>" -o "$out" "<task prompt>"
cat "$out"
```

- Write the prompt for a reader without this conversation's context: goal, files, constraints, and how to verify.
- Use `-s read-only` for investigations that must not edit files.
- Codex runs can take minutes. Run them in the background when other work can continue.
- Check the result before reporting it: read the diff with `git diff` and run the relevant checks. Codex's summary is not verification.

If Codex reports that it is not logged in, ask the user to run `codex login`. Do not retry with other credentials.
