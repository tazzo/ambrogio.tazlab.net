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

## Next

1. **Build the site and its image half.** Scaffold the `ambrogio-site` repository
   (pages, logo, font, `Dockerfile`, `.github/workflows/publish.yml`), push, and
   confirm the first image lands on Docker Hub as
   `tazzo/tazlab-ambrogio-site:ambrogio-site-<N>-<sha>`.
2. **Wire the k8s half.** Add `apps/base/ambrogio-site/*`, `apps/cluster/ambrogio-site/*`,
   `infrastructure/automation/ambrogio-site/*`, the `cluster-instances` registration,
   and `clusters/tazlab-k8s/apps-ambrogio-site.yaml`; confirm Flux selects the tag,
   commits it into the marked image line, and serves
   `https://ambrogio.tazlab.net/` with a valid certificate (PROGETTO §5, §7).

## Open questions

- ~~Logo asset: the operator supplies or approves the mark before it is embedded.~~
  **Closed [step #45]:** the mark exists — `ambrogio/v2/api/ambrogio-mark.png` (27638 B,
  sha256 `7c37248e…`), the file the engine's own bar embeds; the site copies it unmodified
  (PROGETTO §3.1).
- ~~Font choice (default: Inter) to be confirmed at build time.~~
  **Closed [step #45]:** Inter, the variable WOFF2, self-hosted; the site copies no existing
  site's font (the blog uses a Google CDN, the wiki a system stack — both rejected) (PROGETTO
  §3.2).
- **New [step #45], asset provenance to record at build time:** the Inter file must be fetched
  from the vendor's own release (SIL OFL 1.1) and its digest recorded in the repository, so the
  one font the site ships is a pinned file, not a download that drifts.
- **New [step #45]:** the first pass under `ambrogio-site/site/` must be reconciled to the page
  set of PROGETTO §2/§4 (its `logo.svg` and light palette go).
