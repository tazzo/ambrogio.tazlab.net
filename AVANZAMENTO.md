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
    (the queues and who accepts them; the two doors and the sandbox; the hands, the budget
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
  `hands.html`, `conversation.html` — and the first pass' `what-it-does.html`,
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

## Next

1. **Publish, and verify the site end to end.** The source is reconciled ([step #46]) and the
   k8s half is already wired in `/workspace/tazlab-k8s` (`apps/base/ambrogio-site/*`,
   `apps/cluster/ambrogio-site/*`, `infrastructure/automation/ambrogio-site/*`, the
   `cluster-instances` registration and `clusters/tazlab-k8s/apps-ambrogio-site.yaml`; the
   marked image line still reads `:latest`). Push the source to `master`, confirm Docker Hub
   carries `tazzo/tazlab-ambrogio-site:ambrogio-site-<N>-<sha>`, confirm Flux commits the tag
   into `apps/base/ambrogio-site/ambrogio-site.yaml` and rolls the Deployment, then check that
   the five pages answer **200** over HTTPS with a valid Let's Encrypt chain and that the mark,
   the favicon and the woff2 are served (PROGETTO §7).

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
