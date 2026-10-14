# AVANZAMENTO — `ambrogio-site`

Living status of the project. Keep current: move items between Done and Next as
they land; never rewrite history, append.

## Done

- **[step #44] Lane mapped and verified.** The five-stage lane shared by
  `blog.tazlab.net`, `wiki.tazlab.net` and `teaching.tazlab.net` was read from the
  wiki's own pages and then **re-verified against the live repositories**; every
  claim carries a `path:line` in `RICERCA.md`. Three stale wiki claims were found
  and recorded (RICERCA §10).
- **[step #44] Naming rule fixed.** The fourth artifact is image
  `tazzo/tazlab-ambrogio-site` (as declared by the project-root `README.md`), tag
  `ambrogio-site-<N>-<sha>`, Flux pattern
  `^ambrogio-site-(?P<value>[0-9]+)-.*$` (RICERCA §8, PROGETTO §4).
- **[step #44] Project documents laid down:** `RICERCA.md` (the lane),
  `PROGETTO.md` (what the site is), this file.
- **[step #44] Design decided.** Small static site, nginx, one main page + a few
  deep-dive pages, inline-SVG logo, one self-hosted font; no generator, no
  database, no backend (PROGETTO §1–§3).
- **[step #45] The design decided, and written down.** `PROGETTO.md` now carries the four
  things the step asked for, each with its reason and its `path:line`:
  - **structure** — one main page + **four** deep dives, one per mechanism the step names
    (the queues and who accepts them; the two doors and the sandbox; the agents, the budget
    and the silence; the conversation), behind a side menu (PROGETTO §2);
  - **visual** — the operator's own mark `ambrogio/v2/api/ambrogio-mark.png`, **unmodified**
    (27638 B, sha256 `7c37248e…`), plus the engine's `favicon.ico`; one typeface, Inter,
    self-hosted (no CDN); the **product's own palette**, read from
    `ambrogio/v2/api/ui/app.css:15-16`, with measured contrast (fg/bg **14.54:1**, dim/bg
    **5.57:1**, accent/bg **7.19:1**); one hand-written stylesheet, no framework, no JS
    (PROGETTO §3);
  - **pod** — `nginx:stable-alpine`, single stage, `EXPOSE 80`, port 80 end to end, two
    probes copied in shape from `teaching.yaml:62-72`, resources requested (`10m/16Mi →
    200m/64Mi`, below the lab's smallest services) because a pod with no request is an
    unranked eviction candidate (`buzz/helmrelease.yaml:141-142`), and the image/tag rule Flux
    needs (`tazzo/tazlab-ambrogio-site` / `ambrogio-site-<N>-<sha>` /
    `^ambrogio-site-(?P<value>[0-9]+)-.*$`) (PROGETTO §5);
  - **page list, file by file** — what each of the five pages says, with the `ambrogio/README.md`
    section each claim comes from (PROGETTO §4).
- **[step #45] Deviations from the first pass, named.** The first pass' page set
  (`what-it-does.html`, `how-it-works.html`, `about.html`) and its hand-drawn inline
  `logo.svg` are **superseded** — the deep dives become the four mechanism pages, and the
  logo is the operator's own art (PROGETTO §8). The first pass' light palette is replaced by
  the product's tokens.
- **[step #45] A citation check, not a claim.** `verify-project.sh` re-reads every source
  `PROGETTO.md` cites and fails if one is missing; run it before trusting the document.
- **[step #45] Section numbers moved.** `PROGETTO.md` was renumbered by the rewrite: the
  naming rule the #44 entry calls *§4* is now **§5.5**, the artifacts list it calls *§5* is
  **§5**, and the definition of done it calls *§7* is still **§7**.
- **[step #46] The source reconciled to the design.** `ambrogio-site/site/` now carries the
  five pages of PROGETTO §2/§4 — `index.html` (the main page) plus `queues.html`, `doors.html`,
  `agents.html`, `conversation.html` — and the first pass' `what-it-does.html`,
  `how-it-works.html`, `about.html` and hand-drawn `logo.svg` are gone.
- **[step #46] The mark and the favicon are the operator's own files.** `site/logo.png` is
  **byte-identical** to `ambrogio/v2/api/ambrogio-mark.png` (27,638 B, sha256 `7c37248e…`,
  compared this step), and `site/favicon.ico` to the engine's `v2/api/favicon.ico` (15,086 B);
  every page draws `<img src="logo.png">` at 28 px, with no inlined SVG left.
- **[step #46] The palette is the product's, and the site is script-free.** `site/styles.css`
  (5,259 B, ~150 lines) uses only the tokens of `ambrogio/v2/api/ui/app.css:15-16` and the side
  menu of PROGETTO §2; the rendered pages report `background rgb(20,22,26)` (`#14161a`), four
  cards, **0 `<script>` elements**, and the menu collapsing to a wrapped row at 380 px
  (measured in a real Chromium this step).
- **[step #46] The font is pinned.** `site/fonts/inter.woff2` (48,256 B, sha256 `3100e775…`)
  is **byte-identical to its upstream URL** — the fontsource Latin subset of Inter Variable —
  and the URL, the size, the digest and the SIL OFL 1.1 text are recorded in
  `site/fonts/LICENSE-inter.txt`.
- **[step #46] Served and fetched.** From a document root over `site/`: `/`, the four deep
  dives, `styles.css`, `logo.png`, `favicon.ico`, `fonts/inter.woff2` and the licence all
  answered **200** with the right content types; no page still references a removed file.
- **[step #46] The pod files were left untouched.** `Dockerfile` and
  `.github/workflows/publish.yml` still match PROGETTO §5.1 and §5.5 byte for byte
  (`Dockerfile` 244 B sha256 `cbd0b103…`).

- **[step #49] The mark is the icon set's largest, drawn as a header mark.** `site/logo.png` is
  now `ambrogio/v2/api/android-chrome-512x512.png` — 512×512, **121,589 B**, sha256
  `626654ac…`, byte-compared with the file in the Ambrogio repository. It replaces the 192
  (`7c37248e…`, 27,638 B) the site had been serving drawn small. The set carries **no SVG**, and
  the 1024 exists only in the zip's iOS/macOS app-icon sets and was left there: at 40 CSS px the
  512 already covers the drawn pixels six times over, so 195 KB more would buy none. `.brand img`
  draws it at **40 px** (was 28) — inside the header's own 62 px `min-height`, so the bar does not
  grow — and the markup on all five pages carries the file's own `512×512`. `favicon.ico` is
  untouched (15,086 B, `b88644a5…`). Measured on the live hostname: **40×40 CSS px at 320 and at
  1440**, header still 63 px, no horizontal overflow either, desktop page height unchanged at
  **1295** — the mark grew and nothing else moved. The lane carried it: push `73e8ad0` → Actions
  run #6 → `ambrogio-site-6-73e8ad07…` → the ImageUpdateAutomation's commit `2f1c985` in
  `tazlab-k8s` → the pod rolled; `https://ambrogio.tazlab.net/logo.png` answers 121,589 B with
  that digest. `verify-logo.sh` runs the four checks; the citation check's digest moved to the
  512 (PROGETTO §3.1).

- **[step #49] The publish job runs the repository's own checks, before the registry.**
  `.github/workflows/publish.yml` gained a step after the checkout — `sh verify-project.sh
  --in-repo` then `sh verify-logo-files.sh` — standing **before** the Docker Hub login, so a
  tree that fails its own checks never touches the registry. Nothing ran either script before
  this step (grep found no reference to them). `verify-project.sh` gained `--in-repo`: the
  runner carries this repository and not the sibling trees, so the citations that live in
  `wiki.tazlab.net/`, `blog-src/`, `tazlab-k8s/` and `ambrogio/` are counted and reported as
  *not carried here* (8 checked, 0 missing, 24 not carried) instead of being called missing,
  and the full mode on the operator's machine is unchanged (32 checked, 0 missing).
  `verify-logo-files.sh` is the mark's file half, split out of `verify-logo.sh`: the pinned
  digest of `site/logo.png` (121,589 B / `626654ac…`) written **inline**, because the runner
  has no sibling checkout to read it from; the five pages' `img` attributes; the drawn height
  the stylesheet states (40 px); `favicon.ico`'s digest. `verify-logo.sh` now runs that half
  and then the live URL — the live half stays off the runner on purpose, since the live site
  is the previous deployment. Proven: the step's own commands pass on this tree (rc 0) and in
  a container that carries the copy only; on three corrupted copies — the logo's digest, one
  page's markup, one of the five page names in PROGETTO.md — the same commands exit 1
  `evidence-checks-pass.log`, `evidence-checks-corrupt.log`).

- **[step #52] The site says *Personal Agent Orchestrator*.** The operator filed *Agent
  orchestrator → Personal Agent Orchestrator* against the page he is presenting, and the phrase
  moved where it is read — and only the phrase: the hero eyebrow, the `<title>` and the footer of
  the main page (`ambrogio-site/site/index.html:6,33,85`), the footer of the four deep dives
  (`agents.html:92`, `queues.html:103`, `doors.html:85`, `conversation.html:81`), and the
  documents with them (`PROGETTO.md:178`, `README.md:3`, `ambrogio-site/README.md:4`). The pages
  carry **no** Open Graph tag and the meta description never named the phrase, so there was
  nowhere else in the markup to move. Both checks the publish workflow runs
  (`verify-project.sh --in-repo`, `verify-logo-files.sh`) pass on the pushed tree. The lane
  carried it: push `0802624` → Actions run #10 →
  `ambrogio-site-10-08026245668b…` → Flux's commit `ea0bd53` in `tazlab-k8s` → the pod rolled;
  measured on the live hostname, `/` carries *Personal Agent Orchestrator* and no *Agent
  orchestrator*, and the five pages answer **200** (`review-step52/`).

- **[step #53] The five pages carry an Open Graph block.** The head of every page gained
  `og:title`, `og:description` and `og:image` — the three the assignment names — and `og:url`
  and `og:type`, the two the Open Graph protocol also requires, so the block is valid rather
  than three-fifths of one (`ambrogio-site/site/index.html:8-12`, `queues.html:8-12`,
  `doors.html:8-12`, `agents.html:8-12`, `conversation.html:8-12`). `og:title` is the page's own
  `<title>` and `og:description` its own meta description, so each page has one source of truth;
  `og:image` is `https://ambrogio.tazlab.net/logo.png`, the 512×512 the header already draws;
  `og:url` is the page's own address. Nothing else moved: no `<script>` was added (still 0 on
  all five), and `verify-project.sh --in-repo` (8 checked, 0 missing) and `verify-logo-files.sh`
  (OK) pass on the pushed tree. Measured on the live hostname: the five pages carry the five
  properties and `logo.png` answers **200 121589** with the pinned digest
  `626654ac…` (`review-step53/`).

- **[step #54] The first page loses *Built in the lab it runs*.** The operator asked for the
  section out of `index.html`, heading included; the `h2` and its two paragraphs are gone
  (`ambrogio-site/site/index.html:75`; the commit `3717efe`, 2 files, 1 insertion, 12 deletions),
  and nothing else on the page moved — the eyebrow, the hero, the two body paragraphs, the four
  cards, the side menu and its five links, the header and the footer are untouched, and **no
  other page changed**. `PROGETTO.md` §4 documents each page file by file and described that
  closing paragraph, so its bullet went with it (docs only; declared). The removed block carried
  only `h2`/`p`/`a`, all shared with the rest of the site, so **no stylesheet rule is used only by
  that section** and none was removed. Both publish checks pass (`verify-project.sh --in-repo`
  8 checked / 0 missing; `verify-logo-files.sh` OK). The lane carried it: push `3717efe` →
  Actions run #12 (`ambrogio-site-12-3717efe11b09…`, 23:48:15Z) → Flux commit `9ec44cd` in
  `tazlab-k8s` → the pod rolled; measured on the live hostname (23:52:00Z), `/` carries no
  *Built in the lab it runs* and none of the three sentences, the five pages all answer **200**,
  and the four deep dives are byte-for-byte the same as before the push (`review-step54/`).

- **[step #55] The first page says it is a personal tool, and what it takes off one person.**
  The operator's own words (2026-10-11): the text should make plain that the thing is personal —
  one binary that starts on its own file, not something for large teams but for the work of one
  person, or a small team — and what it is for: orchestrating several agents that work on the same
  things at once and keeping the trace of the work, including work done by other tools and by
  Ambrogio's own agents, which take the smaller jobs; against the complexity that outgrows one
  person — many terminals open at once, documents written here and there. The change is
  `ambrogio-site/site/index.html` only: the two body paragraphs became five (a personal-tool
  paragraph, what it orchestrates, what it keeps, the problem it removes, and the honest
  register — *"not a professional product … a small thing that does its job well"*), and the meta
  description and the `og:description` that copies it now read *"Ambrogio is a personal tool: one
  binary beside one file, for one person or a small team, …"*
  (`ambrogio-site/site/index.html:7,9,43-65`). The page's structure, its side menu, the stylesheet
  and the four cards are untouched, and **no other page changed**; **no new fact is claimed** —
  one binary, one file, the queues, the trace and the tasks the hub opens for itself are what
  `ambrogio/README.md` §1/§2/§6 already say. `PROGETTO.md` §4 documents the page file by file, so
  its `index.html` bullet was rewritten to the new text (docs only; declared). Both publish checks
  pass (`verify-project.sh --in-repo` 8 checked / 0 missing; `verify-logo-files.sh` OK). The lane
  carried it: push `6e214c6` → Actions run #13
  (`ambrogio-site-13-6e214c69…`, 23:57:53Z) → Flux commit `1ce4561` in `tazlab-k8s` → the pod
  rolled; measured on the live hostname (00:02:10Z), `/` answers **200 4943** with all eleven of
  the new sentences present, and the four deep dives are byte-for-byte the ones served before the
  push (`review-step55/`).

- **[step #67] The first page says the new version, in one line and one sentence.** The
  operator's order (2026-10-14): *«Il sito deve dire la versione nuova. In
  `ambrogio-site/site/index.html` aggiungi la riga «Ambrogio 0.3 — The Butler» e, sotto, una
  frase sola su cosa e' cambiato: una coda possiede un ramo e una cartella di lavoro propria,
  l'engine atterra il suo lavoro (push e pull request), e ogni agente lavora dentro una gabbia.
  Non toccare le altre pagine.»* The page now carries, between the hero and the body copy
  (`ambrogio-site/site/index.html:43-46`):

  ```html
  <p class="release">Ambrogio 0.3 — The Butler</p>
  <p class="release-note">In 0.3 a queue owns a branch and a working directory of its own,
    the engine lands the work itself — a push, and a pull request — and every agent works
    inside a cage.</p>
  ```

  the line is a paragraph of its own, and the sentence under it is **one** sentence (`". "` →
  count 0) naming exactly the three changes the order names. Two rules give it its look
  (`site/styles.css:79-81`: `.release` at the page's own 650, `.release-note` in `--dim`) — one
  stylesheet, no framework — and the mark's own rule (`.brand img`, 40 px) is untouched. **No
  other page changed**: `git diff --name-only HEAD -- ambrogio-site/site/` → `index.html` and
  `styles.css` only, and the four deep dives are **byte-identical** to what the live hostname
  serves (`cmp` on each, `review-step67/live-*.html`). `PROGETTO.md` §4 documents the page file
  by file and its `index.html` bullet read *«no version badge»*: the bullet now carries the
  release line and that phrase went, and §3.4's inventory of the stylesheet gained the two rules
  (docs only; declared). The checks: `sh verify-project.sh --in-repo` → *checked 8 citations, 0
  missing*, rc 0; `sh verify-logo-files.sh` → **OK**, rc 0, run in the runner's own mode (this
  cage carries the sibling checkout and denies reading it, so the byte-compare against
  `ambrogio/v2/api/android-chrome-512x512.png` — a branch the runner never takes — fires here;
  the pinned digest, the five pages' markup, the 40 px and the favicon all pass); the step's own
  check, `review-step67/verify-index-0.3.sh` → **OK**, 16 assertions over the page as the
  document nginx will serve (`review-step67/checks.log`). **The page was not rendered**: this
  cage carries no renderer — Chromium aborts on
  `FATAL:sandbox/linux/services/proc_util.cc:38 … Permission denied` (the policy denies it
  `/proc`) and the browser bridge is not offered on this transport — so the change is proved as
  markup, and the visual reading is left to the publish below. The live hostname is still the
  pre-0.3 page: `curl -sS https://ambrogio.tazlab.net/` → **200 4943**, byte-identical to
  `index.html` at `HEAD`, `grep -c 'Ambrogio 0.3'` → **0** (`review-step67/live-before.txt`).

## Next

1. **The four deep dives do not carry 0.3 yet.** The first page states the new version and the
   three changes it brought ([step #67]); the deep dives say nothing of them: `queues.html`
   still opens *«It is not a list of messages and not a git branch»*, `doors.html` gives the
   sandbox to the worker alone, and `agents.html` names no cage at all. Bring each page to what
   0.3 is, in its own words, with the engine's source read before it is written — the site is
   the product's public face, and a mechanism the product carries has to be readable there.
2. **The 0.3 line is in the source; the lane has to carry it.** The live `/` answers **200 4943**
   and does not carry the line ([step #67]; `review-step67/live-before.txt`). The publish is the
   one PROGETTO §7 already states, and nothing about it is new: push → the Action builds
   `tazzo/tazlab-ambrogio-site:ambrogio-site-<N>-<sha>` → Flux commits the tag into
   `apps/base/ambrogio-site/ambrogio-site.yaml` and rolls the Deployment; then read `/` back,
   with the line and the sentence on it, and the four deep dives as **200** — byte-for-byte the
   pages they are today.

## Open questions

- ~~Logo asset: the operator supplies or approves the mark before it is embedded.~~
  **Closed [step #45]:** the mark exists — `ambrogio/v2/api/ambrogio-mark.png` (27638 B,
  sha256 `7c37248e…`), the file the engine's own bar embeds; the site copies it unmodified
  (PROGETTO §3.1). **Superseded [step #49]:** the site now copies the icon set's largest,
  `android-chrome-512x512.png` (121,589 B, sha256 `626654ac…`), drawn at 40 px.
- ~~Font choice (default: Inter) to be confirmed at build time.~~
  **Closed [step #45]:** Inter, the variable WOFF2, self-hosted; the site copies no existing
  site's font (the blog uses a Google CDN, the wiki a system stack — both rejected) (PROGETTO
  §3.2).
- ~~**New [step #45], asset provenance to record at build time:** the Inter file must be fetched
  from the vendor's own release (SIL OFL 1.1) and its digest recorded in the repository, so the
  one font the site ships is a pinned file, not a download that drifts.~~
  **Closed [step #46]:** the file in the tree is byte-identical to
  `https://cdn.jsdelivr.net/npm/@fontsource-variable/inter/files/inter-latin-wght-normal.woff2`
  (48,256 B, sha256 `3100e775…`), and the URL, the size, the digest and the licence are recorded
  in `site/fonts/LICENSE-inter.txt`.
- ~~**New [step #45]:** the first pass under `ambrogio-site/site/` must be reconciled to the page
  set of PROGETTO §2/§4 (its `logo.svg` and light palette go).~~
  **Closed [step #46]:** the four mechanism pages are in place, `logo.svg` and the three
  first-pass pages are deleted, and `styles.css` carries the product's tokens.
