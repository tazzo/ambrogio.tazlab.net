#!/bin/sh
# verify-live.sh — the acceptance, read from the live URL and not from the source: the five
# pages answer 200, each carries "Personal Agent Orchestrator", and none carries the exact
# string "Agent orchestrator" (the phrase this step replaced).
#
#   sh review-step52/verify-live.sh
#
# Exit 0 when all of it holds; 1 otherwise.  Run from anywhere; the hostname is fixed because
# the point of the check is the deployment that carries this tree.
BASE=https://ambrogio.tazlab.net
fail=0
for p in / /queues.html /doors.html /agents.html /conversation.html; do
  body=$(curl -sS -w '\n%{http_code}' "$BASE$p")
  code=$(printf '%s' "$body" | tail -n1)
  html=$(printf '%s' "$body" | sed '$d')
  new=$(printf '%s' "$html" | grep -c 'Personal Agent Orchestrator')
  old=$(printf '%s' "$html" | grep -c 'Agent orchestrator')
  printf '%-20s %s  Personal Agent Orchestrator %s  Agent orchestrator %s\n' "$p" "$code" "$new" "$old"
  [ "$code" = 200 ] || fail=1
  [ "$new" -ge 1 ] || fail=1
  [ "$old" -eq 0 ] || fail=1
done
[ "$fail" -eq 0 ] && echo "VERIFY-LIVE: OK" || echo "VERIFY-LIVE: FAILURES"
exit "$fail"
