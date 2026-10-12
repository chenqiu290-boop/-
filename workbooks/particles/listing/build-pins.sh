#!/usr/bin/env bash
# Build the Pinterest pins (1000×1500): renders pages from the PDFs, then screenshots each pin of pins.html.
# Run ../build.sh first so the PDFs are up to date.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p pages pins
for p in 1 9; do
  pdftoppm -f $p -l $p -r 110 -png -singlefile ../particle-power-full.pdf pages/p$p
done
for p in 1 5 6; do
  pdftoppm -f $p -l $p -r 110 -png -singlefile ../particle-workbook-sample.pdf pages/s$p
done
CHROME="${CHROME:-$(command -v chromium || command -v google-chrome || echo /opt/pw-browsers/chromium-1194/chrome-linux/chrome)}"
for n in 1 2 3 4; do
  "$CHROME" --headless --no-sandbox --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --virtual-time-budget=5000 --window-size=1000,1700 --screenshot="$PWD/pins/pin-$n.png" "file://$PWD/pins.html#$n" 2>/dev/null
  # Headless Chrome's viewport is shorter than the window, so shoot taller and crop to the exact size.
  python3 -c "import sys; from PIL import Image; im = Image.open(sys.argv[1]); im.crop((0, 0, 1000, 1500)).save(sys.argv[1])" "pins/pin-$n.png"
  echo "Built pins/pin-$n.png"
done
