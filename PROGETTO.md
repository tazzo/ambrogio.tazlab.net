# PROGETTO — `ambrogio.tazlab.net`

What the site will be, and exactly which artifacts bring it up. The lane it
follows is mapped and verified in `RICERCA.md` (§1–§10); this document only
fixes the fourth site's decisions on top of it.

## 1. What it is

`ambrogio.tazlab.net` is the public face of the Ambrogio project: **a small
static site served by nginx**. It explains what Ambrogio is and points to the
few things worth reading.

- **One main page** and **a few deep-dive pages** (the project's own story; no
  blog engine, no CMS).
- **Our logo** — one inline-SVG mark, the project's own.
- **One typeface** — a single self-hosted family (e.g. Inter), WOFF2, no CDN,
  same family for headings and body.
- **Minimal but professional**: plain, sober, fast, no JavaScript required to
  read a page.

## 2. The runtime — static files, no database, no service

- The pod is **static files only**: nginx `stable-alpine` serving a document root
  on port **80**. Nothing is computed at request time.
- **No database, no backend, no application server** — the image half is the
  static half of the lane, not the teaching site's service half.
- Single replica, like the other two static sites (`replicas: 1`).
- The nginx `Service` (port 80) and the `Ingress` are the plumbing that lets
  Traefik reach the pod; "no service" means no *application* service, exactly as
  for `hugo-blog` and `hugo-wiki` (`tazlab-k8s/apps/base/hugo-wiki/hugo-wiki.yaml:23-30`).

## 3. The builder decision

The other two static sites build with Hugo (`hugomods/hugo:std` → `hugo --minify`
→ `nginx:stable-alpine`). This site is small and fixed, so it is **plain static
HTML/CSS, no generator**: the pages are written once. The Dockerfile is then a
single nginx stage that copies the files — the shortest correct image half.

This is a deliberate departure only in the *image half*; the lane's **delivery
half is followed byte-for-byte** (RICERCA §1, §3–§6), which is what makes the
image half free to differ (blog/wiki and teaching already differ there).

Concrete image half:

```dockerfile
FROM nginx:stable-alpine
COPY site/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 4. The name — one copyable rule

`<x>` = **`ambrogio-site`** (fixed by the project-root `README.md`). Therefore:

- Docker Hub image: **`tazzo/tazlab-ambrogio-site`**
- Immutable tag: **`ambrogio-site-${github.run_number}-${github.sha}`** (plus `:latest`)
- Flux selector: **`filterTags.pattern: '^ambrogio-site-(?P<value>[0-9]+)-.*$'`**, `numerical: order: asc`
- Kubernetes app dir: `apps/base/ambrogio-site/`, overlay `apps/cluster/ambrogio-site/`
- Flux Kustomization: `clusters/tazlab-k8s/apps-ambrogio-site.yaml`, `path: ./apps/cluster/ambrogio-site`

## 5. The artifacts to lay down

**Source repo `ambrogio-site`** (static files + pipeline):

- `site/` — the pages (`index.html`, the deep-dive pages, `styles.css`,
  self-hosted font, the inline-SVG logo).
- `Dockerfile` — §3.
- `.github/workflows/publish.yml` — the `Publish Ambrogio Site` workflow, mirroring
  `blog-src/.github/workflows/publish.yml` (push to `master`; login to Docker
  Hub; push `tazzo/tazlab-ambrogio-site:latest` and
  `tazzo/tazlab-ambrogio-site:ambrogio-site-${run_number}-${sha}`).

**Cluster repo `tazlab-k8s`** (the Flux half, same shape as the three):

- `apps/base/ambrogio-site/ambrogio-site.yaml` — Deployment (nginx, port 80, `replicas: 1`),
  Service (port 80), Ingress (`host: ambrogio.tazlab.net`, class `traefik`,
  entrypoints `web, websecure`, `router.tls: "true"`), with the image line
  carrying the marker `# {"$imagepolicy": "flux-system:ambrogio-site"}`.
- `apps/base/ambrogio-site/certificate.yaml` — `Certificate` `ambrogio-tazlab.net-tls`,
  `issuerRef.name: letsencrypt-issuer`, `commonName: ambrogio.tazlab.net`, RSA-2048,
  `rotationPolicy: Always`.
- `apps/base/ambrogio-site/kustomization.yaml` — lists the two above.
- `apps/cluster/ambrogio-site/kustomization.yaml` — `resources: [../../base/ambrogio-site]`.
- `infrastructure/automation/ambrogio-site/automation.yaml` — ImageRepository +
  ImagePolicy (`^ambrogio-site-…`) + ImageUpdateAutomation (`update.path: ./apps/base/ambrogio-site`,
  `strategy: Setters`, commit `chore: self-update ambrogio-site image [skip ci]`).
- `infrastructure/automation/ambrogio-site/kustomization.yaml` — one resource.
- Registration: add `../automation/ambrogio-site` to
  `infrastructure/cluster-instances/kustomization.yaml`.
- `clusters/tazlab-k8s/apps-ambrogio-site.yaml` — the Flux Kustomization
  (`dependsOn: [infrastructure-configs]`, `path: ./apps/cluster/ambrogio-site`,
  `postBuild.substituteFrom ConfigMap/cluster-vars`).

**DNS**: none. `*.tazlab.net` is wildcard-resolved to the house IP and Traefik is
the MetalLB VIP `192.168.1.240` (RICERCA §7), so the hostname answers at the edge
before the Certificate exists.

## 6. Non-goals

- No database, no PVC, no backend, no auth, no analytics.
- No Hugo/generator unless the page count later justifies it.
- No new ClusterIssuer, no new Traefik entrypoint, no new MetalLB pool — the
  existing chassis carries it (RICERCA §7).

## 7. Definition of done

- `https://ambrogio.tazlab.net/` returns **200** with a valid Let's Encrypt chain.
- A push to `master` of `ambrogio-site` publishes
  `tazzo/tazlab-ambrogio-site:ambrogio-site-<N>-<sha>` and Flux commits the new tag
  into `apps/base/ambrogio-site/ambrogio-site.yaml` on its own, then rolls the
  Deployment.
- The pod serves only static files; `kubectl get deploy -n ambrogio-site` shows
  one ready replica.
