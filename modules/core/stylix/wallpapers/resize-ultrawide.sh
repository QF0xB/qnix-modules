#!/usr/bin/env bash
# Resize solarized-dark-with-mountain.png for 32:9 ultrawide (5120×1440).
# Run: nix shell nixpkgs#imagemagick -c bash ./resize-ultrawide.sh

set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# 32:9 = 5120×1440 (or 3840×1080)
UW="5120x1440"
F="solarized-dark-with-mountain.png"

[ -f "$F" ] || { echo "Missing $F"; exit 1; }
echo "Resizing $F for 32:9 (max $UW)..."
magick "$F" -resize "${UW}\>" -strip "tmp-$F" && mv "tmp-$F" "$F"
echo "Done. Check: ls -lh $F && identify $F"
