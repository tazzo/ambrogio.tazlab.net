#!/bin/sh
# verify-live-og.sh — the Open Graph block, read from the live URL and not from the source.
#
#   sh review-step53/verify-live-og.sh
#
# For each of the five pages: 200, the five og: properties present, og:image the absolute URL
# of the mark; and the mark itself answers 200 with the pinned bytes (121,589 B /
# sha256 626654ac...), so og:image points at the 512x512 the header draws and not at a 404.
set -u
BASE=https://ambrogio.tazlab.net
SIZE=121589
SHA=626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
fail=0
for p in / /queues.html /doors.html /agents.html /conversation.html; do
  body=$(curl -sS -w '\n%{http_code}' "$BASE$p")
  code=$(printf '%s' "$body" | tail -n1)
  html=$(printf '%s' "$body" | sed '$d')
  n=$(printf '%s' "$html" | grep -c 'property="og:')
  img=$(printf '%s' "$html" | sed -n 's|.*<meta property="og:image" content="\(.*\)">.*|\1|p')
  printf '%-20s %s  og properties %s  og:image %s\n' "$p" "$code" "$n" "$img"
  [ "$code" = 200 ] || fail=1
  [ "$n" -ge 5 ] || fail=1
  [ "$img" = "$BASE/logo.png" ] || fail=1
done
tmp=$(mktemp)
got=$(curl -sS -o "$tmp" -w '%{http_code} %{size_download}' "$BASE/logo.png")
sha=$(sha256sum "$tmp" | cut -d' ' -f1)
rm -f "$tmp"
printf 'og:image target     %s  %s\n' "$got" "$sha"
[ "$got" = "200 $SIZE" ] || fail=1
[ "$sha" = "$SHA" ] || fail=1
[ "$fail" -eq 0 ] && echo "VERIFY-LIVE-OG: OK" || echo "VERIFY-LIVE-OG: FAILURES"
exit "$fail"
