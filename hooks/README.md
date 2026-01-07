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

Automatically regenerates generated files when relevant source files change:

- **Triggers on changes to:**
  - Module files (`modules/`)
  - Documentation generation (`docs/generation/`)
  - `module-index.nix`
  - Generation tools (`tools/module-update.py`, `tools/gen-docs.sh`, `tools/update.sh`)

- **Regenerates:**
  - `module-index.nix`
  - `MODULES.md`
  - `docs/options.md`
  - `docs/options.json`
  - `docs/options.txt`

- **Auto-stages** any regenerated files that changed

## Manual Installation

If you prefer to install hooks manually:

```bash
ln -s ../../hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

