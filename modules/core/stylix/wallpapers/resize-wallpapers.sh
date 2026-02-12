#!/usr/bin/env bash
# Resize wallpapers to max 4K (3840x2160), only shrink. Keeps aspect ratio.
# Run: nix shell nixpkgs#imagemagick -c bash ./resize-wallpapers.sh
#
# Check current size:
#   ls -lh *.png              # file size (human-readable)
#   identify *.png             # dimensions + format (ImageMagick)
#   stat -c '%s %n' *.png      # file size in bytes

set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

MAX="3840x2160"   # only shrink if larger (>) than this
# Only resize 16:9-style wallpapers; leave ultrawide (e.g. solarized-dark-with-mountain) at full size for 32:9
RESIZE_ONLY="solarized-dark.png"

for f in $RESIZE_ONLY; do
  [ -f "$f" ] || continue
  echo "Resizing $f (max $MAX)..."
  magick "$f" -resize "${MAX}\>" -strip "tmp-$f" && mv "tmp-$f" "$f"
done

echo "Done. Check with: ls -lh *.png && identify *.png"
