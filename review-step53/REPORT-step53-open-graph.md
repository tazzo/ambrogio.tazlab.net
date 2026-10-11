# step #53 — the five pages carry an Open Graph block

The five pages of `ambrogio-site/site/` had **no Open Graph metadata at all**: measured before
this step, `grep -c 'property="og:'` printed **0** on every page, so a link to the site posted
anywhere — a chat, a mail, a document — previewed with no title, no description and no image.
The assignment: add `og:title`, `og:description` and `og:image` to the five pages, using the
phrase step #52 set (*Personal Agent Orchestrator*) and the 512×512 mark the header already
draws, keep the pages script-free, run the two publish checks, push.

## 1. Every file and line that changed

The change commit is `2f43f92` — *"the five pages carry an Open Graph block: og:title,
og:description, og:image"*, **5 files, 25 insertions, 0 deletions** (`git show --stat 2f43f92`).

Each head gains the block **after its own meta description and before `<link rel="icon">`**, so
the head reads: charset, viewport, `<title>`, description, the block, icon, stylesheet.

| file | lines | the five properties it now carries |
|---|---|---|
| `ambrogio-site/site/index.html` | 8–12 | `og:title` = the page's `<title>` (*Ambrogio — the Personal Agent Orchestrator of tazlab.net*), `og:description` = its meta description, `og:image` = `https://ambrogio.tazlab.net/logo.png`, `og:url` = `https://ambrogio.tazlab.net/`, `og:type` = `website` |
| `ambrogio-site/site/queues.html` | 8–12 | the same five, with *The queues, and who accepts them — Ambrogio* and `…/queues.html` |
| `ambrogio-site/site/doors.html` | 8–12 | the same five, with *The two doors, and the sandbox — Ambrogio* and `…/doors.html` |
| `ambrogio-site/site/agents.html` | 8–12 | the same five, with *The agents, the budget and the silence — Ambrogio* and `…/agents.html` |
| `ambrogio-site/site/conversation.html` | 8–12 | the same five, with *The conversation — Ambrogio* and `…/conversation.html` |

**One source of truth per page.** `og:title` is the page's own `<title>` and `og:description`
its own `meta name="description"`, character for character — so a future edit to a title cannot
leave the share card saying something else. `review-step53/verify-og.sh` asserts that equality
on all five pages, and it passes (`VERIFY-OG: OK`).

**The phrase, and the mark.** `og:title` on the main page carries *Personal Agent Orchestrator*
(the phrase step #52 set) because that page's `<title>` does; the deep dives carry their own
titles, which never named it. `og:image` is `https://ambrogio.tazlab.net/logo.png` — the
512×512 mark the header already draws (121,589 B, sha256 `626654ac…`), not a second image.

**Script-free, still.** No `<script>` was added; all five pages carry **0** (`verify-og.sh`).

## 2. What I ran, and what it printed

**The two checks the publish workflow runs**, on the tree that was pushed — both pass, so the
push was publishable (`review-step53/verify-local.log`):

```
$ sh verify-project.sh --in-repo
verify-project: checked 8 citations, 0 missing
verify-project: 24 citations are in sibling trees this checkout does not carry
    -> rc 0

$ sh verify-logo-files.sh
pages          5 of 5 carry the file's own 512x512
logo drawn     40 px tall (and as wide), expected 40
VERIFY-LOGO-FILES: OK
    -> rc 0

$ sh review-step53/verify-og.sh
index.html           og:title present  og:description present  og:image present  og:url present  og:type present  scripts 0
queues.html          … (the same, 0 scripts)
doors.html           … (the same, 0 scripts)
agents.html          … (the same, 0 scripts)
conversation.html    … (the same, 0 scripts)
VERIFY-OG: OK
    -> rc 0
```

**The acceptance, read from the live URL and not from the source** —
`sh review-step53/verify-live-og.sh` → **rc 0**, `VERIFY-LIVE-OG: OK` (`review-step53/live-og.txt`):

```
/                    200  og properties 5  og:image https://ambrogio.tazlab.net/logo.png
/queues.html         200  og properties 5  og:image https://ambrogio.tazlab.net/logo.png
/doors.html          200  og properties 5  og:image https://ambrogio.tazlab.net/logo.png
/agents.html         200  og properties 5  og:image https://ambrogio.tazlab.net/logo.png
/conversation.html   200  og properties 5  og:image https://ambrogio.tazlab.net/logo.png
og:image target     200 121589  626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
```

and the head of `/` as served, verbatim:

```html
<title>Ambrogio — the Personal Agent Orchestrator of tazlab.net</title>
<meta name="description" content="Ambrogio is one binary that supervises resident AI agents, carries their work in queues, and keeps the trace of what was done and why.">
<meta property="og:title" content="Ambrogio — the Personal Agent Orchestrator of tazlab.net">
<meta property="og:description" content="Ambrogio is one binary that supervises resident AI agents, carries their work in queues, and keeps the trace of what was done and why.">
<meta property="og:image" content="https://ambrogio.tazlab.net/logo.png">
<meta property="og:url" content="https://ambrogio.tazlab.net/">
<meta property="og:type" content="website">
```

So `og:image` points at a real 200 whose bytes are the pinned mark, not at a 404 — the failure
mode that makes a share card look broken.

## 3. The lane that carried it

Push `2f43f92` (~23:38Z) → GitHub Actions run **#11** (`Publish Ambrogio Site`, conclusion
**success**, all steps green) → image
`tazzo/tazlab-ambrogio-site:ambrogio-site-11-2f43f927dbb5d84bfeda79bf4ba5c3e521df4d57` pushed
23:39:23Z → Flux's `ImageUpdateAutomation` committed **`c05d286`** into `tazlab-k8s`
(`apps/base/ambrogio-site/ambrogio-site.yaml` names that tag) → the pod rolled → the live pages
carried the block by the 23:43:51Z reading, about five minutes after the push
(`review-step53/lane.txt`).

## 4. What the delivery departs from

One departure, declared in the delivery's `deviation`: **two properties the assignment did not
name were added**. The Open Graph protocol requires four — `og:title`, `og:type`, `og:image`,
`og:url` — and the assignment named three, so `og:url` (each page's own address) and
`og:type` (`website`) were added as well, because a block that is three-fifths of one is a
block no validator accepts. The three named properties are present and unchanged in meaning;
the extra two cost ten lines and no new behaviour.

**Left alone, and named with their reason:** `PROGETTO.md`. Its §4 describes each page's
**body**, and it never documented the head's `<title>` or `description` either — the Open Graph
block joins them in being the head's business, not §4's. Writing a new section for it would be a
design decision of my own, so it is declared as the child below instead. The page **bodies** are
untouched: 25 insertions, 0 deletions, all inside `<head>`.

## 5. Children this work revealed

1. **`PROGETTO.md does not describe the head of the pages`** (work) — the design document has
   §3.1 for the mark, §3.2 for the typeface, §3.3 for the palette, §3.4 for the stylesheet, and
   §4 for each page's body; nothing states what the `<head>` carries (`<title>`, description,
   the five `og:` properties). A reader comparing the document to a page finds an undocumented
   block. One short section, with the pages as its citations, closes it.
