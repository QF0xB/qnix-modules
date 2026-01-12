#!/usr/bin/env bash
set -euo pipefail

# Update all generated files: module-index.nix, MODULES.md, and documentation
# Usage: ./tools/update.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Updating generated files..."

git add .

# Regenerate module-index.nix and MODULES.md
echo "Regenerating module-index.nix and MODULES.md..."
nix-shell -p python3 --run "python3 '$REPO_ROOT/tools/module-update.py' --root '$REPO_ROOT'" || {
  echo "Error: Failed to regenerate module-index.nix and MODULES.md"
  exit 1
}

# Regenerate documentation
echo "Regenerating documentation..."
"$REPO_ROOT/tools/gen-docs.sh" || {
  echo "Error: Failed to regenerate documentation"
  exit 1
}

echo ""
echo "✓ All generated files updated successfully!"

