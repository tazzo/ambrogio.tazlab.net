#!/bin/sh
# measure-live.sh — one number, read from the live URL (https://ambrogio.tazlab.net/).
#
#   sh review-step52/measure-live.sh new   -> how many times the served page carries "Personal Agent Orchestrator"
#   sh review-step52/measure-live.sh old   -> how many times it carries the exact string "Agent orchestrator"
#
# Always exits 0: a count of zero is a reading, not a failure.
case "${1:-new}" in
  new) curl -sS https://ambrogio.tazlab.net/ | grep -c 'Personal Agent Orchestrator' || true ;;
  old) curl -sS https://ambrogio.tazlab.net/ | grep -c 'Agent orchestrator' || true ;;
  *) echo "usage: measure-live.sh new|old" >&2; exit 2 ;;
esac
exit 0
