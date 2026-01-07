#!/usr/bin/env bash
set -euo pipefail

# Install git hooks from hooks/ directory to .git/hooks/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/hooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

cd "$REPO_ROOT"

if [ ! -d "$GIT_HOOKS_DIR" ]; then
  echo "Error: .git/hooks directory not found. Are you in a git repository?"
  exit 1
fi

# Install each hook from hooks/ directory (skip install.sh and README.md)
for hook in "$HOOKS_DIR"/*; do
  hook_name=$(basename "$hook")
  
  # Skip install script and README
  if [ "$hook_name" = "install.sh" ] || [ "$hook_name" = "README.md" ]; then
    continue
  fi
  
  if [ -f "$hook" ] && [ -x "$hook" ]; then
    target="$GIT_HOOKS_DIR/$hook_name"
    
    # Create symlink to the hook in the repository
    if [ -L "$target" ] || [ -f "$target" ]; then
      echo "Removing existing $hook_name hook..."
      rm -f "$target"
    fi
    
    echo "Installing $hook_name hook..."
    ln -s "../../hooks/$hook_name" "$target"
    chmod +x "$target"
  fi
done

echo ""
echo "✓ Git hooks installed successfully!"
echo "  Hooks are now symlinked from hooks/ to .git/hooks/"

