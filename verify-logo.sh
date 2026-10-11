#!/bin/sh
# verify-logo.sh — the page's mark, from the icon set in the Ambrogio repository to the
# bytes on the live hostname.
#
#   1. site/logo.png is byte for byte android-chrome-512x512.png of ambrogio/v2/api/;
#   2. https://ambrogio.tazlab.net/logo.png serves those same bytes (size + sha256);
#   3. the stylesheet states the mark's drawn height;
#   4. the five pages carry the file's own 512x512 in the markup, and the favicon is
#      untouched (the tab's business, not the page's mark).
#
# Exit 0 when all of it holds; 1 otherwise.  Run from anywhere:
#   sh /workspace/ambrogio-site/verify-logo.sh
set -u

REPO=/workspace/ambrogio/v2/api/android-chrome-512x512.png
SITE=/workspace/ambrogio-site/ambrogio-site/site/logo.png
CSS=/workspace/ambrogio-site/ambrogio-site/site/styles.css
HTML=/workspace/ambrogio-site/ambrogio-site/site
FAVICON_SHA_OLD=b88644a59fa5dad99bf7aa9371ee52b8e2da5d24f1e6f31d45943500bf40377f
LIVE=https://ambrogio.tazlab.net/logo.png
fail=0

echo "== 1. the mark in the site, against the icon set in the Ambrogio repository"
for f in "$REPO" "$SITE"; do
  printf '%-58s %8s bytes  %s\n' "$f" "$(stat -c %s "$f")" "$(sha256sum "$f" | cut -d' ' -f1)"
done
if cmp -s "$REPO" "$SITE"; then
  echo "cmp            site/logo.png == v2/api/android-chrome-512x512.png  (byte for byte)"
else
  echo "cmp            DIFFER"; fail=1
fi

echo "== 2. the live URL"
tmp=$(mktemp)
meta=$(curl -sS --max-time 30 -o "$tmp" -w '%{http_code} %{content_type} %{size_download}' "$LIVE") || fail=1
echo "GET $LIVE -> $meta"
printf 'live bytes     %s\n' "$(stat -c %s "$tmp")"
printf 'live sha256    %s\n' "$(sha256sum "$tmp" | cut -d' ' -f1)"
if cmp -s "$tmp" "$SITE"; then
  echo "cmp            live bytes == site/logo.png  (byte for byte)"
else
  echo "cmp            DIFFER — the live hostname is not serving this file"; fail=1
fi
rm -f "$tmp"

echo "== 3. the drawn height the stylesheet states"
sed -n 's/^\.brand img *{.*width: *\([0-9]*\)px; *height: *\([0-9]*\)px.*$/\1/p' "$CSS" \
  | sed 's/^/logo drawn     /;s/$/ px tall (and as wide)/'

echo "== 4. the markup, and the favicon left alone"
n=$(grep -l 'src="logo.png" width="512" height="512"' "$HTML"/*.html | wc -l)
echo "pages          $n of 5 carry the file's own 512x512"
[ "$n" = 5 ] || fail=1
printf 'favicon.ico    %s bytes  %s\n' "$(stat -c %s "$HTML/favicon.ico")" \
  "$(sha256sum "$HTML/favicon.ico" | cut -d' ' -f1)"
[ "$(sha256sum "$HTML/favicon.ico" | cut -d' ' -f1)" = "$FAVICON_SHA_OLD" ] \
  && echo "favicon        unchanged (still the tab's favicon.ico)" \
  || { echo "favicon        CHANGED — this task must not touch it"; fail=1; }

[ "$fail" -eq 0 ] && echo "VERIFY-LOGO: OK" || echo "VERIFY-LOGO: FAILURES"
exit "$fail"
