#!/bin/sh
# verify-og.sh — the Open Graph block, on the five pages of this tree.
#
#   sh review-step53/verify-og.sh
#
# Each page must carry og:title, og:description and og:image (the three the assignment names)
# and og:url and og:type (the two the Open Graph protocol also requires); og:title must be the
# page's own <title> and og:description its own meta description, so each page has one source
# of truth; og:image must be the absolute URL of the 512x512 mark the header draws; and the
# pages must stay script-free.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SITE="$ROOT/ambrogio-site/site"
IMG="https://ambrogio.tazlab.net/logo.png"
fail=0
for f in index.html queues.html doors.html agents.html conversation.html; do
  p="$SITE/$f"
  title=$(sed -n 's|.*<title>\(.*\)</title>.*|\1|p' "$p")
  desc=$(sed -n 's|.*<meta name="description" content="\(.*\)">.*|\1|p' "$p")
  ot=$(sed -n 's|.*<meta property="og:title" content="\(.*\)">.*|\1|p' "$p")
  od=$(sed -n 's|.*<meta property="og:description" content="\(.*\)">.*|\1|p' "$p")
  oi=$(sed -n 's|.*<meta property="og:image" content="\(.*\)">.*|\1|p' "$p")
  ou=$(sed -n 's|.*<meta property="og:url" content="\(.*\)">.*|\1|p' "$p")
  oy=$(sed -n 's|.*<meta property="og:type" content="\(.*\)">.*|\1|p' "$p")
  sc=$(grep -c '<script' "$p")
  printf '%-20s og:title %s  og:description %s  og:image %s  og:url %s  og:type %s  scripts %s\n' \
    "$f" "$([ -n "$ot" ] && echo present || echo MISSING)" \
    "$([ -n "$od" ] && echo present || echo MISSING)" \
    "$([ -n "$oi" ] && echo present || echo MISSING)" \
    "$([ -n "$ou" ] && echo present || echo MISSING)" \
    "$([ -n "$oy" ] && echo present || echo MISSING)" "$sc"
  { [ -n "$ot" ] && [ -n "$od" ] && [ -n "$oi" ] && [ -n "$ou" ] && [ -n "$oy" ]; } || fail=1
  [ "$ot" = "$title" ] || { echo "  og:title is not the page's <title>"; fail=1; }
  [ "$od" = "$desc" ] || { echo "  og:description is not the page's meta description"; fail=1; }
  [ "$oi" = "$IMG" ] || { echo "  og:image is not $IMG"; fail=1; }
  [ "$sc" = 0 ] || { echo "  the page carries a <script>"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "VERIFY-OG: OK" || echo "VERIFY-OG: FAILURES"
exit "$fail"
