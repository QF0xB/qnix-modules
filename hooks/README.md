# Git Hooks

This directory contains git hooks that can be shared across the repository.

## Installation

To install the hooks, run:

```bash
./hooks/install.sh
```

This will create symlinks from `.git/hooks/` to the hooks in this directory.

## Available Hooks

### `pre-commit`

Runs before every commit:

- **Runs** `tools/update.sh` to regenerate:
  - `module-index.nix`
  - `MODULES.md`
  - `docs/options.md`
  - `docs/options.json`
  - `docs/options.txt`

- **Auto-stages** any regenerated files, shows a short summary, and asks for confirmation before proceeding.

Run AI/code review separately when you need it (e.g. before a release).

## Manual Installation

If you prefer to install hooks manually:

```bash
ln -s ../../hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

