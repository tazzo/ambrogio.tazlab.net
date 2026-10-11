# REPORT — step #46: the site built, and its lane in place

Date: 2026-10-11. Tree: `/workspace/ambrogio-site` (source) and `/workspace/tazlab-k8s` (cluster).
Role: worker-external.

## What this step asked

Build the site (`/workspace/ambrogio-site`: the pages, the stylesheet, the mark taken from the
Ambrogio repository, the `Dockerfile`, `.github/workflows/publish.yml`) and put its lane in
`/workspace/tazlab-k8s` in the exact shape the three live sites use, then prove the image builds
and serves and that the manifests parse.

## State found, and what this step did with it

The tree already carried the lane, committed, when the step opened:

- `ambrogio-site` (branch `main`, also pushed as `origin/master`, HEAD `d8a3bee`): the five
  pages, the mark, the font, the `Dockerfile`, the publish workflow at the repository root, and
  the commit `ambrogio-site: publish the first image`.
- `tazlab-k8s` (branch `master`, HEAD `7c61115`): `bcfdd19` "the Flux half (namespace, base,
  overlay, image automation, Kustomization)", `834636b` "the pod's probes and resource limits",
  and `7c61115` — a real ImageUpdateAutomation commit, `chore: self-update ambrogio-site image
  [skip ci]`, author `fluxcdbot <fluxcdbot@tazlab.net>`.

So this step did **not** author the files afresh: it verified every path the assignment names,
rebuild the image locally (`docker` was absent from the box and was installed — see Limits), ran
the container and fetched every page over HTTP, parsed every manifest, and confirmed the live
site. All outputs are below.

## The source half — `/workspace/ambrogio-site`

Pages live under `ambrogio-site/site/`; the Dockerfile is `ambrogio-site/Dockerfile` (build
context `ambrogio-site`); the workflow is at the repository root, `.github/workflows/publish.yml`,
which is the only place GitHub reads it.

| path | size | sha256 (first 16) |
|---|---|---|
| `ambrogio-site/site/index.html` | 3928 | `222dd5b0bfe34580` |
| `ambrogio-site/site/queues.html` | 5574 | `ddcfbdfb56529e9e` |
| `ambrogio-site/site/doors.html` | 4349 | `03d205cc6d8115be` |
| `ambrogio-site/site/hands.html` | 4609 | `786be7d0bfd142a6` |
| `ambrogio-site/site/conversation.html` | 4064 | `fcee79c2cb1becbb` |
| `ambrogio-site/site/styles.css` | 5259 | `a28a745b375c66e1` |
| `ambrogio-site/site/logo.png` | 27638 | `7c37248e6cbfb2a5` |
| `ambrogio-site/site/favicon.ico` | 15086 | `b88644a59fa5dad9` |
| `ambrogio-site/site/fonts/inter.woff2` | 48256 | `3100e775e8616cd2` |
| `ambrogio-site/Dockerfile` | 226 | — |
| `.github/workflows/publish.yml` | — | — |

Provenance, measured this step (sha256 compared byte for byte):

- `site/logo.png` == `/workspace/ambrogio/v2/api/ambrogio-mark.png`, both
  `27638 B / 7c37248e6cbfb2a5a00b92a22b8c93aa93591743757ad0b21319d92a10a5f0e6` (**IDENTICAL**).
- `site/favicon.ico` == `/workspace/ambrogio/v2/api/favicon.ico`, both
  `15086 B / b88644a59fa5dad99bf7aa9371ee52b8e2da5d24f1e6f31d45943500bf40377f` (**IDENTICAL**).
- Titles: index `Ambrogio — the agent orchestrator of tazlab.net`; the four deep dives
  `The queues, and who accepts them — Ambrogio`, `The two doors, and the sandbox — Ambrogio`,
  `The hands, the budget and the silence — Ambrogio`, `The conversation — Ambrogio`.
- No third-party request: the only absolute `href`s on the pages are plain
  `https://tazlab.net` hyperlinks; `styles.css` has one `url()` — `fonts/inter.woff2`,
  self-hosted.

`Dockerfile` (the wiki's and the blog's last three lines, per PROGETTO §5.1):

```
FROM nginx:stable-alpine
COPY site/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

`publish.yml` mirrors `blog-src/.github/workflows/publish.yml` and
`wiki.tazlab.net/.github/workflows/publish.yml`: trigger `push: branches: [master]`;
`actions/checkout@v4`; `docker/login-action@v3` with `roberto.tazzoli@gmail.com` +
`secrets.DOCKER_PASSWORD`; `docker/build-push-action@v5`, `push: true`, tags
`tazzo/tazlab-ambrogio-site:latest` and
`tazzo/tazlab-ambrogio-site:ambrogio-site-${{ github.run_number }}-${{ github.sha }}`. It adds
`context: ambrogio-site` / `file: ambrogio-site/Dockerfile` because the repository root also
carries the project's documents, and drops `submodules: recursive` (the repo has none).

## The image half — built and served locally (measured)

`docker` was not installed on the box; `docker.io` 29.1.3 was installed from Ubuntu noble and the
daemon started by systemd. Build (the same context and file the workflow uses):

```
$ cd /workspace/ambrogio-site/ambrogio-site && sudo docker build -t tazzo/tazlab-ambrogio-site:local .
Step 1/4 : FROM nginx:stable-alpine
 ---> 0985e772fb9f
Step 2/4 : COPY site/ /usr/share/nginx/html
 ---> 05b0ecabd76f
Step 3/4 : EXPOSE 80
Step 4/4 : CMD ["nginx", "-g", "daemon off;"]
Successfully built 502d2accbc4f
Successfully tagged tazzo/tazlab-ambrogio-site:local
```

`docker image ls` → `tazzo/tazlab-ambrogio-site:local 502d2accbc4f 93MB`; `docker history` shows
the base is the pulled `nginx:stable-alpine` (`NGINX_VERSION=1.30.5`, alpine 3.24.2 minirootfs).

Run and fetch (the container needs `--security-opt apparmor=unconfined` on this nested host,
whose AppArmor policy cannot load `docker-default`):

```
$ sudo docker run -d --name ambrogio-site-test --security-opt apparmor=unconfined -p 18080:80 tazzo/tazlab-ambrogio-site:local
$ sudo docker exec ambrogio-site-test ls /usr/share/nginx/html
conversation.html  doors.html  fonts  favicon.ico  hands.html  index.html  logo.png  queues.html  styles.css
$ for p in ...; do curl -s -o /dev/null -w '%{http_code} %{content_type} %{size_download}' http://127.0.0.1:18080$p; done
/                       200 text/html     3928
/index.html             200 text/html     3928
/queues.html            200 text/html     5574
/doors.html             200 text/html     4349
/hands.html             200 text/html     4609
/conversation.html      200 text/html     4064
/styles.css             200 text/css      5259
/logo.png               200 image/png    27638
/favicon.ico            200 image/x-icon 15086
/fonts/inter.woff2      200 font/woff2   48256
/fonts/LICENSE-inter.txt 200 text/plain  5311
```

Body probe on `/`: the operator's claim sentence is present (`"keeps the trace of what is done"`),
**0** `<script` tags, **4** `class="card"` cards.

## The cluster half — `/workspace/tazlab-k8s`

Eleven files in four directories, the shape of `hugo-wiki`/`apps-static-wiki`:

| # | path | contents |
|---|---|---|
| 1 | `infrastructure/operators/ambrogio-site/namespace.yaml` | `Namespace/ambrogio-site` |
| 2 | `infrastructure/operators/ambrogio-site/kustomization.yaml` | `resources: [namespace.yaml]` |
| 3 | `infrastructure/operators/core/kustomization.yaml` | **registration**: `… - ../ambrogio-site` |
| 4 | `apps/base/ambrogio-site/ambrogio-site.yaml` | Deployment + Service + Ingress, 3 docs |
| 5 | `apps/base/ambrogio-site/certificate.yaml` | `Certificate/ambrogio-tazlab.net-tls` |
| 6 | `apps/base/ambrogio-site/kustomization.yaml` | `resources: [ambrogio-site.yaml, certificate.yaml]` |
| 7 | `apps/cluster/ambrogio-site/kustomization.yaml` | `resources: [../../base/ambrogio-site]` |
| 8 | `clusters/tazlab-k8s/apps-ambrogio-site.yaml` | Flux `Kustomization/apps-ambrogio-site` |
| 9 | `infrastructure/automation/ambrogio-site/automation.yaml` | ImageRepository + ImagePolicy + ImageUpdateAutomation |
| 10 | `infrastructure/automation/ambrogio-site/kustomization.yaml` | `resources: [automation.yaml]` |
| 11 | `infrastructure/cluster-instances/kustomization.yaml` | **registration**: `… - ../automation/ambrogio-site` |

Shape compared to the references (read this step):

- `apps/base/ambrogio-site/ambrogio-site.yaml` — Deployment `ambrogio-site`/ns `ambrogio-site`,
  `replicas: 1`, container `web`, `containerPort: 80`, the marked image line; Service
  `ambrogio-site`, `port: 80 → targetPort: 80`; Ingress `ambrogio-site-ingress`,
  `ingressClassName: traefik`, the two Traefik annotations plus the `gethomepage.dev/*` trio the
  wiki and the blog also carry, TLS host `ambrogio.tazlab.net`, secret `ambrogio-tazlab.net-tls`.
  It adds the two probes (`teaching.yaml:62-72`, path `/`) and the resource requests
  `10m/16Mi → 200m/64Mi` that PROGETTO §5.3–§5.4 fixes; the two static sites carry neither.
- `certificate.yaml` — same as `apps/base/hugo-wiki/certificate.yaml`: `letsencrypt-issuer` /
  `ClusterIssuer`, `commonName`/`dnsNames` `ambrogio.tazlab.net`, RSA-2048, `rotationPolicy:
  Always`.
- `apps-ambrogio-site.yaml` — field for field `apps-static-wiki.yaml` with the names swapped:
  `dependsOn infrastructure-configs`, `interval: 15m`, `path: ./apps/cluster/ambrogio-site`,
  `prune: true`, `sourceRef flux-system`, `timeout: 5m`, `postBuild.substituteFrom
  ConfigMap/cluster-vars`.
- `automation.yaml` — `interval: 1m`, `filterTags.pattern '^ambrogio-site-(?P<value>[0-9]+)-.*$'`,
  `extract '$value'`, `numerical: order: asc`, commit author `fluxcdbot@tazlab.net`,
  `messageTemplate: 'chore: self-update ambrogio-site image [skip ci]'`, push `master`,
  `update.path: ./apps/base/ambrogio-site`, `strategy: Setters`.

## Manifests parse — the commands and their output

`kubectl` v1.31.14 (kustomize v5.4.2):

```
$ kubectl kustomize /workspace/tazlab-k8s/apps/cluster/ambrogio-site
rc=0  kinds=['Service','Deployment','Certificate','Ingress']
$ kubectl kustomize /workspace/tazlab-k8s/infrastructure/automation/ambrogio-site
rc=0  kinds=['ImagePolicy','ImageRepository','ImageUpdateAutomation']
$ kubectl kustomize /workspace/tazlab-k8s/infrastructure/operators/ambrogio-site
rc=0  kinds=['Namespace']
$ kubectl kustomize /workspace/tazlab-k8s/infrastructure/operators/core
rc=0  kinds=['Namespace'×8,'HelmRelease'×2,'HelmRepository'×2]
$ kubectl kustomize --load-restrictor LoadRestrictionsNone /workspace/tazlab-k8s/infrastructure/cluster-instances
rc=0
```

Every one of the eleven files also parses as YAML (python `yaml.safe_load_all`), with the kinds
tabled above. `sh /workspace/ambrogio-site/verify-project.sh` → `checked 31 citations, 0 missing`.

## The live lane, verified

- Docker Hub `tazzo/tazlab-ambrogio-site`, `count 2`:
  `latest` (26,169,377 B, pushed 2026-10-11T21:19:28Z) and
  `ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416` (pushed 21:19:30Z) — the rule's
  `<app>-<run>-<sha>` tag, produced by run #1 of the workflow.
- The Deployment's marked image line carries exactly that tag,
  `tazzo/tazlab-ambrogio-site:ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416 # {"$imagepolicy": "flux-system:ambrogio-site"}`,
  and `tazlab-k8s` HEAD is the ImageUpdateAutomation commit that wrote it.
- `https://ambrogio.tazlab.net/` → `200 text/html 3928`, `/queues.html` → `200 text/html 5574`,
  `/logo.png` → `200 image/png 27638`, `ssl_verify_result 0`, subject `CN=ambrogio.tazlab.net`,
  issuer `Let's Encrypt` (chain valid).

## The naming rule, as the three sites use it

`blog-src`, `wiki.tazlab.net`, `teaching.tazlab.net` all publish image `tazzo/tazlab-<x>` with
the immutable tag `<x>-<run_number>-<sha>` (plus `:latest`), and Flux selects it with
`filterTags.pattern: '^<x>-(?P<value>[0-9]+)-.*$'`. For this site `<x>` = `ambrogio-site`:

| piece | value |
|---|---|
| Docker Hub image | `tazzo/tazlab-ambrogio-site` |
| tags pushed | `:latest`, `:ambrogio-site-<run_number>-<sha>` |
| ImagePolicy pattern | `^ambrogio-site-(?P<value>[0-9]+)-.*$`, `extract '$value'`, `asc` |
| setter marker | `# {"$imagepolicy": "flux-system:ambrogio-site"}` |
| Kubernetes namespace | `ambrogio-site` |
| Flux Kustomization | `apps-ambrogio-site`, `path: ./apps/cluster/ambrogio-site` |
| hostname | `ambrogio.tazlab.net`, secret `ambrogio-tazlab.net-tls` |

## Limits and findings

- **`docker` was absent**; `docker.io` was installed to satisfy the "the local image builds"
  acceptance. A container also needs `--security-opt apparmor=unconfined` on this host (a nested
  AppArmor cannot load `docker-default`).
- `kubectl kustomize infrastructure/cluster-instances` (plain, default restrictions) fails — but
  on a **pre-existing** path, not on this registration: `infrastructure/instances/pgadmin` uses a
  PatchTransformer at `../../common/wait-for-db-patch.yaml`, which kustomize v5 refuses outside
  the root. `kubectl kustomize infrastructure/instances` fails identically with the ambrogio
  registration untouched, and with `LoadRestrictionsNone` the whole overlay builds `rc=0`. Flux's
  kustomize-controller loads unrestricted, so the cluster is unaffected — the same file already
  drives `hugo-blog`/`hugo-wiki`/`teaching`.
- `tests/verify_manifest_purity.sh` exits 1 on matches in `instances/longhorn`,
  `operators/traefik`, `instances/homepage`, `instances/tazlab-db` — all pre-existing, none in
  `ambrogio-site`.
- The `apps/base/ambrogio-site/ambrogio-site.yaml` image line reads a published tag, not
  `:latest`, because the lane already ran once; the marker is what matters and it is intact.

## The check that reproduces all of it

`sh /workspace/ambrogio-site/verify-lane.sh` runs the four stages above — build, serve, parse,
live — and exits 0 only when every page answers 200 and every overlay builds. Output on this
tree: `Successfully tagged tazzo/tazlab-ambrogio-site:local`, the eleven-row 200 matrix, five
`kustomize ok`, `yaml ok 11 manifest files parse`, `live https 200 0`, `registry tags 2`,
`VERIFY-LANE: OK`.

## Next

Nothing in the assignment is outstanding. One follow-up remains worth a step: the pre-existing
`infrastructure/instances/pgadmin` patch path, if the plain-`kubectl` build of
`cluster-instances` is ever wanted as a CI check.
