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

- Logo asset: the operator supplies or approves the mark before it is embedded.
- Font choice (default: Inter) to be confirmed at build time.
