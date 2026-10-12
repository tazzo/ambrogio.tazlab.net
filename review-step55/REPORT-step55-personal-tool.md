# step #55 — the first page says it is a personal tool, and what it takes off one person

The operator's filing (2026-10-11), in his own words: *«Il testo dovrebbe puntualizzare il fatto
che e' personale, perche' e' un unico binario che parte al suo file: non e' una cosa per grandi
team ma una cosa per gestire il lavoro di probabilmente di una persona, di un piccolo team. Io lo
uso per me stesso, e il suo scopo principale appunto e' orchestrare piu' agenti che possono
lavorare sulle stesse cose, quindi tenere traccia dei lavori che vengono fatti anche da piu' tool
e anche da agenti autopilotati da Ambrogio … Bisogna puntualizzare sulle cose importanti che fa:
quando succede qualcosa c'e' tracciato tutto. Non e' un prodotto professionale, pero' e' una
cosina che fa il suo lavoro fatto bene e mi toglie un sacco di problemi che invece lavorando con
tanti terminali aperti a volte, o perche' hai i documenti scritti nelle varie cartelle di qua e
di la'.»*

Everything below is the tree `/workspace/ambrogio-site` (the repository
`tazzo/ambrogio.tazlab.net`), served at `https://ambrogio.tazlab.net/`.

*(The step prompt names this work *queue #53*; the repository's own step sequence —
`AVANZAMENTO.md`, the `review-stepNN/` directories — ran to **#54**, so this one is recorded as
**#55**.)*

## 1. What changed, and only this

The change commit is `6e214c6` — *"index.html: the page says it is a personal tool, who it is for,
and what it takes off one person"*, **2 files, 42 insertions, 14 deletions** (`git show --stat
6e214c6`): `ambrogio-site/site/index.html` and `PROGETTO.md` (documentation of the same page,
§2 below).

**The text of the first page, and nothing else.** The two body paragraphs that stood under the
lead became five; the head's description and its `og:description` copy gained the same framing.
Nothing else on the page moved — the eyebrow, the `h1`, the lead, the `h2` *The four things worth
knowing*, its four cards, the side menu and its five links, the header, the mark's `img` and the
footer are untouched — and **no other page changed** (`git status` names only those two files;
`review-step55/` is this step's own evidence directory).

### The sentences added to `ambrogio-site/site/index.html`, quoted from the served page

```
It is a personal tool. It is one static Go binary beside one SQLite file — no server to install,
no database to run, no infrastructure, no team — and the operator runs it on his own machine and
drives it from a page the binary serves itself. One person, or a small team, is the most it is
made for.

What it does is orchestration: several agents working at the same time on the same things.
Ambrogio supervises resident agent processes over the Agent Client Protocol, hands them work
without two agents in one place, and exposes the whole of it — the queues, the steps, the
documents, the verdicts — through one HTTP API and one event stream. It opens tasks of its own as
well, the smaller jobs, and the agents it spawns carry them.

What it keeps is the trace: what was done, by whom and when — the operator's own work, the work of
other tools, and the work of the agents Ambrogio spawns for itself. A queue says the order, its
documents say why, and the record stays in the one file beside the binary.

That is the problem it removes. For one person the work grows past what one person can hold — many
terminals open at once, documents written here and there, no answer to who did what and when — and
Ambrogio is the one place where the work is written down, the documents stay, and the order of it
can be read back afterwards.

It is not a professional product. It is a small thing that does its job well.
```

and, in the head, both the description and the share card's copy of it:

```html
<meta name="description" content="Ambrogio is a personal tool: one binary beside one file, for one person or a small team, that supervises resident AI agents, carries their work in queues, and keeps the trace of what was done and why.">
```

(one line in the file; `og:description` carries the same content, character for character)

**The one paragraph that left the page** is the one that said *"It exists for two problems: several
agents working at once without two agents in one place, and the trace of what was done and why, for
the agent that comes later and was not there when the decision was taken."* Both problems are still
on the page — the first as *what it does is orchestration … without two agents in one place*, the
second as *what it keeps is the trace* — so nothing was dropped, only said again in the operator's
terms. No sentence moved between sections: the page has one body section, and the five paragraphs
stand in the order he asked for (what it is, who for, what it orchestrates, what it keeps, the
problem, the register).

**No fact is new.** Each claim was read from the engine's own account before it was written:
one static Go binary beside one SQLite file (`ambrogio/README.md` §8 — the hub owns one directory,
`bin/ambrogio` + `data/ambrogio.db`); resident agent processes supervised over the Agent Client
Protocol, one HTTP API, one event stream (§3, §4); several agents at work at once without two in one
place (§1, the operator's own two problems); the tasks the hub opens for itself and the agents it
spawns for them (§2 — *"a request from the operator, or a task the hub opened itself"*; §7, the tool
declarations per role); the trace — what was done, by whom, when — the operator's work, other tools'
work and the hub's own agents' work (§4, the free external agent; §6, the trace); a queue says the
order and the documents say why, and the record lives in the one SQLite file (§6). The "smaller
jobs" is the operator's own description of the work the hub opens for itself; the mechanism is the
one §2 and §7 state.

## 2. The documents that describe the same thing, and what was done to them

- **`PROGETTO.md` §4** documents each page *file by file*, and its `index.html` bullet described the
  old three-block page (*"Five lines and four cards, nothing else"*, *what it is*, *why it exists*).
  Left alone it would have described a page that no longer exists. It was rewritten to the new text,
  with the citations the new claims rest on (`ambrogio/README.md` §1, §2, §6). It is documentation
  only — no page — and it is declared in the delivery's `deviation`. The digest and the five page
  names the publish check reads out of this file are untouched.
- **`AVANZAMENTO.md`** gains the `[step #55]` entry that records this work; the history above it is
  not rewritten.
- **`README.md` (both copies)** were left alone: they already say *Personal Agent Orchestrator* and
  describe the site as static pages served by nginx — nothing in them contradicts the new text.

## 3. What I ran, and what it printed

**The page as rendered, locally** (a `python3 -m http.server` over `ambrogio-site/site`, read with
`curl`): `/` answered **200, 4943 bytes**, **0 `<script>` elements**, one `img` (`logo.png`), and
six paragraphs inside `<main>` — the lead and the five new ones, in the order above. The same bytes
the live host serves (same sha256).

**The two checks the publish workflow runs**, on the tree that was pushed — both pass, so the push
was publishable (`review-step55/checks.log`):

```
$ sh verify-project.sh --in-repo
verify-project: checked 8 citations, 0 missing
verify-project: 24 citations are in sibling trees this checkout does not carry
    -> rc 0

$ sh verify-logo-files.sh
== 1. the mark in the site          site/logo.png 121589 bytes 626654ac…  (byte for byte with the icon set's 512)
== 2. the markup, on the five pages  pages 5 of 5 carry the file's own 512x512
== 3. the drawn height               logo drawn 40 px tall, expected 40
== 4. the favicon left alone         favicon.ico unchanged (still the tab's favicon.ico)
VERIFY-LOGO-FILES: OK
    -> rc 0
```

**The acceptance, read from the live URL and not from the source** —
`sh review-step55/verify-live.sh` → **rc 0**, `VERIFY-LIVE: OK` (`review-step55/verify-live.log`):

```
/                    200  4943 bytes
  says "It is a personal tool."                                                 1
  says "one static Go binary beside one SQLite file"                            1
  says "no server to install, no database to run, no infrastructure, no team"   1
  says "One person, or a small team, is the most it is made for."               1
  says "What it does is orchestration"                                          1
  says "several agents working at the same time on the same things"             1
  says "What it keeps is the trace"                                             1
  says "the work of other tools, and the work of the agents Ambrogio spawns for itself" 1
  says "That is the problem it removes."                                        1
  says "many terminals open at once, documents written here and there"          1
  says "It is not a professional product."                                      1
  description and og:description say "a personal tool"                          2
  menu: links to index.html / queues.html / doors.html / agents.html / conversation.html  2 each
/queues.html         200  6056 bytes  bc874571…  unchanged=yes
/doors.html          200  4799 bytes  d744585f…  unchanged=yes
/agents.html         200  5110 bytes  5758c7e6…  unchanged=yes
/conversation.html   200  4548 bytes  077e668b…  unchanged=yes
```

The sentences are read against the served page with its line breaks flattened to single spaces —
the page is hand-wrapped, so a sentence can straddle two source lines, and the check quotes the
sentence a reader sees.

and the single numbers — `sh review-step55/measure-live.sh personal` prints **11** (of the eleven
sentences), `… bytes` prints **4943**, `… digest` prints
`15c3ecf0df5dde0dfd6ccbe80122d24ad8d997402e9e957fa59d1a07fdf6f326`, `… deepdives` prints **4**.

**Before and after, on the served bytes** (`review-step55/live-before.txt`,
`review-step55/live-after.txt`):

| page | before (2026-10-11T23:57Z) | after (2026-10-12T00:02Z) |
|---|---|---|
| `/` | 200, 3818 B, `5739af66…` | 200, 4943 B, `15c3ecf0…` |
| `/queues.html` | 200, 6056 B, `bc874571…` | 200, 6056 B, `bc874571…` |
| `/doors.html` | 200, 4799 B, `d744585f…` | 200, 4799 B, `d744585f…` |
| `/agents.html` | 200, 5110 B, `5758c7e6…` | 200, 5110 B, `5758c7e6…` |
| `/conversation.html` | 200, 4548 B, `077e668b…` | 200, 4548 B, `077e668b…` |

The four deep dives are byte-for-byte the same on both readings; only the first page moved
(3818 → 4943 bytes, +1125).

## 4. The lane that carried it

Push `6e214c6` (23:57:33Z) → GitHub Actions run **#13** (`Publish Ambrogio Site`, id
`38186202415`, conclusion **success**, every step green) → image
`tazzo/tazlab-ambrogio-site:ambrogio-site-13-6e214c693ca8bffdc786d12f901dd61118ecb45e` pushed
23:57:53Z → Flux's `ImageUpdateAutomation` committed **`1ce4561`** into `tazlab-k8s`
(`apps/base/ambrogio-site/ambrogio-site.yaml` now names that tag) → the pod rolled → the live page
changed between the 23:57Z and the 00:02:10Z reading, **about four and a half minutes after the
push**. The readings are in `review-step55/lane.txt`.

## 5. What the delivery departs from

One departure, declared in the delivery's `deviation`: **`PROGETTO.md` §4 was rewritten** (and
`AVANZAMENTO.md` appended to). The assignment is the page's text; the design document describes that
page file by file, so leaving it would have left a document describing a page that no longer exists.
Documentation only, no page, and the check that reads the document still passes.

**A second, smaller one, also declared:** the head's `meta name="description"` and the
`og:description` that copies it now say *"Ambrogio is a personal tool: one binary beside one file,
for one person or a small team, …"*. The assignment is the page's text; the description is text of
the page, and a page whose body says it is personal while its own summary does not is a page that
argues with itself. Nothing else in the head moved (`<title>`, `og:title`, `og:image`, `og:url`,
`og:type` are untouched), and the two remain character-for-character equal, as step #53 fixed them.

## 6. Children this work revealed

None. The change is text on one page plus the two documents that describe it; nothing in the tree
depends on the old wording beyond what this step already carried.
