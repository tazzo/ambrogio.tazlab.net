#!/bin/sh
# verify-acp.sh — step 61 (queue #61, worker-external).
#
# The question: does the site expand "ACP" to the protocol the engine actually
# speaks? The operator says the site is wrong (it should be "Agent Communication
# Protocol"). This script reads FOUR independent sources — the site's own text,
# the engine's source, the agent binary's own declaration, and the LIVE page —
# and exits non-zero if they do not all agree with the site.
#
# Run:  sh review-step61/verify-acp.sh
set -u

SITE=/workspace/ambrogio-site
ENGINE=/workspace/ambrogio
HOST=https://ambrogio.tazlab.net
rc=0

echo "== 1. the site's own text (source, with file:line) =="
grep -rn "Agent Client Protocol\|Agent Communication Protocol" \
  "$SITE/ambrogio-site/site" "$SITE/PROGETTO.md" "$SITE/AVANZAMENTO.md" "$SITE/RICERCA.md" || rc=1

echo
echo "== 2. what the engine's own source says the engine speaks =="
grep -rn -A1 "Agent Client$\|the Agent$" \
  "$ENGINE/README.md" "$ENGINE/v2/worker/acp.go" "$ENGINE/v2/acp/acp.go" || rc=1
echo "   (the transport prompt the engine hands every ACP agent:)"
grep -n "agent of Ambrogio speaking the Agent Client Protocol" \
  "$ENGINE/v2/worker/acp.go" || rc=1

echo
echo "== 3. what the agent process the dispatcher starts says it is (omp acp) =="
omp acp --help 2>&1 | grep -i "acp (" || rc=1
echo "   (what the dispatcher runs:)"
grep -n 'prog, args := d.Agent, \[\]string{"acp"}' "$ENGINE/v2/queue/dispatch.go" || rc=1

echo
echo "== 4. the LIVE page's spelling (not the source) =="
LIVE=$(curl -fsS "$HOST/") || rc=1
printf '   %s\n' "$(printf '%s' "$LIVE" | grep -o 'Agent [A-Za-z]* Protocol' | sort -u)"

echo
echo "== 5. the site answers 200 at its hostname, every page whole =="
for p in index queues doors agents conversation; do
  code=$(curl -fsS -o /dev/null -w '%{http_code}' "$HOST/$p.html") || rc=1
  printf '   %-14s %s\n' "$p.html" "$code"
  [ "$code" = "200" ] || rc=1
done

echo
echo "== verdict =="
if printf '%s' "$LIVE" | grep -q 'Agent Client Protocol'; then
  echo "   the LIVE page names the protocol 'Agent Client Protocol',"
  echo "   which is the protocol the engine speaks — the site is CORRECT, change nothing."
else
  echo "   MISMATCH: the live page does not name it 'Agent Client Protocol'." >&2
  rc=1
fi
exit $rc
