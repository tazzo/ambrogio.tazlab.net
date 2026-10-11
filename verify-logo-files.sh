#!/bin/sh
# verify-logo-files.sh — the mark's file half: everything about the page's logo that this
# repository alone can prove.  No network, no sibling checkout: this is the half the
# publish workflow runs, where the runner carries this repository and nothing else.
#
#   1. site/logo.png is the pinned bytes (size + sha256), and — when the sibling checkout
#      of the Ambrogio repository is reachable — byte for byte its icon set's 512;
#   2. the five pages carry the file's own 512x512 in the markup;
#   3. the stylesheet states the mark's drawn height;
#   4. favicon.ico is the pinned file, untouched (the tab's business, not the page's mark).
#
# The digest is pinned here and not read from the Ambrogio repository's checkout, because
# the runner has this repository and nothing else; `verify-logo.sh` runs this half and adds
# the live URL.  Both numbers may be overridden for a one-off reading:
#
#   sh verify-logo-files.sh [expected-sha256] [expected-size]
#
# Exit 0 when all of it holds; 1 otherwise.  Run from anywhere; the tree is found from the
# script's own path, so a copy of the repository checks the copy.
set -u

ROOT=$(cd "$(dirname "$0")" && pwd)
SITE="$ROOT/ambrogio-site/site"
CSS="$SITE/styles.css"
REPO=/workspace/ambrogio/v2/api/android-chrome-512x512.png

# the icon set's 512 — ambrogio/v2/api/android-chrome-512x512.png, 121,589 B
EXPECTED_SIZE=${2:-121589}
EXPECTED_SHA=${1:-626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9}
# the tab's icon, the file this task must not touch — ambrogio/v2/api/favicon.ico
FAVICON_SIZE=15086
FAVICON_SHA=b88644a59fa5dad99bf7aa9371ee52b8e2da5d24f1e6f31d45943500bf40377f
# the height the stylesheet draws the mark at: the header's mark, not a favicon
EXPECTED_BOX=40
PAGES=5
fail=0

echo "== 1. the mark in the site"
if [ ! -f "$SITE/logo.png" ]; then
  echo "MISSING       ambrogio-site/site/logo.png"; fail=1
else
  got_size=$(stat -c %s "$SITE/logo.png")
  got_sha=$(sha256sum "$SITE/logo.png" | cut -d' ' -f1)
  printf 'site/logo.png  %s bytes  %s\n' "$got_size" "$got_sha"
  printf 'expected       %s bytes  %s\n' "$EXPECTED_SIZE" "$EXPECTED_SHA"
  [ "$got_size" = "$EXPECTED_SIZE" ] || { echo "SIZE MISMATCH  the page's mark is not the pinned file"; fail=1; }
  [ "$got_sha" = "$EXPECTED_SHA" ] || { echo "DIGEST MISMATCH  the page's mark is not the pinned file"; fail=1; }
fi
if [ -f "$REPO" ]; then
  printf 'icon set       %s bytes  %s\n' "$(stat -c %s "$REPO")" "$(sha256sum "$REPO" | cut -d' ' -f1)"
  cmp -s "$REPO" "$SITE/logo.png" \
    && echo "cmp            site/logo.png == ambrogio/v2/api/android-chrome-512x512.png  (byte for byte)" \
    || { echo "cmp            DIFFER — the site's mark and the icon set's file have parted"; fail=1; }
else
  echo "sibling        $REPO is not here (a runner carries this repository only): the pinned digest above is the whole check"
fi

echo "== 2. the markup, on the five pages"
n=$(grep -l 'src="logo.png" width="512" height="512"' "$SITE"/*.html 2>/dev/null | wc -l)
echo "pages          $n of $PAGES carry the file's own 512x512"
[ "$n" = "$PAGES" ] || fail=1

echo "== 3. the drawn height the stylesheet states"
box=$(sed -n 's/^\.brand img *{.*width: *\([0-9]*\)px; *height: *\([0-9]*\)px.*$/\1/p' "$CSS")
printf 'logo drawn     %s px tall (and as wide), expected %s\n' "${box:-none}" "$EXPECTED_BOX"
[ "$box" = "$EXPECTED_BOX" ] || { echo "BOX MISMATCH   the mark's own rule no longer states $EXPECTED_BOX px"; fail=1; }

echo "== 4. the favicon left alone"
if [ ! -f "$SITE/favicon.ico" ]; then
  echo "MISSING       ambrogio-site/site/favicon.ico"; fail=1
else
  got_fav_size=$(stat -c %s "$SITE/favicon.ico")
  got_fav_sha=$(sha256sum "$SITE/favicon.ico" | cut -d' ' -f1)
  printf 'favicon.ico    %s bytes  %s\n' "$got_fav_size" "$got_fav_sha"
  [ "$got_fav_size" = "$FAVICON_SIZE" ] && [ "$got_fav_sha" = "$FAVICON_SHA" ] \
    && echo "favicon        unchanged (still the tab's favicon.ico)" \
    || { echo "FAVICON CHANGED  the tab's icon is not the pinned file"; fail=1; }
fi

[ "$fail" -eq 0 ] && echo "VERIFY-LOGO-FILES: OK" || echo "VERIFY-LOGO-FILES: FAILURES"
exit "$fail"
