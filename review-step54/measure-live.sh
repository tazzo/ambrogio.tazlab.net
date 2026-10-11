#!/bin/sh
# measure-live.sh — one number, read from the live URL (https://ambrogio.tazlab.net/).
#
#   sh review-step54/measure-live.sh section  -> how many times the served first page carries
#                                                the exact string "Built in the lab it runs"
#   sh review-step54/measure-live.sh bytes    -> the served first page's byte count
#
# Always exits 0: a count of zero is a reading, not a failure.
case "${1:-section}" in
  section) curl -sS https://ambrogio.tazlab.net/ | grep -c -F 'Built in the lab it runs' || true ;;
  bytes)   curl -sS https://ambrogio.tazlab.net/ | wc -c | tr -d ' ' ;;
  *) echo "usage: measure-live.sh section|bytes" >&2; exit 2 ;;
esac
exit 0
