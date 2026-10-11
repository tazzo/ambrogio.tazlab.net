#!/bin/sh
# verify-word-agent.sh — the engine's own page, in service, measured on the bytes it serves.
#
# The claim: no sentence a reader reads, on either page the binary serves, calls the being a
# *hand* any more. The measurement is taken **from a running engine**, not from the source:
# the binary is built from this working tree, a second instance is started on a port of its
# own with a data directory of its own (the operator's hub is not touched), and the bytes it
# serves are counted.
#
# What is counted, per served file:
#   - every occurrence of the word `hand`/`hands`;
#   - of those, the ones used **for the being** — the rule is the one the rename was applied
#     with (`hand`/`hands` in front of a determiner, a number or an adjective of the being:
#     `a hand`, `the hands`, `no hand`, `the operator's hands`…). The idioms and the verbs are
#     not the being and they stay: `by hand`, `hand-written`, `hands it in`, `hands out` — and
#     so do the code's own identifiers (`const hand`, `handsOf`) and the wire value
#     `value="hand"`.
#
# Exit 0 when no occurrence for the being is left on either page; 1 otherwise.
set -u
REPO=/workspace/ambrogio
BIN=${TMPDIR:-/tmp}/ambrogio-word-agent
DATA=${TMPDIR:-/tmp}/ambrogio-word-agent-lab
PORT=7891
LOG=${TMPDIR:-/tmp}/ambrogio-word-agent-lab.log
fail=0

echo "== 1. the binary, built from this tree"
rm -rf "$DATA"; mkdir -p "$DATA"
if ( cd "$REPO" && go build -o "$BIN" ./v2/cmd/ambrogio ); then
  echo "built   $BIN ($(wc -c < "$BIN") bytes)"
else
  echo "FAIL: build"; exit 1
fi

echo "== 2. a second engine, serving the page"
"$BIN" -data "$DATA" -addr "127.0.0.1:$PORT" -queues 1 -tick 1h -log "$LOG" >/dev/null 2>&1 &
PID=$!
trap 'kill "$PID" 2>/dev/null' EXIT INT TERM
i=0
while [ "$i" -lt 40 ]; do
  if curl -s -o /dev/null --max-time 2 "http://127.0.0.1:$PORT/"; then break; fi
  i=$((i + 1)); sleep 0.25
done
if ! curl -s -o /dev/null --max-time 5 "http://127.0.0.1:$PORT/"; then
  echo "FAIL: the second engine never answered"; exit 1
fi
echo "serving http://127.0.0.1:$PORT/ (pid $PID)"

echo "== 3. the bytes it serves"
PORT="$PORT" python3 - <<'PY' || fail=1
import re, os, urllib.request
PORT = os.environ["PORT"]
DET = set("""a an the no every any each this that these those its his her their our your my
one two three four five six seven eight nine ten eleven twelve both several many all some another
more most few of whose which""".split()) | {str(i) for i in range(0, 200)}
ADJ = set("""first second third fourth fifth last next other free live dead silent parked mute new old
same only single bare stale stopped whole own second any external internal piloted""".split())
PAT = re.compile(r"(?i)\bhands?\b")
fail = 0
for u in ("/", "/ui", "/ui/app.js", "/ui/app.css"):
    body = urllib.request.urlopen(f"http://127.0.0.1:{PORT}{u}", timeout=10).read().decode("utf-8", "ignore")
    hits = list(PAT.finditer(body))
    being = 0
    for m in hits:
        if body[m.end():m.end()+1] == "-" or body[m.start()-1:m.start()] == "-":
            continue
        if m.group(0).endswith("'s"):
            being += 1; continue
        left = body[:m.start()]
        if re.search(r"(?i)\bon the other\s*$", left):
            continue
        if re.search(r"['\u2019]s\s*$", left):
            being += 1; continue
        toks = re.findall(r"[A-Za-z_][A-Za-z0-9_]*|\d+", left)
        i = len(toks) - 1
        if i >= 0 and toks[i].lower() in ADJ and toks[i].lower() not in ("first", "second", "other"):
            being += 1; continue
        while i >= 0 and toks[i].lower() in ADJ:
            i -= 1
        if i >= 0 and toks[i].lower() in DET:
            being += 1
    print(f"{u:14s} {len(body):7d} bytes   hand(s) total {len(hits):3d}   for the being {being}")
    if being:
        fail = 1
        for m in hits:
            print("      | " + " ".join(body[max(0, m.start()-70):m.end()+70].split()))
raise SystemExit(fail)
PY

echo "== 4. the sentences, as they are served"
for s in "an agent is on it" "an agent does not do this" "in progress, with an agent" "no agent at work"; do
  if curl -s --max-time 10 "http://127.0.0.1:$PORT/ui" | grep -q -F "$s" || \
     curl -s --max-time 10 "http://127.0.0.1:$PORT/" | grep -q -F "$s"; then
    echo "found   $s"
  else
    echo "absent  $s"
  fi
done

kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
[ "$fail" -eq 0 ] && echo "VERIFY-WORD-AGENT: OK" || echo "VERIFY-WORD-AGENT: the being is still called a hand"
exit "$fail"
