#!/bin/sh
# verify-live.sh — the acceptance of step #55, read from the live URL and not from the source:
# the served first page says plainly that the tool is personal, who it is for, what it
# orchestrates and what it keeps, and names the problem it removes; it still answers 200; the
# four deep dives answer 200 and their bytes are the ones the deployment before this step served
# (digests measured 2026-10-11, before the push and again after the roll); the side menu still
# links to all five pages.
#
#   sh review-step55/verify-live.sh
#
# Exit 0 when all of it holds; 1 otherwise.  Run from anywhere; the hostname is fixed because
# the point of the check is the deployment that carries this tree.
BASE=https://ambrogio.tazlab.net
fail=0

echo "== the first page: it is personal, for one person, and it says so =="
tmp=$(mktemp)
flat=$(mktemp)
code=$(curl -sS -o "$tmp" -w '%{http_code}' "$BASE/")
bytes=$(wc -c < "$tmp" | tr -d ' ')
printf '/                    %s  %s bytes\n' "$code" "$bytes"
[ "$code" = 200 ] || fail=1
# The page is hand-wrapped: a sentence may be split across two source lines.  The strings below
# are quoted from the page, so they are read against the page with its line breaks flattened to
# single spaces — the sentence as a reader sees it, not as the source wraps it.
tr '\n' ' ' < "$tmp" | tr -s ' \t' ' ' > "$flat"
for s in "It is a personal tool." \
         "one static Go binary beside one SQLite file" \
         "no server to install, no database to run, no infrastructure, no team" \
         "One person, or a small team, is the most it is made for." \
         "What it does is orchestration" \
         "several agents working at the same time on the same things" \
         "What it keeps is the trace" \
         "the work of other tools, and the work of the agents Ambrogio spawns for itself" \
         "That is the problem it removes." \
         "many terminals open at once, documents written here and there" \
         "It is not a professional product." ; do
  n=$(grep -c -F "$s" "$flat" || true)
  printf '  says %-72s %s\n' "\"$s\"" "$n"
  [ "$n" -ge 1 ] || fail=1
done
# the description, and the share card that copies it, name it personal too (two occurrences on
# the flattened page: the file is one line after flattening, so count matches, not lines)
n=$(grep -o -F 'content="Ambrogio is a personal tool:' "$flat" | wc -l | tr -d ' ')
printf '  %-78s %s\n' 'description and og:description say "a personal tool"' "$n"
[ "$n" -eq 2 ] || fail=1
rm -f "$flat"

echo "== the side menu, on the first page =="
for h in index.html queues.html doors.html agents.html conversation.html; do
  n=$(grep -c -F "href=\"$h\"" "$tmp" || true)
  printf '  links to %-20s %s\n' "$h" "$n"
  [ "$n" -ge 1 ] || fail=1
done
rm -f "$tmp"

echo "== the four deep dives: 200, and unchanged since before this step =="
check_unchanged() {
  p="$1"; want_bytes="$2"; want_sha="$3"
  t=$(mktemp)
  c=$(curl -sS -o "$t" -w '%{http_code}' "$BASE$p")
  b=$(wc -c < "$t" | tr -d ' ')
  s=$(sha256sum "$t" | cut -d' ' -f1)
  rm -f "$t"
  ok=yes
  [ "$c" = 200 ] || ok=no
  [ "$b" = "$want_bytes" ] || ok=no
  [ "$s" = "$want_sha" ] || ok=no
  printf '%-20s %s  %s bytes  %s  unchanged=%s\n' "$p" "$c" "$b" "$s" "$ok"
  [ "$ok" = yes ] || fail=1
}
# the digests the live host served before the push (2026-10-11T23:57Z, review-step55/live-before.txt)
check_unchanged /queues.html       6056 bc874571808393504ddf06188a62bf153eebc66274b7577840c621511a90fe52
check_unchanged /doors.html        4799 d744585f6f8c86e5ffc56a64daed6e194e71609166e7f3762cd1910c279cacbf
check_unchanged /agents.html       5110 5758c7e6eed5b20e9d28d9fffae0a612cb9df6fa78b2123ef960c65374b342d7
check_unchanged /conversation.html 4548 077e668be17160988e2182b13b8fcb77773469fea48d51c1455c1d31bf826ca4

[ "$fail" -eq 0 ] && echo "VERIFY-LIVE: OK" || echo "VERIFY-LIVE: FAILURES"
exit "$fail"
