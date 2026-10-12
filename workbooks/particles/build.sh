#!/usr/bin/env bash
# Build the workbook PDF: downloads fonts (first run), then prints the HTML with headless Chromium.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p fonts
get() { [ -s "fonts/$1" ] || curl -sSfo "fonts/$1" "$2"; }
get Fraunces-600.ttf    "https://fonts.gstatic.com/s/fraunces/v38/6NUh8FyLNQOQZAnv9bYEvDiIdE9Ea92uemAk_WBq8U_9v0c2Wa0K7iN7hzFUPJH58nib1603gg7S2nfgRYIcaRyjDg.ttf"
get NotoSansJP-400.ttf  "https://fonts.gstatic.com/s/notosansjp/v57/-F6jfjtqLzI2JPCgQBnw7HFyzSD-AsregP8VFBEj75s.ttf"
get NotoSansJP-700.ttf  "https://fonts.gstatic.com/s/notosansjp/v57/-F6jfjtqLzI2JPCgQBnw7HFyzSD-AsregP8VFPYk75s.ttf"
get NotoSerifJP-700.ttf "https://fonts.gstatic.com/s/notoserifjp/v34/xn71YHs72GKoTvER4Gn3b5eMRtWGkp6o7MjQ2bzWPebA.ttf"
CHROME="${CHROME:-$(command -v chromium || command -v google-chrome || echo /opt/pw-browsers/chromium-1194/chrome-linux/chrome)}"
"$CHROME" --headless --no-sandbox --disable-gpu --no-pdf-header-footer \
  --run-all-compositor-stages-before-draw --virtual-time-budget=5000 \
  --print-to-pdf="particle-workbook-sample.pdf" "file://$PWD/workbook.html"
echo "Built particle-workbook-sample.pdf"
