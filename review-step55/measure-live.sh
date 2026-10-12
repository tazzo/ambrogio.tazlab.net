#!/bin/sh
# measure-live.sh — the single numbers of step #55, read from the live URL.
#
#   sh review-step55/measure-live.sh personal     how many of the page's own sentences say it is
#                                                 personal / who it is for / what it does / what it
#                                                 keeps / the problem it removes  (11 of 11)
#   sh review-step55/measure-live.sh bytes        the first page's served bytes
#   sh review-step55/measure-live.sh digest       the first page's served sha256
#   sh review-step55/measure-live.sh deepdives    how many of the four deep dives are 200 and
#                                                 byte-identical to the pre-push reading (4 of 4)
BASE=https://ambrogio.tazlab.net
tmp=$(mktemp)
flat=$(mktemp)
curl -sS -o "$tmp" "$BASE/"
# the page is hand-wrapped: read the sentences against the page with its line breaks flattened
tr '\n' ' ' < "$tmp" | tr -s ' \t' ' ' > "$flat"
case "${1:-personal}" in
  personal)
    n=0
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
      c=$(grep -c -F "$s" "$flat" || true); [ "$c" -ge 1 ] && n=$((n + 1))
    done
    echo "$n" ;;
  bytes)  wc -c < "$tmp" | tr -d ' ' ;;
  digest) sha256sum "$tmp" | cut -d' ' -f1 ;;
  deepdives)
    n=0
    check() {
      t=$(mktemp)
      curl -sS -o "$t" "$BASE$1"
      [ "$(wc -c < "$t" | tr -d ' ')" = "$2" ] && [ "$(sha256sum "$t" | cut -d' ' -f1)" = "$3" ] && n=$((n + 1))
      rm -f "$t"
    }
    check /queues.html       6056 bc874571808393504ddf06188a62bf153eebc66274b7577840c621511a90fe52
    check /doors.html        4799 d744585f6f8c86e5ffc56a64daed6e194e71609166e7f3762cd1910c279cacbf
    check /agents.html       5110 5758c7e6eed5b20e9d28d9fffae0a612cb9df6fa78b2123ef960c65374b342d7
    check /conversation.html 4548 077e668be17160988e2182b13b8fcb77773469fea48d51c1455c1d31bf826ca4
    echo "$n" ;;
  *) echo "usage: measure-live.sh personal|bytes|digest|deepdives" >&2; exit 2 ;;
esac
rm -f "$tmp" "$flat"
