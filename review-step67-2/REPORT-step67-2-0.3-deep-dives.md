# Step #67/2 — the three deep dives carry Ambrogio 0.3

**Queue #67, second task, role worker-external.** Tree: the worktree
`/workspace/ambrogio/scratch/lab/wt/q67` of `https://github.com/tazzo/ambrogio.tazlab.net.git`,
branch `q67/ambrogio-site`. The first task of the queue is `review-step67/`.

## What the step asked (the order, 2026-10-14, verbatim)

> ambrogio-site/site/index.html:43-46 now says a queue owns a branch and a working directory of
> its own, that the engine lands the work itself (a push, and a pull request), and that every
> agent works inside a cage. The deep dives do not carry them: queues.html:45 still opens «It is
> not a list of messages and not a git branch», queues.html:97 still says «The engine does not
> build and does not merge», doors.html gives the sandbox to the worker alone, agents.html names
> no cage. Read the engine's own source before writing, then bring each of the four pages to
> what 0.3 is, in its own words. Do not restyle the site and do not touch index.html.

Acceptance, as stated:

| the order asks | the answer |
|---|---|
| `queues.html` — what a queue owns in 0.3, and what the engine now does with the work | done |
| `doors.html` — every agent, not only every worker, runs inside the cage | done |
| `agents.html` — the agent's work happens inside the cage | done |
| `conversation.html` — whatever 0.3 changed for a queue of kind conversation, or nothing | **nothing**, and said out loud (§Open questions) |

## The one thing this step could not do: read the engine's own source

The order says *read the engine's own source before writing*. **It is not readable from this
cage**, and that is a fact worth the record:

```
$ head -c 200 /workspace/ambrogio/README.md            → Permission denied
$ head -c 200 /workspace/ambrogio/VOCABULARY.md        → Permission denied
$ head -c 200 /workspace/ambrogio/v2/worktree/worktree.go   → Permission denied
$ head -c 200 /workspace/ambrogio/v2/cmd/sandbox/main.go    → Permission denied
$ head -c 200 /workspace/ambrogio/go.sum               → Permission denied
$ ls /workspace/ambrogio                               → cannot open directory: Permission denied
$ git ls-remote https://github.com/tazzo/ambrogio.git  → remote: Invalid username or token.
```

Every file *under* `/workspace/ambrogio` can be `stat`ed and none can be read; the directory
cannot be listed; the repository is private on the wire. There is no second copy in this cage
(`/workspace` itself cannot be listed; there is no engine checkout anywhere reachable).

**So the pages were written from the account that *is* on the record** — the first page's line
(`index.html:43-46`, from the order, 2026-10-14) and the order's own words — and **no mechanism
beyond those three changes is claimed anywhere**. Where a page had to say something the record
does not fix, it says it in the site's own established vocabulary and *stops*; the three places
that needed a decision are named in §"The three judgement calls" below. §Open questions of
`AVANZAMENTO.md` carries the caution for the next step: a step that can read
`ambrogio/README.md` §2/§4/§7 and `v2/` should read it and correct the pages if they say more
than it does.

## What changed, page by page

**`ambrogio-site/site/queues.html`** — the queue's own branch and working directory, and the
landing:

- `:45-48` — the opening no longer denies: *«The queue is the unit of work. It is not a list of
  messages: it is the container that carries one request from the moment it is accepted to the
  moment it closes, and **it owns the branch and the working directory its steps are written
  in**. It has exactly these parts.»* (`and not a git branch` is gone);
- `:57-59` — a part of its own, between the chain of steps and the session: *«**A branch, and a
  working directory** — the queue's own two: the steps are written there, and two queues at work
  at the same time do not write in one another's tree.»*;
- `:100-104` — a new section, **What the engine does with the work**: *«The queue's branch is
  not left where it was written. When the chain closes, the engine **lands the work**: it pushes
  the branch and opens a **pull request**, so what leaves the queue is the branch itself, with
  the request that carries it out to be read.»*;
- `:107-111` — **What the engine does not do** keeps the honest edge (no build, no tests, no
  judgement of prose; the review checks declarations and documents) and **drops the two claims
  0.3 supersedes**: the page no longer says the engine *does not merge*, nor that *the merge is
  the worker's act*. It now says what the engine does — the push, and the pull request — and
  asserts nothing about where the merge happens, because nothing available here says it;
- `:7,9` — `meta description` and `og:description`, one text as step #53 left them, gained the
  branch and the landing.

**`ambrogio-site/site/doors.html`** — every agent, not only every worker:

- `:40-42` — the lead: *«the engine serves two doors, and every agent it starts is caged before
  it runs — not only the workers»*;
- `:59-62` — the sandbox opens on *«**Every agent the engine starts** goes through a launcher
  that applies a **Landlock** policy to itself and then `exec`s the target… a live **agent**
  shows `NoNewPrivs=1`»*;
- `:81-84` — the declared limit is told of agents: *«The policy does not give a caged **agent**
  what the Go toolchain needs… A caged **agent** therefore cannot build the project… That is a
  declared limit, not a hidden one.»*;
- `:7,9` — `meta description` / `og:description`: *every agent started inside a per-role Landlock
  sandbox* (was *every worker*).

**`ambrogio-site/site/agents.html`** — the cage, where the agent is:

- `:49-55` — a new section, **The agent works inside the cage**: *«Every agent the engine starts
  works inside the **cage** — and not only the workers that carry a step. A launcher applies the
  **per-role** policy to itself and then `exec`s the target, so the run *is* the caged process:
  what the agent may touch is the allow-list and nothing else. [The two doors](doors.html) have
  the sandbox in full; what matters here is that the agent's work happens in there.»*

**`ambrogio-site/site/conversation.html`** — **untouched**, and that is the answer the order's
fourth line allows. The reason is on the record in `AVANZAMENTO.md` §Open questions: none of
0.3's three changes names a conversation, and the page already sends the reader on — *«Everything
else — the steps, the session, the ceiling, the trace — is the machinery the rest of the site
describes»* (`:60-62`) — so a conversation inherits whatever the queues page says a queue is.

**`ambrogio-site/site/index.html` and `ambrogio-site/site/styles.css`** — **untouched**, as the
order requires (`git diff --name-only HEAD` lists neither).

### The three judgement calls

1. **The merge.** The old `queues.html` claimed two things about merging (the engine does not
   merge; the merge is the worker's act). 0.3's landing — a push and a pull request — supersedes
   the second and leaves the first unsupported from here, so **both went** and the page now
   states the landing and nothing about the merge. It is a deletion of two claims, not an
   addition of a new one; the honest edge that matters (no build, no tests, no prose) stayed.
2. **The workaround for the declared limit.** `doors.html` used to close that section with
   *«the workaround is a worker outside the cage, on purpose, for that step»*. With every agent
   caged that clause contradicted the sentence above it, and no available source says what the
   workaround now is, so **the clause went and the limit stayed**. Recorded as an open question.
3. **The conversation.** Silence, for the reason given above; the order allows it in so many
   words, and inventing a branch for a chat would have been the one thing this step could not
   support.

## What was verified

### 1. The step's own check — `review-step67-2/verify-0.3-deep-dives.sh`

```
$ sh review-step67-2/verify-0.3-deep-dives.sh
ok    index.html still carries the 0.3 line once, and is otherwise the page it was
ok    conversation.html is the page it was (nothing in 0.3 names a queue of kind conversation)
ok    queues.html says a queue owns a branch and a working directory of its own
ok    queues.html lists the branch and the working directory among the queue's parts
ok    queues.html no longer opens by denying the queue is a git branch
ok    queues.html has a section on what the engine does with the work
ok    queues.html says the engine lands the work: it pushes the branch and opens a pull request
ok    queues.html no longer claims the engine does not merge, or that the merge is the worker's act
ok    queues.html keeps the honest edge: no build, no tests, no judgement of prose
ok    doors.html's lead: every agent the engine starts is caged, not only the workers
ok    doors.html's sandbox opens on every agent the engine starts
ok    doors.html no longer says 'every worker' anywhere (the cage is not the workers' alone)
ok    doors.html no longer names a workaround outside the cage (0.3 cages every agent)
ok    doors.html keeps the declared limit, told of agents
ok    agents.html has the cage's own section
ok    agents.html says every agent the engine starts works inside the cage
ok    agents.html says it is not the workers' cage alone
ok    agents.html says where the agent's work happens
…  (60 more: per page, one h1 / one main, no <script>, meta == og:description, the mark
    512×512, every internal link resolves to a file, no tabs)
-- pages: 5; the three deep dives changed, index.html and conversation.html did not
VERIFY-0.3-DEEP-DIVES: OK
rc=0   (78 `ok` lines)
```

The script reads the markup with `html.parser`: the prose checks run on the *text of the
paragraphs* (tags stripped), so say `works inside the <strong>cage</strong>` and it still reads
the sentence; the structural checks read the markup. **It refuses the pages as published** —
copies from `git show HEAD:` in a two-directory stand-in the script's own `ROOT` derivation
takes:

```
$ sh …/pretend-dives/review-step67-2/verify-0.3-deep-dives.sh
rc=1   15 FAIL
VERIFY-0.3-DEEP-DIVES: FAILURES
```

### 2. The publish lane's own two checks

```
$ sh verify-project.sh --in-repo
verify-project: checked 8 citations, 0 missing          (24 citations live in sibling trees)   rc=0
$ sed 's#^REPO=/workspace/…/android-chrome-512x512.png$#REPO=/nonexistent/sibling-checkout/…#' \
      verify-logo-files.sh > ./.verify-logo-runner-mode.sh && sh ./.verify-logo-runner-mode.sh
site/logo.png 121589 bytes 626654ac…; pages  5 of 5 carry the file's own 512x512;
logo drawn 40 px; favicon unchanged            VERIFY-LOGO-FILES: OK   rc=0
```

The `verify-logo-files.sh` substitution is the same one `review-step67/REPORT-step67-ambrogio-0.3.md`
§2 explains: this cage has the sibling checkout and refuses to read it, so the script's
byte-compare branch — which a runner never takes — fires here; repointing that one constant at a
path that does not exist reproduces the runner's branch and nothing else changes.

### 3. No other file moved

```
$ git diff --name-only HEAD
AVANZAMENTO.md
PROGETTO.md
ambrogio-site/site/agents.html
ambrogio-site/site/doors.html
ambrogio-site/site/queues.html
```

`styles.css` is not touched (the order says not to restyle), `index.html` is not touched, and
`PROGETTO.md` §3.4/§4 are the design's own record of the pages, kept true: its three bullets for
the three pages (the queue's branch and working directory; the landing; the sandbox for every
agent; the declared limit told of agents) moved with them.

### 4. The live hostname still serves the pages this step replaced

```
$ curl -sS -o review-step67-2/live-queues.html -w '/queues.html -> %{http_code} %{size_download}\n' \
        https://ambrogio.tazlab.net/queues.html
/queues.html -> 200 6056 bytes        (also /, /doors.html 200 4799, /agents.html 200 5110, /conversation.html 200 4548)
$ grep -c 'not a git branch' review-step67-2/live-queues.html            → 1
$ grep -c 'does not build and does not merge' review-step67-2/live-queues.html → 1
$ grep -c 'every worker' review-step67-2/live-doors.html                 → 3
$ cmp review-step67-2/live-<page>.html review-step67-2/at-HEAD-<page>.html
  /queues.html, /doors.html, /agents.html, /conversation.html  live == the tree at HEAD (pre-0.3)
```

### 5. What could not be done here — the pages were not rendered

**This cage carries no renderer.** Chromium is installed and executable but dies in the policy
(`FATAL:sandbox/linux/services/proc_util.cc:38] Check failed: . : Permission denied (13)`), the
transport offers no browser bridge (`browser.open` → *the tool bridge is unavailable in this
kernel*), no second renderer (`lynx`, `w3m`, `wkhtmltoimage`, `weasyprint`) is installed, and no
local socket can be opened (`bind`/`connect` on `127.0.0.1` → `Permission denied`), so the pages
could not even be served and fetched. **No screenshot exists, and none is claimed.** The writing
is checked as the documents nginx will serve — the exact sentences, in well-formed markup, on
pages whose skeleton, links and metadata the script re-reads — and the visual reading stays
where PROGETTO §7 puts it: the live hostname, after the lane carries the change.

## Reproduction

```
sh review-step67-2/verify-0.3-deep-dives.sh                    # OK, rc 0 — the three pages say it
git diff --name-only HEAD                                      # the three pages and the two documents
sh verify-project.sh --in-repo                                 # checked 8 citations, 0 missing
sed 's#^REPO=/workspace/ambrogio/v2/api/android-chrome-512x512.png$#REPO=/nonexistent/sibling-checkout/android-chrome-512x512.png#' \
    verify-logo-files.sh > ./.verify-logo-runner-mode.sh && sh ./.verify-logo-runner-mode.sh
rm -f ./.verify-logo-runner-mode.sh
```

Every one of them, with what it printed, is `review-step67-2/checks.log`; the hostname readings of
`2026-10-14T22:18:02Z` are `review-step67-2/live-before.txt`, with the five pages as served beside
it (`live-*.html`, `at-HEAD-*.html`, `index-pre-0.3.html`) for the `cmp`s.

## What this reveals

1. **The engine's source has to be read where it can be read.** The three pages state 0.3 in the
   order's words and claim nothing more; a step that can read `ambrogio/README.md` §2/§4/§7 and
   `v2/worktree/`, `v2/cmd/sandbox` should check them against it. In this queue that means a
   role other than a caged external worker, or the operator's own machine.
2. **The publish is the engine's, not a worker's.** This cage has no credentials (`git push
   --dry-run` → *Invalid username or token*), so no step of this queue can push; the lane does it
   when the work is merged, exactly as `AVANZAMENTO.md` §Next states with the readings to take.
3. **Two questions are for the operator**, both in `AVANZAMENTO.md` §Open questions: what the
   workaround for the caged-agent build limit now is (one sentence, if he wants it on
   `doors.html`), and whether 0.3 changed anything for a queue of kind `conversation`.

## The tree this task leaves

```
ambrogio-site/site/queues.html   the branch and the working directory, the landing     (4 edits)
ambrogio-site/site/doors.html    every agent, not only every worker                    (2 edits + meta)
ambrogio-site/site/agents.html   the cage section                                      (1 insert)
PROGETTO.md                      §4's three bullets, kept true
AVANZAMENTO.md                   §Done [step #67/2], §Next, §Open questions
review-step67-2/                 this report, the check, its log, the live readings
```

No restyling, no `index.html`, no `conversation.html`, no asset, no `Dockerfile`, no workflow.
