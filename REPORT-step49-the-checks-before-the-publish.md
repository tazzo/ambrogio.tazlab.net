# REPORT — step 49: the publish job runs the repository's own checks

Date: 2026-10-11. Tree: `/workspace/ambrogio-site`. Role: worker-external, queue 49.
Files: `.github/workflows/publish.yml`, `verify-project.sh`, `verify-logo-files.sh` (new),
`verify-logo.sh`, `PROGETTO.md` §5.5, `AVANZAMENTO.md`, the two evidence logs.

## What this step asked

*"Make `.github/workflows/publish.yml` run the cheap, offline checks before the docker
build-push step — `verify-project.sh`, and the file half of `verify-logo.sh` (site/logo.png
against the expected digest, the five pages' img attributes, the favicon's digest). The live
half must stay out of the workflow… The CI runner has only this repository, so the digest
expected of `site/logo.png` must be inline in the check rather than read from the sibling
checkout `/workspace/ambrogio`… Prove it by running the workflow's check step locally on this
tree (it must pass) and on a tree with a corrupted digest (it must fail)."*

## The gap, before the change

```
$ grep -n 'verify-project\|verify-logo\|verify-lane' .github/workflows/publish.yml
(no output)
$ ls .github/workflows/
publish.yml
```

Two scripts existed at the repository root — `verify-project.sh` (32 citations of
`PROGETTO.md`, from step 46) and `verify-logo.sh` (the mark, from step 49) — and the job that
publishes the site ran neither. A tree with a stale digest, a page that lost the mark's
dimensions or a document that cites a file that moved would be built, pushed to Docker Hub and
rolled out by Flux without anything saying so.

## What the job does now

`.github/workflows/publish.yml`, a step **after the checkout and before the Docker Hub login**
(so a tree that fails its own checks never touches the registry):

```yaml
      - name: The repository's own checks
        run: |
          sh verify-project.sh --in-repo
          sh verify-logo-files.sh
```

It is one `run:` block, so GitHub's default shell ends it at the first failure — the CI log of
the run below prints `shell: /usr/bin/bash -e {0}` on that step.

### `verify-project.sh --in-repo` (the mode is new)

A runner carries this repository and not the sibling trees the citations are written against
(`wiki.tazlab.net/`, `blog-src/`, `tazlab-k8s/`, `ambrogio/`), so the mode scopes the check to
what this checkout carries and **counts the rest out loud** rather than calling them missing:

```
$ sh verify-project.sh --in-repo
skipped        the mark's digest against the icon set's file (ambrogio/v2/api/android-chrome-512x512.png is a sibling checkout)
verify-project: checked 8 citations, 0 missing
verify-project: 24 citations are in sibling trees this checkout does not carry (run without --in-repo on the operator's machine)
```

The full mode is untouched on the operator's machine, where every citation is reachable:

```
$ sh verify-project.sh
verify-project: checked 32 citations, 0 missing
```

### `verify-logo-files.sh` (the file half, split out)

New file, and it is `verify-logo.sh`'s file half with no network and no sibling tree: the
**digest is pinned inline** (`121589` B / `626654ac…`) because the runner has nothing to read
it from, and both numbers can be overridden as arguments (`sh verify-logo-files.sh [sha] [size]`)
for a one-off reading. It checks:

1. `ambrogio-site/site/logo.png` against the pinned size and sha256, and — when the sibling
   checkout *is* there, which it is on the operator's machine — byte for byte against
   `ambrogio/v2/api/android-chrome-512x512.png`, saying so when it is not there;
2. the five pages carrying the file's own `width="512" height="512"`;
3. the drawn height the stylesheet states (`40 px`, the mark's own rule from step 49);
4. `favicon.ico`'s pinned size and sha256 — the tab's business, which this must not touch;
5. that the digest pinned in the script and the digest `PROGETTO.md` §3.1 names are the same
   number (two copies of one value, so they are read against each other).

`verify-logo.sh` now runs that half and then the live URL, so the two can no longer drift:

```
$ sh verify-logo.sh
== 1. the mark in the site … cmp site/logo.png == ambrogio/v2/api/android-chrome-512x512.png (byte for byte)
PROGETTO.md    names the same digest
== 2. the markup, on the five pages … pages 5 of 5 carry the file's own 512x512
== 3. the drawn height the stylesheet states … logo drawn 40 px tall (and as wide), expected 40
== 4. the favicon left alone … favicon unchanged (still the tab's favicon.ico)
VERIFY-LOGO-FILES: OK
== 5. the live URL
GET https://ambrogio.tazlab.net/logo.png -> 200 image/png 121589
live sha256    626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
cmp            live bytes == site/logo.png  (byte for byte)
VERIFY-LOGO: OK
```

### What deliberately stays off the runner

- **the live URL** — `https://ambrogio.tazlab.net/logo.png` is the *previous* deployment; a
  check of it says nothing about the image being built;
- **every citation that lives in a sibling tree** — the runner has no `wiki.tazlab.net/`,
  `blog-src/`, `tazlab-k8s/` or `ambrogio/` checkout.

Both are what `verify-logo.sh` and the full `verify-project.sh` are for, and both are run on
the operator's machine. `PROGETTO.md` §5.5 says all of this, next to the table of the publish
rule; `AVANZAMENTO.md` carries the step.

## The proofs

**The step passes where it must.** `evidence-checks-pass.log` — the step's own two commands, from
the repository root (rc 0); the same two commands in a container that carries this repository
only, no siblings (rc 0, and the "sibling … is not here" line prints exactly as it did on the
runner); and `sh verify-logo.sh` with the live half (rc 0).

**It fails where it must.** `evidence-checks-corrupt.log` — four corrupted copies, each in a
container carrying the copy only, each exiting **1**:

| corrupted | what the check said |
|---|---|
| `site/logo.png`, one byte flipped | `DIGEST MISMATCH  the page's mark is not the pinned file` → `VERIFY-LOGO-FILES: FAILURES` |
| `queues.html` drawing the mark at 256 | `pages  4 of 5 carry the file's own 512x512` → `FAILURES` |
| `PROGETTO.md` no longer naming `queues.html` | `PROGETTO.md does not name queues.html` → `verify-project: checked 8 citations, 1 missing` |
| `PROGETTO.md` naming a digest one character off | `PROGETTO.md does not name the mark's digest` (and, run alone, `DOC MISMATCH`) |

**And on the real runner.** The push that carried the change ran it
(`gh run view 38182410132 --repo tazzo/ambrogio.tazlab.net --log`, conclusion **success**):

```
The repository's own checks   ##[group]Run sh verify-project.sh --in-repo
The repository's own checks   shell: /usr/bin/bash -e {0}
The repository's own checks   verify-project: checked 8 citations, 0 missing
The repository's own checks   verify-project: 24 citations are in sibling trees this checkout does not carry
The repository's own checks   site/logo.png  121589 bytes  626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
The repository's own checks   sibling        /workspace/ambrogio/v2/api/android-chrome-512x512.png is not here (a runner carries this repository only)
The repository's own checks   pages          5 of 5 carry the file's own 512x512
The repository's own checks   logo drawn     40 px tall (and as wide), expected 40
The repository's own checks   favicon        unchanged (still the tab's favicon.ico)
The repository's own checks   VERIFY-LOGO-FILES: OK
Login to Docker Hub           Logging into docker.io…
Build and push                tags: tazzo/tazlab-ambrogio-site:ambrogio-site-7-93b88226…
```

The order in that log is the point: the checks, then the login, then the push. The run published
tag `ambrogio-site-7-93b88226…` and the live site still answers
`200 image/png 121589` / `626654ac…` after it (the image content is unchanged — the commit
touched no byte under `ambrogio-site/`, which is the build context).

## Limits

- **No deliberately red push.** The "fails the run" half is proven locally, not by pushing a
  broken tree to `main`: the step is one `run:` block under `bash -e`, both scripts exit 1 on a
  corrupted tree, and the combined command exits 1 on the corrupted copies (the log above). A
  red run on `main` would be operator-visible noise for a proof the step asked to be made
  locally.
- **Both runs of this step are green.** The one on the commit that added the step
  (`93b88226…`, run 38182410132) and the one on the final bytes — the report, the logs and the
  `PROGETTO.md` digest tie inside `verify-logo-files.sh` (`49f2c2d7…`, run 38182532293), whose
  check step printed `PROGETTO.md    names the same digest` and `VERIFY-LOGO-FILES: OK` before
  the login. Log excerpts: `evidence-checks-ci-run.log`.
- **The check reads the tree, not the image.** Nothing here runs the built image and fetches a
  page from it: a Dockerfile that copied the wrong directory would still publish. That is the
  next step, and it is declared as a child.

## Next

1. **A smoke test on the built image, before the push** — build with `load: true`, run it, fetch
   `/`, `/styles.css`, `/logo.png` and compare the served mark's digest with the pinned one;
   that is the only way to catch a Dockerfile that ships a different tree than the one checked.
2. The same publish shape is used by `blog-src`, `wiki.tazlab.net` and `teaching.tazlab.net`,
   and none of those workflows runs any check either — a gap in three other repositories, not in
   this one.
