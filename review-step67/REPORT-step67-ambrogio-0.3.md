# Step 67 — the first page says «Ambrogio 0.3 — The Butler»

**Queue #67, role worker-external.** Tree: the worktree `/workspace/ambrogio/scratch/lab/wt/q67`
of `https://github.com/tazzo/ambrogio.tazlab.net.git`, branch `q67/ambrogio-site`.

## What the step asked (operator, 2026-10-14, verbatim)

> Il sito deve dire la versione nuova. In ambrogio-site/site/index.html aggiungi la riga
> «Ambrogio 0.3 — The Butler» e, sotto, una frase sola su cosa e' cambiato: una coda possiede un
> ramo e una cartella di lavoro propria, l'engine atterra il suo lavoro (push e pull request), e
> ogni agente lavora dentro una gabbia. Non toccare le altre pagine. Poi consegna.

Acceptance, as stated: `ambrogio-site/site/index.html` carries the line **Ambrogio 0.3 — The
Butler** and **one** sentence on what changed. No other page is to be touched.

## What changed

`ambrogio-site/site/index.html:43-46` — between the hero (eyebrow, `h1`, lead) and the body copy:

```html
      <p class="release">Ambrogio 0.3 — The Butler</p>
      <p class="release-note">In 0.3 a queue owns a branch and a working directory of its own,
        the engine lands the work itself — a push, and a pull request — and every agent works
        inside a cage.</p>
```

`ambrogio-site/site/styles.css:79-81` — the two rules that give those two paragraphs their look,
written where the file's Type section already keeps the eyebrow and the lead:

```css
/* The release the page is about, and the one sentence on what changed in it. */
.release { font-weight: 650; margin: 0.4rem 0 0.3rem; }
.release-note { color: var(--dim); }
```

`font-weight: 650` is the page's own heading weight (`h1, h2, h3 { … font-weight: 680 }`,
`.brand { font-weight: 650 }`); `var(--dim)` is the token the lead and the card text already use.
No new token, no framework, no JavaScript — the stylesheet is still the site's only vocabulary of
look, and the mark's own rule (`.brand img { … width: 40px; height: 40px; }`) is untouched, which
is what `verify-logo-files.sh` §3 reads.

The sentence is **one** sentence, and names exactly the three changes the order names:

| the order says | the sentence says |
|---|---|
| una coda possiede un ramo e una cartella di lavoro propria | a queue owns a branch and a working directory of its own |
| l'engine atterra il suo lavoro (push e pull request) | the engine lands the work itself — a push, and a pull request |
| ogni agente lavora dentro una gabbia | every agent works inside a cage |

*Cage* is the site's own word already: `doors.html:41` says *«every worker it starts is caged
before it runs»* and its `<h2>The sandbox</h2>` describes the Landlock launcher. The step adds no
new vocabulary, and no claim about the engine beyond the operator's own three.

### The two documents that had to follow it

`PROGETTO.md` §4 documents every page file by file, and its `index.html` bullet ended with
*«No feature list, no screenshot gallery, no version badge.»* — a page carrying a release line
makes that false, so the bullet gained the release line and the phrase went
(`PROGETTO.md:181,201-206`), and §3.4's inventory of the stylesheet gained the two rules
(`PROGETTO.md:165-166`). `AVANZAMENTO.md` gained its `[step #67]` entry in §Done, and §Next —
which still opened with *«Publish, and verify the site end to end»*, the work steps #50–#55 had
already landed — was brought to what is true.

## What was verified, and what could not be

### 1. The page, as the document nginx will serve — `review-step67/verify-index-0.3.sh`

```
$ sh review-step67/verify-index-0.3.sh
ok    the page carries «Ambrogio 0.3 — The Butler» exactly once (found 1)
ok    the line is the text of a <p> of its own in <main>, not a comment or an attribute
ok    the sentence sits directly under the line, as the next paragraph
ok    the two paragraphs are marked .release and .release-note (one each)
ok    the note is one sentence (0 further sentence ends)
ok    the sentence names: a queue owns a branch and a working directory of its own
ok    the sentence names: the engine lands the work itself — a push, and a pull request —
ok    the sentence names: every agent works inside a cage
ok    the order is: the hero, the release line, then the page's body (before the first <h2>)
ok    the markup parses (no unclosed tag swallowed the document)
ok    <h1> ×1 (was ×1)
ok    <h2> ×1 (was ×1)
ok    <main> ×1 (was ×1)
ok    the four cards are still four (×4)
ok    still no <script>
ok    the header mark is still the file's own 512×512
-- the page's paragraphs in <main>: 13 (the published page had 11: the eyebrow, the lead, five body, the register and four cards; the release line and its sentence are the two more)
VERIFY-INDEX-0.3: OK
```

The script parses the file with `html.parser` (the page is read as HTML, not as a haystack of
bytes): the line has to be the *text node of a `<p>` inside `<main>`*, the sentence has to be the
*next paragraph*, and the page's skeleton has to be the one that was published. It exits 1 and
names what is wrong on any of the sixteen; it is not a script that passes by construction — run
against the page as published (`git show HEAD:ambrogio-site/site/index.html`, in a two-directory
stand-in the script's own `ROOT` derivation accepts) it refuses it:

```
$ sh …/pretend-0.3/review-step67/verify-index-0.3.sh
FAIL  the page carries «Ambrogio 0.3 — The Butler» exactly once (found 0)
FAIL  the line is the text of a <p> of its own in <main>, not a comment or an attribute
FAIL  the sentence sits directly under the line, as the next paragraph
FAIL  the two paragraphs are marked .release and .release-note (one each)
ok    the note is one sentence (0 further sentence ends)
…
FAIL  the order is: the hero, the release line, then the page's body (before the first <h2>)
…
-- the page's paragraphs in <main>: 11 (…)
VERIFY-INDEX-0.3: FAILURES
rc=1
```

### 2. The publish lane's own two checks

```
$ sh verify-project.sh --in-repo
skipped        the mark's digest against the icon set's file (ambrogio/v2/api/android-chrome-512x512.png is a sibling checkout)
verify-project: checked 8 citations, 0 missing
verify-project: 24 citations are in sibling trees this checkout does not carry (run without --in-repo on the operator's machine)
rc=0
```

`verify-logo-files.sh` **cannot be run faithfully in this cage**, and the reason is worth writing
down: it byte-compares `site/logo.png` with the sibling checkout
`/workspace/ambrogio/v2/api/android-chrome-512x512.png`, which this cage *has* (so `-f` is true)
and *refuses to read* (the Landlock policy: `-rw------- tazpod`, and `sha256sum` answers
`Permission denied`). The script's own design says that branch belongs to the operator's machine,
not to a runner — a runner carries this repository only, `-f` is false there, and the script takes
its *«sibling … is not here»* branch. So the check was run the way the runner runs it, by
repointing that one constant at a path that does not exist (the same `sed` the report shows), and
with that one substitution **nothing else changed**:

```
$ sed 's#^REPO=/workspace/ambrogio/v2/api/android-chrome-512x512.png$#REPO=/nonexistent/sibling-checkout/android-chrome-512x512.png#' verify-logo-files.sh > ./.verify-logo-runner-mode.sh && sh ./.verify-logo-runner-mode.sh
== 1. the mark in the site
site/logo.png  121589 bytes  626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
expected       121589 bytes  626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
sibling        /nonexistent/sibling-checkout/android-chrome-512x512.png is not here (a runner carries this repository only): the pinned digest above is the whole check
PROGETTO.md    names the same digest
== 2. the markup, on the five pages
pages          5 of 5 carry the file's own 512x512
== 3. the drawn height the stylesheet states
logo drawn     40 px tall (and as wide), expected 40
== 4. the favicon left alone
favicon.ico   15086 bytes  b88644a59fa5dad99bf7aa9371ee52b8e2da5d24f1e6f31d45943500bf40377f
favicon        unchanged (still the tab's favicon.ico)
VERIFY-LOGO-FILES: OK
rc=0
```

(the copy lived at the repository's own root for the run — the script finds the tree from its own
path — and was removed afterwards). §2 is the one that reads *this* step: **5 of 5 pages still
carry** `src="logo.png" width="512" height="512"`, the markup `verify-index-0.3.sh` also asserts
on `index.html`.

### 3. No other page changed, and the live hostname is still the old page

```
$ git diff --name-only HEAD -- ambrogio-site/site/
ambrogio-site/site/index.html
ambrogio-site/site/styles.css
$ git show HEAD:ambrogio-site/site/index.html > review-step67/index-at-HEAD.html
$ cmp -s review-step67/index-at-HEAD.html review-step67/live-index-before.html && echo 'the live / is byte-identical to index.html at HEAD'
the live / is byte-identical to index.html at HEAD
$ for p in queues doors agents conversation; do curl -sS -o review-step67/live-$p.html https://ambrogio.tazlab.net/$p.html; cmp -s review-step67/live-$p.html ambrogio-site/site/$p.html && echo "/$p.html  the tree and the live hostname agree, byte for byte"; done
/queues.html  the tree and the live hostname agree, byte for byte
/doors.html  the tree and the live hostname agree, byte for byte
/agents.html  the tree and the live hostname agree, byte for byte
/conversation.html  the tree and the live hostname agree, byte for byte
$ curl -sS -o review-step67/live-index-before.html -w 'GET / -> %{http_code} %{size_download} bytes\n' https://ambrogio.tazlab.net/
GET / -> 200 4943 bytes
$ grep -c 'Ambrogio 0.3' review-step67/live-index-before.html
0
$ for p in queues doors agents conversation; do curl -sS -o /dev/null -w "/$p.html -> %{http_code} %{size_download}\n" https://ambrogio.tazlab.net/$p.html; done
/queues.html -> 200 6056
/doors.html -> 200 4799
/agents.html -> 200 5110
/conversation.html -> 200 4548
```

So the *whole* difference between the tree and the live site is the five lines added to
`index.html` plus the three to `styles.css`: the four deep dives are byte-for-byte the pages the
hostname serves, and the live `/` is byte-for-byte `index.html` at `HEAD`.

### 4. What could not be done here — the page was not rendered

**This cage carries no renderer.** Chromium is installed and executable
(`/workspace/.tazpod/.omp/puppeteer/chrome/linux-150.0.7871.24/chrome-linux64/chrome`,
`Google Chrome for Testing 150.0.7871.24`) but cannot start inside the policy:

```
$ chrome --headless=new --no-sandbox --disable-gpu --screenshot=… file:///…/index.html
[…]
FATAL:sandbox/linux/services/proc_util.cc:38] Check failed: . : Permission denied (13)
[…/singleton_socket…] Aborted (core dumped)
```

— it is the same wall `doors.html` names for a caged worker (`the policy does not give a caged
worker what the Go toolchain needs`), and the transport offers no browser bridge either
(`browser.open` → *the tool bridge is unavailable in this kernel*). There is no second renderer
in the cage (`lynx`, `w3m`, `wkhtmltoimage`, `weasyprint`: none installed; `bs4`/`lxml`: not
importable), and no local socket (`bind`/`connect` on `127.0.0.1` → `Permission denied`), so the
page could not even be served and fetched. **No screenshot of this change exists, and none is
claimed.** The visual reading is left where PROGETTO §7 puts it: the live hostname, after the lane
carries the change. What is proved here is the document.

## Reproduction

```
sh review-step67/verify-index-0.3.sh                     # OK, rc 0 — the page says it
sh verify-project.sh --in-repo                           # checked 8 citations, 0 missing, rc 0
sed 's#^REPO=/workspace/ambrogio/v2/api/android-chrome-512x512.png$#REPO=/nonexistent/sibling-checkout/android-chrome-512x512.png#' \
    verify-logo-files.sh > ./.verify-logo-runner-mode.sh && sh ./.verify-logo-runner-mode.sh
rm -f ./.verify-logo-runner-mode.sh
git diff --name-only HEAD -- ambrogio-site/site/         # index.html, styles.css — nothing else
```

The output of every one of them, in order, is `review-step67/checks.log`.

`review-step67/` carries: `verify-index-0.3.sh` (the step's check), `checks.log` (every command
above with its output), `live-before.txt` (the readings taken from the hostname at
`2026-10-14T22:08:28Z`), `live-index-before.html`, `index-at-HEAD.html`, `live-*.html` (the four
deep dives as served, for the `cmp`s), and this report.

## What this reveals, and what is left

1. **The four deep dives do not carry 0.3.** The first page now says a queue owns a branch and a
   working directory of its own, that the engine lands the work (a push, and a pull request), and
   that every agent works inside a cage; the deep dives say nothing of the three. They do not
   *contradict* the first page — `queues.html:45` says a queue is not a git branch (it is not: it
   owns one), and `queues.html:97` says the engine does not build and does not merge (landing a
   push or a pull request is not merging) — but a reader who follows the menu meets three
   mechanisms the site never explains. This is the next step of this project, and it needs the
   engine's source read before the words are written.
2. **The line is in the source, not on the hostname.** The publish is the one PROGETTO §7
   already describes and it is not this step's act: the worker commits on its branch, the gate
   merges to the trunk, and the lane does the rest (push → the Action builds
   `ambrogio-site-<N>-<sha>` → Flux commits the tag → the pod rolls). Nothing was pushed from
   here; `origin/main` was left where it was (`4295bec7`).

## The tree this step leaves

```
ambrogio-site/site/index.html    the line and the sentence       (5 lines added)
ambrogio-site/site/styles.css    .release / .release-note        (3 lines added)
PROGETTO.md                      §3.4 and the §4 index.html bullet
AVANZAMENTO.md                   §Done [step #67], §Next brought to what is true
review-step67/                   this report, the check, its log, the live readings
```

No other page, no asset, no `Dockerfile`, no workflow was touched.
