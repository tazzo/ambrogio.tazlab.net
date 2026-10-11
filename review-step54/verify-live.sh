#!/bin/sh
# verify-live.sh — the acceptance of step #54, read from the live URL and not from the source:
# the served first page carries neither the heading "Built in the lab it runs" nor the three
# sentences that stood under it, and it still answers 200; the other four pages answer 200 and
# their bytes are the ones the deployment before this step served (digests measured 2026-10-11,
# before the push and again after the roll); the side menu still links to all five pages.
#
#   sh review-step54/verify-live.sh
#
# Exit 0 when all of it holds; 1 otherwise.  Run from anywhere; the hostname is fixed because
# the point of the check is the deployment that carries this tree.
BASE=https://ambrogio.tazlab.net
fail=0

echo "== the first page: the section gone, and 200 =="
tmp=$(mktemp)
code=$(curl -sS -o "$tmp" -w '%{http_code}' "$BASE/")
bytes=$(wc -c < "$tmp" | tr -d ' ')
printf '/                    %s  %s bytes\n' "$code" "$bytes"
[ "$code" = 200 ] || fail=1
for s in "Built in the lab it runs" \
         "A repository holds the desired state" \
         "This site is a description, not the product" \
         "not reachable from here"; do
  n=$(grep -c -F "$s" "$tmp" || true)
  printf '  contains %-45s %s\n' "\"$s\"" "$n"
  [ "$n" -eq 0 ] || fail=1
done

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
# the digests the live host served both before the push (23:47Z) and after the roll (23:52Z)
check_unchanged /queues.html       6056 bc874571808393504ddf06188a62bf153eebc66274b7577840c621511a90fe52
check_unchanged /doors.html        4799 d744585f6f8c86e5ffc56a64daed6e194e71609166e7f3762cd1910c279cacbf
check_unchanged /agents.html       5110 5758c7e6eed5b20e9d28d9fffae0a612cb9df6fa78b2123ef960c65374b342d7
check_unchanged /conversation.html 4548 077e668be17160988e2182b13b8fcb77773469fea48d51c1455c1d31bf826ca4

[ "$fail" -eq 0 ] && echo "VERIFY-LIVE: OK" || echo "VERIFY-LIVE: FAILURES"
exit "$fail"
