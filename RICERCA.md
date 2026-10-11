# RICERCA — The lane of the three sites, verified

Level: research. Scope: map the deployment lane shared by the three live sites
(`blog.tazlab.net`, `wiki.tazlab.net`, `teaching.tazlab.net`) from the wiki's own
pages, then **re-verify every claim against the live repositories** and fix the
naming rule the fourth site (`ambrogio.tazlab.net`) must follow.

Wiki pages read:
`wiki.tazlab.net/wiki/details/tazlab-k8s-hugo-wiki-detail.md`,
`wiki.tazlab.net/wiki/details/tazlab-k8s-hugo-blog-detail.md`,
`wiki.tazlab.net/wiki/details/tazlab-k8s-teaching-detail.md`,
`wiki.tazlab.net/wiki/topics/blog-publication-pipeline.md`,
`wiki.tazlab.net/wiki/details/tazlab-k8s-image-automation-detail.md`.

Repositories verified: `tazlab-k8s`, `wiki.tazlab.net`, `blog-src`,
`teaching.tazlab.net` (all under `/workspace`). Every citation below is
`path:line` read from the live tree; where the wiki disagrees with the tree, the
tree wins and the disagreement is recorded in §10.

---

## 1. The one lane — five stages

All three sites follow the same five-stage chain. Only the **image half**
(stages 1–2) differs per site; the **Flux half** (stages 3–5) is byte-for-byte
the same shape with the names swapped.

```
(1) source repo  --git push master-->  (2) GitHub Actions publish.yml
        |                                       |
        |                          builds image, pushes to Docker Hub as
        |                          tazzo/tazlab-<app>:<app>-<N>-<sha> (+ :latest)
        v                                       v
(3) Flux image automation  <--poll 1m--  Docker Hub registry
        ImageRepository + ImagePolicy + ImageUpdateAutomation
        (infrastructure/automation/<app>/automation.yaml)
        |  (4) commits the new tag into the marked image line of
        |      apps/base/<app>/<app>.yaml
        v
(5) Flux Kustomization  clusters/tazlab-k8s/<file>.yaml
        path ./apps/cluster/<app> -> overlay -> ../../base/<app>
        -> Deployment/Service/Ingress/Certificate reconcile and roll out
```

Verified end to end below. The Kubernetes app directory name is the app's short
name (`hugo-blog`, `hugo-wiki`, `teaching`); the Docker image short name is the
site's own name (`blog`, `wiki`, `teaching`).

---

## 2. Stage 1 — the source repository

| Site | Source repo (working dir) | Trigger | Citation |
|------|---------------------------|---------|----------|
| blog | `blog-src` | push to `master` | `blog-src/.github/workflows/publish.yml:1,4-6` (`name: Publish Blog`) |
| wiki | `wiki.tazlab.net` | push to `master` | `wiki.tazlab.net/.github/workflows/publish.yml:1,4-6` (`name: Publish Wiki`) |
| teaching | `teaching.tazlab.net` | push to `master` | `teaching.tazlab.net/.github/workflows/publish.yml:1,4-6` (`name: Publish Teaching`) |

All three are driven by a Git push to `master`; the workflow file is
`.github/workflows/publish.yml` in each repository.

---

## 3. Stage 2 — GitHub Actions builds and pushes the image

Each `publish.yml` logs in to Docker Hub and pushes **two tags**: a floating
`latest` and an immutable `<app>-<run_number>-<sha>`.

| Site | Image | Immutable tag | Citation |
|------|-------|---------------|----------|
| blog | `tazzo/tazlab-blog` | `blog-${run_number}-${sha}` | `blog-src/.github/workflows/publish.yml:29-30` |
| wiki | `tazzo/tazlab-wiki` | `wiki-${run_number}-${sha}` | `wiki.tazlab.net/.github/workflows/publish.yml:29-30` |
| teaching | `tazzo/tazlab-teaching` | `teaching-${run_number}-${sha}` | `teaching.tazlab.net/.github/workflows/publish.yml:83-84` |

The image half is not identical across the three:

- **blog / wiki (static Hugo → nginx)**: two-stage build. Stage 1
  `FROM hugomods/hugo:std AS builder`, `RUN hugo --minify`; stage 2
  `FROM nginx:stable-alpine`, `COPY --from=builder …/public /usr/share/nginx/html`,
  `EXPOSE 80`, `CMD ["nginx","-g","daemon off;"]`.
  Citations: `blog-src/Dockerfile:2,21,24,26,27`;
  `wiki.tazlab.net/Dockerfile:2,16,19,21,22`.
- **teaching (Python service)**: `FROM node:24-bookworm AS web` (Vite bundle) then
  `FROM python:3.14-slim`, `EXPOSE 8080`,
  `CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8080", …]`.
  Citations: `teaching.tazlab.net/Dockerfile:3,12,67,69`.

Teaching additionally gates publication on a test job: `build-and-push` carries
`needs: test` (`teaching.tazlab.net/.github/workflows/publish.yml:62-63`), so a red
suite stops the image; the two static sites publish unconditionally.

---

## 4. Stage 3 — Flux image automation

One directory per app: `tazlab-k8s/infrastructure/automation/<app>/automation.yaml`,
holding three Flux CRDs. Identical shape for all three, `interval: 1m`, only the
image, the tag pattern and the commit target change.

| Site | ImageRepository image | ImagePolicy `filterTags.pattern` | Update path | Citation |
|------|----------------------|-----------------------------------|-------------|----------|
| blog | `tazzo/tazlab-blog` | `^blog-(?P<value>[0-9]+)-.*$` | `./apps/base/hugo-blog` | `…/automation/hugo-blog/automation.yaml:7,22,47` |
| wiki | `tazzo/tazlab-wiki` | `^wiki-(?P<value>[0-9]+)-.*$` | `./apps/base/hugo-wiki` | `…/automation/hugo-wiki/automation.yaml:7,22,47` |
| teaching | `tazzo/tazlab-teaching` | `^teaching-(?P<value>[0-9]+)-.*$` | `./apps/base/teaching` | `…/automation/teaching/automation.yaml:7,22,47` |

Common to all three (same lines in each file): `interval: 1m` on the
ImageRepository (`:8`) and the ImageUpdateAutomation (`:31`); `policy.numerical.order: asc`
with `extract: '$value'` (`:18-23`); commit author `fluxcdbot@tazlab.net`
(`:40-42`), `messageTemplate: 'chore: self-update <app> image [skip ci]'` (`:43`),
push branch `master` (`:45`), `update.strategy: Setters` (`:48`).

---

## 5. Stage 4 — the commit target (base manifest + setter marker)

The ImageUpdateAutomation rewrites exactly the marked `image:` line inside
`apps/base/<app>/<app>.yaml`. The marker format is
`# {"$imagepolicy": "flux-system:<policy>"}`.

| Site | Base manifest | Image line + marker | Port | Citation |
|------|---------------|---------------------|------|----------|
| blog | `apps/base/hugo-blog/hugo-blog.yaml` | `tazzo/tazlab-blog:blog-91-… # {"$imagepolicy": "flux-system:hugo-blog"}` | 80 | `hugo-blog.yaml:5,19,21` |
| wiki | `apps/base/hugo-wiki/hugo-wiki.yaml` | `tazzo/tazlab-wiki:wiki-102-… # {"$imagepolicy": "flux-system:hugo-wiki"}` | 80 | `hugo-wiki.yaml:5,19,21` |
| teaching | `apps/base/teaching/teaching.yaml` | `tazzo/tazlab-teaching:teaching-28-… # {"$imagepolicy": "flux-system:teaching"}` | 8080 | `teaching.yaml:5,29,33` |

The Deployment, Service and Ingress live in this one file for blog/wiki; teaching
splits the redirect Ingress into `apps/base/teaching/redirect-ingress.yaml`. All
three are single-replica (`replicas: 1` at `:7` in each). The tags shown
(`blog-91`, `wiki-102`, `teaching-28`) are the current live values the automation
last wrote; they move on every publication, which is why only the marker string
is stable.

---

## 6. Stage 5 — the Flux Kustomization, and the overlay

Each site has one Flux `Kustomization` in `clusters/tazlab-k8s/` whose
`spec.path` points at its overlay, and the overlay points at the base.

| Site | Flux Kustomization file | `metadata.name` | `spec.path` | Citation |
|------|------------------------|-----------------|-------------|----------|
| blog | `clusters/tazlab-k8s/apps-static.yaml` | `apps-static` | `./apps/cluster/hugo-blog` | `apps-static.yaml:4,10` |
| wiki | `clusters/tazlab-k8s/apps-static-wiki.yaml` | `apps-static-wiki` | `./apps/cluster/hugo-wiki` | `apps-static-wiki.yaml:4,10` |
| teaching | `clusters/tazlab-k8s/apps-teaching.yaml` | `apps-teaching` | `./apps/cluster/teaching` | `apps-teaching.yaml:4,10` |

Each carries `dependsOn: [infrastructure-configs]` on the same line in all three
(`apps-static.yaml:7-8`, `apps-static-wiki.yaml:7-8`, `apps-teaching.yaml:7-8`),
plus `interval: 15m`, `prune: true`, `sourceRef GitRepository/flux-system`, and
`postBuild.substituteFrom ConfigMap/cluster-vars` (`:17-19`).

The overlay is a one-line pass-through to the base:

- `apps/cluster/hugo-blog/kustomization.yaml:4` → `- ../../base/hugo-blog`
- `apps/cluster/hugo-wiki/kustomization.yaml:4` → `- ../../base/hugo-wiki`
- `apps/cluster/teaching/kustomization.yaml:4` → `- ../../base/teaching`

These Flux Kustomizations are themselves applied by the cluster root: the
`flux-system` Kustomization reconciles `./clusters/tazlab-k8s`
(`clusters/tazlab-k8s/flux-system/gotk-sync.yaml:16-27`, `path: ./clusters/tazlab-k8s` at `:23`).

---

## 7. The shared chassis — ingress, TLS, Traefik, MetalLB

**Certificate (cert-manager)** — each site gets its own `Certificate`, all with
`issuerRef.name: letsencrypt-issuer` (`kind: ClusterIssuer`), RSA-2048,
`rotationPolicy: Always`:

| Site | Certificate / secret | `commonName` | `dnsNames` | Citation |
|------|----------------------|--------------|-----------|----------|
| blog | `blog-tazlab.net-tls` | `tazlab.net` | `blog.tazlab.net`, `tazlab.net`, `www.tazlab.net`, `lab.tazlab.net` | `apps/base/hugo-blog/certificate.yaml:4,9-16` |
| wiki | `wiki-tazlab.net-tls` | `wiki.tazlab.net` | `wiki.tazlab.net` | `apps/base/hugo-wiki/certificate.yaml:4,9-13` |
| teaching | `teaching-tazlab.net-tls` | `teaching.tazlab.net` | `teaching.tazlab.net` | `apps/base/teaching/certificate.yaml:4,9-13` |

The issuer is ACME production with an HTTP-01 solver over
`ingressClassName: traefik`:
`infrastructure/configs/cert-manager/issuer.yaml:2-14` (`name: letsencrypt-issuer`,
`server: https://acme-v02.api.letsencrypt.org/directory`). (A second ClusterIssuer,
`tazlab-issuer`, exists at `infrastructure/bridge/cluster-issuer.yaml:2-14`; the
three sites do **not** use it.)

**Ingress** — all three use `ingressClassName: traefik`, entrypoints
`web, websecure`, `router.tls: "true"`, TLS on the hostname:

- blog main ingress: `apps/base/hugo-blog/hugo-blog.yaml:49,52-55`
  (`host: blog.tazlab.net`, secret `blog-tazlab.net-tls`); a second
  `hugo-blog-redirect-ingress` (`:70-108`) serves `tazlab.net`,
  `www.tazlab.net`, `lab.tazlab.net` and redirects them to `blog.tazlab.net`
  via Middleware `hugo-blog-redirect-to-blog` (`apps/base/hugo-blog/middlewares.yaml:4-10`).
- wiki ingress: `apps/base/hugo-wiki/hugo-wiki.yaml:48,51-54` (`host: wiki.tazlab.net`).
- teaching ingress: `apps/base/teaching/teaching.yaml:119,122-125`
  (`host: teaching.tazlab.net`); teaching's HTTP→HTTPS redirect is a **separate,
  web-only** Ingress (`apps/base/teaching/redirect-ingress.yaml:12,16,18`) with
  Middleware `teaching-redirect-to-https` (`apps/base/teaching/middlewares.yaml:4-7`),
  `router.priority: "1"` so the cert-manager HTTP-01 solver router wins
  (`redirect-ingress.yaml:14`).

**Traefik** is a `LoadBalancer` fronted by MetalLB:
`infrastructure/operators/traefik/helmrelease.yaml:44` (`type: LoadBalancer`),
`:46` `metallb.universe.tf/loadBalancerIPs: "${traefik_lb_ip}"`, `:47`
`allow-shared-ip: "tazlab-internal-dashboard"`. The address in force is
**192.168.1.240** (the shared VIP other services pin explicitly, e.g.
`apps/base/hindsight/service-api.yaml:17`). `traefik_lb_ip` is a cluster variable
supplied by the `cluster-vars` ConfigMap through `postBuild.substituteFrom`
(`clusters/tazlab-k8s/apps-static.yaml:16-19`); the ConfigMap and the MetalLB
`IPAddressPool` are applied out of band and are not manifests in this repository.

---

## 8. The naming rule for the fourth artifact

> **A site named `<x>` publishes to Docker Hub as image `tazzo/tazlab-<x>` with the immutable tag `<x>-<run_number>-<sha>` (plus `:latest`), and Flux selects it with `filterTags.pattern: '^<x>-(?P<value>[0-9]+)-.*$'` (`numerical: order: asc`).**

For this project `<x>` = `ambrogio-site` — the project-root `README.md` fixes the
image name as `tazzo/tazlab-ambrogio-site` (the public hostname is
`ambrogio.tazlab.net`). So the fourth artifact is image
**`tazzo/tazlab-ambrogio-site`**, tag **`ambrogio-site-<N>-<sha>`**, Flux pattern
**`^ambrogio-site-(?P<value>[0-9]+)-.*$`**. The Flux half keeps the same names
with `<app>` = the Kubernetes slug `ambrogio-site`:
`apps/base/ambrogio-site/ambrogio-site.yaml` (the marked image line),
`apps/cluster/ambrogio-site/kustomization.yaml` (→ `../../base/ambrogio-site`),
`infrastructure/automation/ambrogio-site/automation.yaml`, and the Flux
Kustomization `clusters/tazlab-k8s/apps-ambrogio-site.yaml` with
`path: ./apps/cluster/ambrogio-site`.

The rule is mechanical because Flux picks the image up **by name**: the
ImagePolicy regex, the pushed tag and the Deployment marker must agree, or the
automation never fires.

---

## 9. Registration points a fourth app must not forget

A new app is invisible to Flux until its resources are referenced from the
kustomizations that build the cluster:

- `infrastructure/cluster-instances/kustomization.yaml:9` lists
  `../automation/teaching` — the fourth automation enters the same list.
- `apps/cluster/kustomization.yaml:4-5` lists `./hugo-blog` and `./mnemosyne-mcp`
  as the apps this overlay currently builds (the Hugo blog+wiki and teaching have
  their own Flux Kustomizations/paths).
- The Flux Kustomization file itself, inside `clusters/tazlab-k8s/`, is the only
  thing that registers the app's overlay with Flux
  (`clusters/tazlab-k8s/apps-teaching.yaml`, `:10`).

---

## 10. Discrepancies found — the wiki is stale in three places

The task said to re-verify, not trust. Three wiki claims do not match the tree:

1. **`details/tazlab-k8s-hugo-blog-detail.md` — blog certificate.** The page shows
   `issuerRef.name: tazlab-issuer` and `dnsNames: ["*.tazlab.net"]`. The live file
   is `issuerRef.name: letsencrypt-issuer` with four explicit `dnsNames`
   (`apps/base/hugo-blog/certificate.yaml:9,11-16`). No wildcard certificate is used.
2. **`details/tazlab-k8s-image-automation-detail.md` — "All 4 image automation
   pipelines".** Its inventory lists `hugo-blog`, `hugo-wiki`, `mnemosyne-mcp`,
   `homepage` and **omits `teaching`**. The live tree has six automation
   directories (`tazlab-k8s/infrastructure/automation/`), including
   `teaching/automation.yaml`. The same page's sibling topic
   (`topics/tazlab-k8s-image-automation.md`) also calls them "the three original
   pipelines" without teaching.
3. **Stale example tags** in the detail pages (`blog-47`, `wiki-2`, `teaching-4`)
   versus the live values (`blog-91`, `wiki-102`, `teaching-28`). Expected — the
   automation rewrites them — but worth knowing before copying an example.

Every claim in §2–§9 above was read from the tree, not carried over from the wiki.
