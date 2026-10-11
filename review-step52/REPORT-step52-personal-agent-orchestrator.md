# step #52 — the site is a *Personal Agent Orchestrator*

The operator's filing (2026-10-11): *«Agent orchestrator -> Personal Agent Orchestrator»*. The
phrase is rewritten **where it is read, and only the phrase** — the surrounding wording stands,
as the task asked. Everything below is the tree `/workspace/ambrogio-site` (the repository
`tazzo/ambrogio.tazlab.net`), served at `https://ambrogio.tazlab.net/`.

## 1. Every file and line that changed

The change commit is `0802624` — *"the site says Personal Agent Orchestrator: the phrase moved
everywhere it is read"*, 8 files, 12 insertions, 12 deletions (`git show --stat 0802624`).

| file | line | before | after |
|---|---|---|---|
| `ambrogio-site/site/index.html` | 6 | `<title>Ambrogio — the agent orchestrator of tazlab.net</title>` | `<title>Ambrogio — the Personal Agent Orchestrator of tazlab.net</title>` |
| `ambrogio-site/site/index.html` | 33 | `<p class="eyebrow">Agent orchestrator</p>` | `<p class="eyebrow">Personal Agent Orchestrator</p>` |
| `ambrogio-site/site/index.html` | 85 | `<span>Ambrogio — the agent orchestrator of tazlab.net.</span>` | `<span>Ambrogio — the Personal Agent Orchestrator of tazlab.net.</span>` |
| `ambrogio-site/site/agents.html` | 92 | the same footer span | the same span, *Personal Agent Orchestrator* |
| `ambrogio-site/site/queues.html` | 103 | the same footer span | the same span, *Personal Agent Orchestrator* |
| `ambrogio-site/site/doors.html` | 85 | the same footer span | the same span, *Personal Agent Orchestrator* |
| `ambrogio-site/site/conversation.html` | 81 | the same footer span | the same span, *Personal Agent Orchestrator* |
| `PROGETTO.md` | 178 | `### \`site/index.html\` — *Ambrogio — the agent orchestrator of tazlab.net*` | the same citation, *Personal Agent Orchestrator* |
| `README.md` | 3 | `… the agent orchestrator of tazlab.net: one Go binary that` | `… the Personal Agent Orchestrator of tazlab.net: one Go binary` (rewrapped to the file's 100 columns) |
| `ambrogio-site/README.md` | 4 | `for **Ambrogio**, the agent orchestrator of tazlab.net.` | `for **Ambrogio**, the Personal Agent Orchestrator of tazlab.net.` |
| `AVANZAMENTO.md` | 110 | — | the `[step #52]` entry in **Done** (the file says *append, never rewrite*) |

**The phrase, counted on the five pushed pages (case-sensitive):**

```
ambrogio-site/site/index.html         Personal Agent Orchestrator 3   Agent orchestrator 0
ambrogio-site/site/queues.html        Personal Agent Orchestrator 1   Agent orchestrator 0
ambrogio-site/site/doors.html         Personal Agent Orchestrator 1   Agent orchestrator 0
ambrogio-site/site/agents.html        Personal Agent Orchestrator 1   Agent orchestrator 0
ambrogio-site/site/conversation.html  Personal Agent Orchestrator 1   Agent orchestrator 0
```

(`review-step52/verify-local.log`.)

**Where the phrase was *not*, and why that is the answer and not an omission.**

- the **meta description** (`index.html:7` and the four deep dives) never named it — it says what
  the binary does, not what Ambrogio is called; it is unchanged;
- the pages carry **no Open Graph tag at all** — `grep -c 'property="og:'` is **0** on every
  served page (`review-step52/live-site-check.txt`), so there was no `og:title` /
  `og:description` to move. The task named them; the finding is that they do not exist;
- `PROGETTO.md:34` and `:54` say *"what the orchestrator is"* / *"what this orchestrator is"* —
  the word *orchestrator* alone, **not** the phrase *agent orchestrator*, and the task says the
  change is the phrase, not the sentence around it, so they stand;
- the **records** are left as they are, and named here with their reason (the rule step #50 set):
  `REPORT-step46-build-and-lane.md:56`, `review-step47/REPORT-step47-end-to-end-review.md:304,309,329`
  and `review-step47/render-report.json:14,265` are readings of what the site said on the day.
  Rewriting a record of what a command printed is making the record lie.

## 2. What I ran, and what it printed

**The two checks the publish workflow runs**, on the tree that was pushed — both pass, so the
push was publishable (`review-step52/verify-local.log`):

```
$ sh verify-project.sh --in-repo
verify-project: checked 8 citations, 0 missing
verify-project: 24 citations are in sibling trees this checkout does not carry
    -> rc 0

$ sh verify-logo-files.sh
pages          5 of 5 carry the file's own 512x512
logo drawn     40 px tall (and as wide), expected 40
favicon        unchanged (still the tab's favicon.ico)
VERIFY-LOGO-FILES: OK
    -> rc 0
```

The citation check re-reads every source `PROGETTO.md` cites; the edit at `PROGETTO.md:178` moved
the quoted title with the title, so the citation still resolves (the check counts files and line
numbers, and neither moved).

**The acceptance, read from the live URL and not from the source** —
`sh review-step52/verify-live.sh` → **rc 0**, `VERIFY-LIVE: OK`:

```
/                    200  Personal Agent Orchestrator 3  Agent orchestrator 0
/queues.html         200  Personal Agent Orchestrator 1  Agent orchestrator 0
/doors.html          200  Personal Agent Orchestrator 1  Agent orchestrator 0
/agents.html         200  Personal Agent Orchestrator 1  Agent orchestrator 0
/conversation.html   200  Personal Agent Orchestrator 1  Agent orchestrator 0
```

and the two numbers alone — `sh review-step52/measure-live.sh new` prints **3**,
`sh review-step52/measure-live.sh old` prints **0**.

The `<title>` and the eyebrow, read off the served bytes of `/`:

```
<title>  Ambrogio — the Personal Agent Orchestrator of tazlab.net
eyebrow  Personal Agent Orchestrator
```

**One thing to say plainly about counting.** The string *Agent orchestrator* is gone
case-sensitively, but *Agent Orchestrator* still occurs — inside *Personal Agent Orchestrator*
(3 on `/`, 1 per deep dive). That is unavoidable: the operator's own target phrase contains it.
The reading that matters is therefore the case-sensitive one above: the old phrase as written is
gone, and the new phrase as written is served.

## 3. The lane that carried it

Push `0802624` at ~23:29Z → GitHub Actions run **#10** (`Publish Ambrogio Site`, conclusion
**success**, all steps green) → image
`tazzo/tazlab-ambrogio-site:ambrogio-site-10-08026245668b75fb04b839464afca2d90ff456b5` pushed
23:30:11Z → Flux's `ImageUpdateAutomation` committed **`ea0bd53`** into `tazlab-k8s`
(`apps/base/ambrogio-site/ambrogio-site.yaml` now names that tag) → the pod rolled → the live
page changed between the 23:33:01Z and the 23:33:31Z reading, **about four minutes after the
push**. The readings are in `review-step52/lane.txt`.

## 4. What the delivery departs from

Nothing in the assignment was skipped. One judgement call is declared in the delivery's
`deviation`: the phrase is written **title case** everywhere (*the* Personal Agent Orchestrator
*of tazlab.net*), mid-sentence included, so that the string the operator filed appears verbatim
wherever it is read; the alternative — lowercase *personal agent orchestrator* inside the title
and the footer — would have left the delivered phrase differing from the one he asked for.
`AVANZAMENTO.md` was changed even though it never carried the phrase (the entry is the record of
this step, which the file's own contract asks for), and the pages' missing Open Graph tags are
reported rather than invented.

## 5. Children this work revealed

1. **`the five pages carry no Open Graph metadata at all`** (work) — `grep -c 'property="og:'`
   is 0 on every served page, so a link to the site previews with no title, description or
   image. The task named the Open Graph tags as a place the phrase lives; the finding is that
   the place does not exist yet. `og:title`, `og:description` and an `og:image` (the 512 the
   header already draws) are the obvious fill, with the phrase this step just set.
