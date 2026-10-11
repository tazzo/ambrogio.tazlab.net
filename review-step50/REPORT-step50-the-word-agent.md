# step #50 — the word "hand" goes: the being is called an **agent**

The operator's decision (2026-10-11, filed twice): *«non bisogna dire "le mani", dobbiamo
usare o "gli agenti" o "i worker". "Le mani" non mi piace»*, then *«cambiare hands con workers
o agents, forse meglio agents»*. The word for the being is **agent**. **worker** stays where it
names the **role** (`worker-external`, `worker-internal`, the lane, `lane_cap:<lane>`), because
there the word says something exact and the role's own names are identifiers. The Go
identifiers (`store.Hand`, `Hands`, `handForPID`, `CauseHandExited`) and the code's comments are
**not** renamed: they are not what the operator reads.

A sentence a test pins moved with its test, in the same change (the tests below).

## 1. The site — `hands.html` is `agents.html`

Repository `/workspace/ambrogio-site`, committed and pushed (`2c04afc..b0ff6ff`, `main`):

| file | what changed |
|---|---|
| `ambrogio-site/site/hands.html` → **`agents.html`** | `git mv`; title, menu entry and eyebrow say *The agents*; `<h1>` and the meta description too; "A hand is a live run" → "An agent is a live run"; "The free hand" → "The free agent" |
| `ambrogio-site/site/{index,queues,doors,conversation}.html` | the menu link `href="hands.html"` → `agents.html` (all four); the card on the main page: *The agents, the budget and the silence* |
| `PROGETTO.md`, `AVANZAMENTO.md`, `README.md`, `ambrogio-site/README.md` | the page set, the deep-dive list, the tree listing, `*run*/*agent*`, `*free agent*` |
| `verify-lane.sh`, `verify-project.sh` | the two checks that curl/grep the page set name `agents.html` |

`sh verify-project.sh --in-repo` → `checked 8 citations, 0 missing`, exit 0;
`sh verify-logo-files.sh` → `VERIFY-LOGO-FILES: OK`, exit 0 — the two checks the publish workflow
runs before it touches the registry, so the push is publishable.

**The push is the lane** (Actions builds `tazzo/tazlab-ambrogio-site:ambrogio-site-<run>-<sha>`,
Flux's ImagePolicy picks it, ImageUpdateAutomation commits the tag, Flux deploys — intervals 1 m).
Readings at ~23:29Z, minutes after the push: `/` 200, `queues/doors/conversation` 200,
`/agents.html` **404** and `/hands.html` 200 — the deployment had not landed yet. **At ~23:36Z it
had**: `curl -s -o /dev/null -w '%{http_code} %{size_download}' https://ambrogio.tazlab.net/agents.html`
prints **`200 4643`** and the same call on `/hands.html` prints **`404 153`** — the new name is
served, the old one is gone, and every live page
(`/`, `/queues.html`, `/doors.html`, `/conversation.html`) carries `href="agents.html"` exactly
once. Both readings are in `live-site-check.txt`.

## 2. The engine's own page, in service — `sh review-step50/verify-word-agent.sh` → **OK**

The script builds the binary from this tree, starts a **second** engine on `:7891` with a data
directory of its own (the operator's hub is not touched), and counts the bytes it serves:

```
/               213047 bytes   hand(s) total  21   for the being 0
/ui              85607 bytes   hand(s) total   8   for the being 0
/ui/app.js      160419 bytes   hand(s) total  14   for the being 0
/ui/app.css      35908 bytes   hand(s) total   1   for the being 0
found   an agent is on it
found   in progress, with an agent
found   no agent at work
VERIFY-WORD-AGENT: OK
```

The census applies the same rule the rename was applied with (a determiner, a number or an
adjective of the being in front of the word). What remains is **not the being**: `by hand`,
`hand-written`, `drawn by hand`, `typed by hand`, `in hand`, `on the other hand` (idioms), `hands
it in`, `hands out`, `hands back`, `hands a place` (the verb), the identifiers `const hand` /
`const hands` / `handsOf` and the **wire value** `<option value="hand">` — the last one is an API
value meaning "this needs write+bash" (`v2/api/api.go:445` maps it to `write`), it is not a word
for the being, and renaming it would break a page older than the change (the same aliasing the
stop body keeps).

## 3. The engine's sentences, and the tests that pinned them

Sources: `v2/api/**` (every string a reader sees, `page.html`, `ui/index.html`, `ui/app.js`,
`ui/app.css`), `v2/queue/*.go`, `v2/store/*.go`, plus the prompt sentences an agent reads about
itself (`v2/task/prompt.go`, `v2/runner/runner.go`). Examples of the sentences that moved:

- `v2/api/wall.go`: `"…this caller is the hand of run %d (task %d, role %s): a hand does not do
  this. Ask the operator"` → **`"…this caller is the agent of run %d …: an agent does not do this.
  Ask the operator"`**;
- `v2/api/api.go`: `"in progress, with a hand"` → `"in progress, with an agent"`;
- `v2/api/page.html` / `ui/app.js`: `"? \"a hand is on it: the answer will land here\""` → `"an
  agent is on it"`; `"? \"no hand is at work on any queue\""` → `"no agent is at work on any
  queue"`; the Workers-table wording (*"beside a list of hands; here they belong to the queue the
  agent is on"*);
- `v2/store/run.go`, `deliver.go`, `stop.go`, `book.go`: the refusals and event lines;
- `v2/task/prompt.go`: `"\n## You are not the first hand on this task\n\n"` → **`"\n## You are not
  the first agent on this task\n\n"`**, and the prompt's own *"a hand that changes files"* →
  *"an agent that changes files"*.

The tests that pinned a sentence moved in the same change (same rule, applied to test literals
too): `v2/api/{wall,stop_run,tick,page,ui_board,ui_conversations,ui_sign,ui_restart,waiting,
runs_silence,machine,logs}_test.go`, `v2/queue/{announce,budget,conversation,stopped_run}_test.go`,
`v2/store/{conversation,propose,stop_lane,run_history}_test.go`, `v2/engine/*_test.go`,
`v2/runner/*_test.go`, `v2/worker/*_test.go`, `v2/worktree/*_test.go`.

**The page copies the panel probe measures** were refreshed with the repo's own tool, because
`page.html` changed: `python3 v2/api/panel_probe/pages.py --refresh` wrote `page.copy.html` and
`page.copy.2026-10-11.html` (215531 B, sha256 `e53abc47e008…`) and the three rows of
`v2/api/panel_probe/README.md` were taken again to the same bytes.

**What I ran, and what it printed** (all from `/workspace/ambrogio`):

```
$ go build ./...                                          # clean
$ gofmt -l v2/                                            # only two files, both unformatted at HEAD
$ go test ./v2/api/ -count=1                              # ok  52.775s   (whole package, browser probes included)
$ go test -count=1 ./v2/task/ ./v2/store/ ./v2/queue/ ./v2/engine/ ./v2/worker/ \
    ./v2/worktree/ ./v2/review/ ./v2/acp/                 # ok  (task 0.056s, store 8.695s, queue 20.046s,
                                                          #      engine 6.157s, worker 11.959s, worktree 2.068s,
                                                          #      review 0.008s, acp 1.004s)
$ go test ./v2/runner/ -count=1                           # FAIL — three gate tests, and the cause is NOT this change
```

**`v2/runner`'s three failures are pre-existing, and here is the proof.** They are
`TestTheGateRefusesATreeThatDoesNotCompile`, `TestTheGateLetsACompilingTreeThrough` and
`TestTheGateLetsAWriterThroughWhenTheKeyIsDeclared`, and they fail because the tree's own logx
vocabulary is red:

```
$ cd /workspace/ambrogio/v2/queue && sed -n '479p' carry.go   # logx.F("step", next.ID)
$ go test ./logx/ -run TestEveryFieldAWriterUsesIsDeclared -count=1
    --- FAIL: TestEveryFieldAWriterUsesIsDeclared
        vocabulary_test.go:289: the writer at v2/queue/carry.go:479 logs the key "step",
        which logx.FieldKeys does not declare.
$ git worktree add -f /tmp/head-check HEAD      # a clean checkout of c2a14a5a, before this work
$ go test ./logx/ -run TestEveryFieldAWriterUsesIsDeclared -count=1     # the SAME failure
$ go test ./v2/runner/ -run 'TestTheGateRefusesATreeThatDoesNotCompile|...' -count=1
    # the same three failures at HEAD and in this tree, line for line
```

So the runner gate is red on the trunk for an undeclared log key, and this rename did not touch
it. It is declared as a child below, because a tree whose gate is red refuses every delivery that
touches the log writers.

## 4. The documents

- renamed: `/workspace/ambrogio/VOCABULARY.md` — the row is now `**agent**`, and **decision 5**
  is rewritten: what changed (the site, the page, the engine's sentences, and the tests that
  pinned them) and what did not (the role's `worker`, the Go identifiers, the code's comments) —
  it is the document that used to *decide* the word, so it had to move with the word;
- renamed: `/workspace/ambrogio/README.md` (*"without two agents in one place"*, *"carried by an
  external agent"*, *"an agent is refused them"*);
- renamed: `/workspace/ambrogio/projects/web-ui/{PROGETTO,RICERCA,BUILD,TEST}*.md` — the design
  documents (28 replacements);
- **left as they are, and named here with their reason**: the **records** — `projects/web-ui/REPORT-*.md`
  and `projects/web-ui/AVANZAMENTO.md` (its chronicle table quotes what the engine said on the day),
  `projects/web-ui/evidence/**` (raw command output, `.log`s, probe scripts, JSON readings),
  `ambrogio-site/review-step47/`, `review-step49/`, `v2/api/panel_probe/page.copy.<date>.html`
  (frozen dated samples), and the engine's own `REPORT-*.md`s. Rewriting a record of what a command
  printed is making the record lie: those files say the word that was in force when they were
  written, and the dated copies above them are history by construction.
- the code's **comments** (≈1,100 occurrences in `v2/**/*.go`) are left for the round that renames
  the code's own vocabulary — the task excludes it, and it is declared as a child.

## 5. What the delivery departs from

Two departures, both declared in the delivery's `deviation`: the engine's `README.md` and
`VOCABULARY.md` are outside the four places the task named (they are the engine's own root
documents) and were changed anyway, because `VOCABULARY.md` is where the word was *decided* and
leaving it would leave the decision contradicting the delivered rename; and the live site's
reading could not be taken as a 200 (`agents.html` was still 404 at delivery — the publish lane
was still propagating).

## 6. Children this work revealed

1. **`the tree's logx vocabulary is red: `step` at `v2/queue/carry.go:479` is undeclared`** (work) —
   the gate refuses every delivery that touches the log writers, and it is red on the trunk today.
2. **`the code's own vocabulary: the Go identifiers and comments that still say hand`** (work) —
   `store.Hand`, `Hands`, `handForPID`, `CauseHandExited` and ≈1,100 comment occurrences, which
   this task excludes on purpose.
