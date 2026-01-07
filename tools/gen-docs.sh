#!/usr/bin/env bash
set -euo pipefail

# Generate documentation and copy to docs/ directory
# Usage: ./tools/gen-docs.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS_DIR="$REPO_ROOT/docs"

cd "$REPO_ROOT"

# Ensure docs directory exists
mkdir -p "$DOCS_DIR"

echo "Building documentation..."
nix build .#docs.markdown --impure -o docs-result-markdown
nix build .#docs.json --impure -o docs-result-json
nix build .#docs.ascii --impure -o docs-result-ascii

echo "Copying documentation to docs/ directory..."

# Remove existing read-only files if they exist
[ -f "$DOCS_DIR/options.md" ] && chmod u+w "$DOCS_DIR/options.md" && rm -f "$DOCS_DIR/options.md"
[ -f "$DOCS_DIR/options.json" ] && chmod u+w "$DOCS_DIR/options.json" && rm -f "$DOCS_DIR/options.json"
[ -f "$DOCS_DIR/options.txt" ] && chmod u+w "$DOCS_DIR/options.txt" && rm -f "$DOCS_DIR/options.txt"

# The build results are symlinks to the actual files or directories
# Copy the files directly (cat to avoid copying read-only permissions)
if [ -L docs-result-markdown ]; then
  MARKDOWN_SRC="$(readlink -f docs-result-markdown)"
  # Check if it's a directory or file
  if [ -d "$MARKDOWN_SRC" ]; then
    # Find the markdown file in the directory
    MARKDOWN_FILE=$(find "$MARKDOWN_SRC" -name "*.md" -type f | head -1)
    if [ -n "$MARKDOWN_FILE" ]; then
      cat "$MARKDOWN_FILE" > "$DOCS_DIR/options.md"
      echo "✓ Copied markdown to docs/options.md"
    else
      echo "Warning: Could not find .md file in $MARKDOWN_SRC"
    fi
  else
    cat "$MARKDOWN_SRC" > "$DOCS_DIR/options.md"
    echo "✓ Copied markdown to docs/options.md"
  fi
else
  echo "Warning: docs-result-markdown is not a symlink"
fi

if [ -L docs-result-json ]; then
  JSON_SRC="$(readlink -f docs-result-json)"
  # JSON is typically in a directory structure
  if [ -d "$JSON_SRC" ]; then
    # Find the JSON file (usually in share/doc/nixos/)
    JSON_FILE=$(find "$JSON_SRC" -name "*.json" -type f | grep -v "\.br$" | head -1)
    if [ -n "$JSON_FILE" ]; then
      cat "$JSON_FILE" > "$DOCS_DIR/options.json"
      echo "✓ Copied JSON to docs/options.json"
    else
      echo "Warning: Could not find .json file in $JSON_SRC"
    fi
  else
    cat "$JSON_SRC" > "$DOCS_DIR/options.json"
    echo "✓ Copied JSON to docs/options.json"
  fi
else
  echo "Warning: docs-result-json is not a symlink"
fi

if [ -L docs-result-ascii ]; then
  ASCII_SRC="$(readlink -f docs-result-ascii)"
  # Check if it's a directory or file
  if [ -d "$ASCII_SRC" ]; then
    # Find the ASCII file (could be .txt or .asciidoc)
    ASCII_FILE=$(find "$ASCII_SRC" -type f \( -name "*.txt" -o -name "*.asciidoc" \) | head -1)
    if [ -n "$ASCII_FILE" ]; then
      cat "$ASCII_FILE" > "$DOCS_DIR/options.txt"
      echo "✓ Copied ASCII to docs/options.txt"
    else
      echo "Warning: Could not find ASCII file in $ASCII_SRC"
    fi
  else
    cat "$ASCII_SRC" > "$DOCS_DIR/options.txt"
    echo "✓ Copied ASCII to docs/options.txt"
  fi
else
  echo "Warning: docs-result-ascii is not a symlink"
fi

# Clean up build results
rm -f docs-result-*

echo ""
echo "Documentation generated in docs/ directory:"
echo "  - docs/options.md (markdown)"
echo "  - docs/options.json (JSON)"
echo "  - docs/options.txt (ASCII)"

