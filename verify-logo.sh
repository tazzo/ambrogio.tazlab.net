#!/bin/sh
# verify-logo.sh — the page's mark, from the icon set in the Ambrogio repository to the
# bytes on the live hostname.  The local, full check; the publish workflow runs the half
# of it a runner can run (`verify-logo-files.sh`, below), and never this live half —
# a check of the live URL tests the deployment before the one being published.
#
#   1. the file half, `verify-logo-files.sh`: site/logo.png is the pinned bytes and, on a
#      machine that has the sibling checkout, byte for byte the icon set's 512; the five
#      pages carry the file's own 512x512; the stylesheet states the drawn height; the
#      favicon is untouched;
#   2. the live URL serves those same bytes (size + sha256).
#
# Exit 0 when all of it holds; 1 otherwise.  Run from anywhere:
#   sh /workspace/ambrogio-site/verify-logo.sh
set -u

ROOT=$(cd "$(dirname "$0")" && pwd)
SITE="$ROOT/ambrogio-site/site/logo.png"
LIVE=https://ambrogio.tazlab.net/logo.png
fail=0

sh "$ROOT/verify-logo-files.sh" || fail=1

echo "== 5. the live URL"
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

[ "$fail" -eq 0 ] && echo "VERIFY-LOGO: OK" || echo "VERIFY-LOGO: FAILURES"
exit "$fail"
