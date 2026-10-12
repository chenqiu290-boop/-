#!/usr/bin/env bash
# Build the Gumroad store images: renders pages from the English PDF, then screenshots each slide of previews.html.
# Run ../build.sh first so the PDF is up to date.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p pages
for p in 1 2 9 10 14 16 31 32; do
  pdftoppm -f $p -l $p -r 110 -png -singlefile ../particle-power-full.pdf pages/p$p
done
pdftoppm -f 9 -l 9 -r 200 -png -singlefile ../particle-power-full.pdf pages/p9-big
CHROME="${CHROME:-$(command -v chromium || command -v google-chrome || echo /opt/pw-browsers/chromium-1194/chrome-linux/chrome)}"
shot() {
  "$CHROME" --headless --no-sandbox --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --virtual-time-budget=5000 --window-size="${3%,*},$(( ${3#*,} + 200 ))" --screenshot="$PWD/$2" "file://$PWD/previews.html#$1" 2>/dev/null
  # Headless Chrome's viewport is shorter than the window, so shoot taller and crop to the exact size.
  python3 -c "import sys; from PIL import Image; im = Image.open(sys.argv[1]); im.crop((0, 0, $3)).save(sys.argv[1])" "$2"
  echo "Built $2"
}
shot 1 preview-1-cover.png    1280,720
shot 2 preview-2-lessons.png  1280,720
shot 3 preview-3-tests.png    1280,720
shot 4 preview-4-contents.png 1280,720
shot 5 preview-5-closeup.png  1280,720
shot 6 thumbnail.png          600,600
