# REPORT — step #47: the whole chain, from the commit to the pod answering at ambrogio.tazlab.net

Date: 2026-10-11. Role: worker-external (review).
**§6 was added by the step that closed finding 1** (the publish-branch fix): it records the
change made to `.github/workflows/publish.yml`, the deletion of the vestigial `origin/master`
ref, and the second full pass of the chain that the closing push ran (run #2 →
`ambrogio-site-2-a5ae413…` → the Automation's commit `8287717` → the pod on the new digest).
**§7 was added by the step that closed finding 3** (the kustomize-root fix): it records the
change in `/workspace/tazlab-k8s` (`f1884ad`, landed as `63c7ee7`) that puts the DB-wait patch
inside each consumer's own kustomize root, the byte-identical renders that prove the cluster does
not move, and the new check `tests/verify_overlays_build.sh`.
Tree: `/workspace/ambrogio-site` (the site's repository, on branch `main` — `602bf05` when this
review opened, `a5ae413` when the fix landed) and its
sibling `/workspace/tazlab-k8s` (reached through the in-tree symlink `tazlab-k8s`), the cluster
repository Flux reads.
Cluster: context `admin@tazlab-k8s`, server v1.35.0; `flux` 2.9.0, `kubectl` v1.31.14.
Host used for the measurement: the workstation this step runs on (DNS resolves
`ambrogio.tazlab.net` to 101.58.6.104, the lab's edge).

**The rule this step kept.** The cluster was touched only through Git: every `kubectl` call in
this report is a read (`get`, `logs`, `port-forward`), and nothing was applied by hand —
`kubectl apply`, `kubectl edit`, `flux reconcile` were never run. What the pod is running is
what the committed manifests say, and the manifests are what Flux applied from
`github.com/tazzo/tazlab-k8s@master`.

**What was asked**: verify, with evidence, that the lane built for `ambrogio.tazlab.net` works
end to end exactly as it does for the wiki, the blog and the teaching site, over five points.

---

## 1. The repository and its workflow

**The file.** `.github/workflows/publish.yml` — at the repository root, the only place GitHub
reads workflows, and the only file under `.github/`.

```
name: Publish Ambrogio Site
on:
  push:
    branches:
      - master
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with: {username: "roberto.tazzoli@gmail.com", password: ${{ secrets.DOCKER_PASSWORD }}}
      - uses: docker/build-push-action@v5
        with:
          context: ambrogio-site
          file: ambrogio-site/Dockerfile
          push: true
          tags: |
            tazzo/tazlab-ambrogio-site:latest
            tazzo/tazlab-ambrogio-site:ambrogio-site-${{ github.run_number }}-${{ github.sha }}
```

**The triggers.** `push` to `master`, and only that.

**The image name and the tag the Action produces.** `tazzo/tazlab-ambrogio-site`, published as
`:latest` **and** `:ambrogio-site-<run_number>-<sha>`.

**It ran.** GitHub's own record:

```
$ curl -s https://api.github.com/repos/tazzo/ambrogio.tazlab.net/actions/runs
total_count: 1
38175802839  Publish Ambrogio Site | event: push | branch: master | sha: d8a3bee3ba3e
             | run_number: 1 | status: completed | conclusion: success | 2026-10-11T21:18:15Z
```

**The registry carries the tag.** Docker Hub, `tazzo/tazlab-ambrogio-site`:

```
latest                                                digest sha256:b05f71ac…56679  26,169,377 B  2026-10-11T21:19:28Z
ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416  digest sha256:b05f71ac…56679  26,169,377 B  2026-10-11T21:19:30Z
```

One digest, two tags — `latest` and the immutable `<app>-<run>-<sha>`. The sha in the tag is the
commit that ran: `d8a3bee ambrogio-site: publish the first image` (the tree's `origin/master`).

**Same shape as the three live lanes** (their workflows read this step, and their registries):
`blog-src` publishes `tazzo/tazlab-blog:blog-<run>-<sha>` (`blog-91-c10cf249…`),
`wiki.tazlab.net` → `tazzo/tazlab-wiki:wiki-<run>-<sha>` (`wiki-103-4e2b32c1…`),
`teaching.tazlab.net` → `tazzo/tazlab-teaching:teaching-<run>-<sha>` (`teaching-28-3897107a…`).
All three workflows trigger on `push: branches: [master]` and log in with the same Docker Hub
account. `ambrogio-site` differs only in adding `context:`/`file:` (its repository root also
carries the project's documents) and dropping `submodules: recursive` (it has no submodules).

*One departure from the three, kept and flagged in §5: this checkout's branch is `main`, not
`master`.*

---

## 2. Flux

**The Kustomization is picked up by the root scan.** The root scan is a directory-scan:
`clusters/tazlab-k8s/flux-system/gotk-sync.yaml` defines

```
GitRepository/flux-system  → url https://github.com/tazzo/tazlab-k8s, ref branch master, interval 1m
Kustomization/flux-system  → path ./clusters/tazlab-k8s, prune true, interval 10m
```

so every file in `clusters/tazlab-k8s/` is applied, `apps-ambrogio-site.yaml` among them
(`grep -n ambrogio clusters/tazlab-k8s/*.yaml` → lines 4 and 10). The cluster agrees:

```
$ kubectl -n flux-system get kustomization apps-ambrogio-site
NAME                  READY   STATUS
apps-ambrogio-site    True    Applied revision: master@sha1:7c6111554fd83186743790354f26804be56527a8
```

The manifest is field-for-field `apps-static-wiki.yaml` with the names swapped — `diff` of the
two (name-normalized) prints **nothing**, so it is identical to the wiki's lane. Its `spec`
carries `dependsOn: infrastructure-configs`, `path: ./apps/cluster/ambrogio-site`, `prune: true`,
`sourceRef: GitRepository/flux-system`, `postBuild.substituteFrom: ConfigMap/cluster-vars`.

**Its two registrations are in the scans that matter.**

```
infrastructure/operators/core/kustomization.yaml:4-11   … - ../hugo-blog, ../hugo-wiki, ../teaching, ../ambrogio-site
infrastructure/cluster-instances/kustomization.yaml:11  - ../automation/ambrogio-site
```

Cluster truth: `Namespace/ambrogio-site` is Active (20m) and the three image objects exist —
they could only have come through those two registrations.

**The ImageRepository reads the registry.**

```
$ kubectl -n flux-system get imagerepository ambrogio-site -o yaml   (status)
canonicalImageName: index.docker.io/tazzo/tazlab-ambrogio-site
message: 'successful scan: found 2 tags with checksum 316216631'
lastScanResult: {latestTags: [latest, ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416],
                 tagCount: 2, revision: "316216631", scanTime: 2026-10-11T21:40:52Z}
Ready: True
```

`spec.image: tazzo/tazlab-ambrogio-site`, `interval: 1m`.

**The ImagePolicy's pattern matches the tags the Action produces.**
`filterTags.pattern: '^ambrogio-site-(?P<value>[0-9]+)-.*$'`, `extract: '$value'`,
`policy.numerical: {order: asc}`. Applied to the two tags the registry actually carries:

```
latest                                                    -> NO MATCH   (correctly ignored)
ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416  -> value "1"
```

and the controller resolved exactly that:

```
$ kubectl -n flux-system get imagepolicy ambrogio-site -o yaml   (status)
latestRef: {name: tazzo/tazlab-ambrogio-site, tag: ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416}
message: Latest image tag for tazzo/tazlab-ambrogio-site resolved to ambrogio-site-1-d8a3bee…
Ready: True
```

**The ImageUpdateAutomation commits the tag into the app's manifest.**

```
$ kubectl -n flux-system get imageupdateautomation ambrogio-site -o yaml   (status)
lastPushCommit: 7c6111554fd83186743790354f26804be56527a8
lastPushTime:   2026-10-11T21:20:46Z
message:        repository up-to-date        Ready: True
```

`spec`: `sourceRef GitRepository/flux-system`, `git.checkout.ref.branch: master`,
`commit.author fluxcdbot <fluxcdbot@tazlab.net>`,
`messageTemplate: 'chore: self-update ambrogio-site image [skip ci]'`,
`push.branch: master`, `update.path: ./apps/base/ambrogio-site`, `update.strategy: Setters`.
That commit is real and it is the change:

```
$ git -C /workspace/tazlab-k8s show --stat --format='%H%n%an <%ae>%n%s' 7c61115
7c6111554fd83186743790354f26804be56527a8
fluxcdbot <fluxcdbot@tazlab.net>
chore: self-update ambrogio-site image [skip ci]

 apps/base/ambrogio-site/ambrogio-site.yaml | 2 +-
-          image: tazzo/tazlab-ambrogio-site:latest # {"$imagepolicy": "flux-system:ambrogio-site"}
+          image: tazzo/tazlab-ambrogio-site:ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416 # {"$imagepolicy": "flux-system:ambrogio-site"}
```

and the automation pushed it — `origin/master` in `/workspace/tazlab-k8s` is that commit
(`git rev-parse HEAD origin/master` → both `7c61115…`), which is also the revision the root scan
applied. The setter marker `{"$imagepolicy": "flux-system:ambrogio-site"}` is intact, so the
next publish will be picked up the same way.

---

## 3. The pod

**Installed in its namespace, Deployment ready, Service answering, Ingress carrying the TLS
certificate:**

```
$ kubectl -n ambrogio-site get deploy,po,svc,ingress,certificate,rs,ep -o wide
deployment.apps/ambrogio-site   1/1   1   1   18m   web   tazzo/tazlab-ambrogio-site:ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416
pod/ambrogio-site-7fb9f865df-svltq   1/1   Running   0   12m   10.244.1.69   talos-k24-4z0
service/ambrogio-site   ClusterIP   10.99.58.66   <none>   80/TCP   app=ambrogio-site
ingress.networking.k8s.io/ambrogio-site-ingress   traefik   ambrogio.tazlab.net   192.168.1.240   80,443
certificate.cert-manager.io/ambrogio-tazlab.net-tls   True   ambrogio-tazlab.net-tls   letsencrypt-issuer   Certificate is up to date and has not expired
endpoints/ambrogio-site   10.244.1.69:80
```

The Deployment runs the one thing the chain agreed on — the tag the Action produced, the tag the
ImagePolicy selected, the tag the Automation wrote:

```
$ kubectl -n ambrogio-site get deploy ambrogio-site -o jsonpath='{.spec.template.spec.containers[0].image}'
tazzo/tazlab-ambrogio-site:ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416
$ kubectl -n flux-system get imagepolicy ambrogio-site -o jsonpath='{.status.latestRef.tag}'
ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416
$ curl -s https://hub.docker.com/v2/repositories/tazzo/tazlab-ambrogio-site/tags | jq '.results[1]'
{"name": "ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416",
 "digest": "sha256:b05f71aca4e2a962b1febf513bffdf9a000ff0d76825d4e245cabca787c56679", …}
```

**Byte-for-byte, the pod runs what the Action pushed**: the pod's own imageID is the registry's
digest for that tag —

```
$ kubectl -n ambrogio-site get pod -l app=ambrogio-site -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'
docker.io/tazzo/tazlab-ambrogio-site@sha256:b05f71aca4e2a962b1febf513bffdf9a000ff0d76825d4e245cabca787c56679
```

**The Service answers** (proved through the Service object, read-only port-forward; no `apply`):

```
$ kubectl -n ambrogio-site port-forward svc/ambrogio-site 18099:80 &
$ for p in / /queues.html /doors.html /hands.html /conversation.html /styles.css /logo.png /favicon.ico /fonts/inter.woff2; do
    curl -s -o /dev/null -w '%{http_code} %{content_type} %{size_download}\n' http://127.0.0.1:18099$p; done
/                 200 text/html     3928
/queues.html      200 text/html     5574
/doors.html       200 text/html     4349
/hands.html       200 text/html     4609
/conversation.html 200 text/html    4064
/styles.css       200 text/css      5259
/logo.png         200 image/png     27638
/favicon.ico      200 image/x-icon  15086
/fonts/inter.woff2 200 font/woff2   48256
```

and the pod's own nginx access log shows those very requests arriving inside the container:

```
$ kubectl -n ambrogio-site logs deploy/ambrogio-site --tail=5
127.0.0.1 - - [11/Oct/2026:21:36:50 +0000] "GET /conversation.html HTTP/1.1" 200 4064
127.0.0.1 - - [11/Oct/2026:21:36:50 +0000] "GET /styles.css HTTP/1.1" 200 5259
127.0.0.1 - - [11/Oct/2026:21:36:50 +0000] "GET /logo.png HTTP/1.1" 200 27638
```

**The Ingress carries the certificate for the hostname.** Ingress class `traefik`, host
`ambrogio.tazlab.net`, `tls.secretName: ambrogio-tazlab.net-tls`; `Certificate/ambrogio-tazlab.net-tls`
is `Ready=True`, `notAfter 2027-01-09T20:19:25Z`, issued by `ClusterIssuer/letsencrypt-issuer`
(RSA-2048, `rotationPolicy: Always`); the secret exists with `type kubernetes.io/tls`. The
certificate the edge actually serves:

```
$ echo | openssl s_client -connect ambrogio.tazlab.net:443 -servername ambrogio.tazlab.net | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
subject=CN = ambrogio.tazlab.net
issuer=C = US, O = Let's Encrypt, CN = YR1
notBefore=Oct 11 20:19:26 2026 GMT   notAfter=Jan  9 20:19:25 2027 GMT
X509v3 Subject Alternative Name: DNS:ambrogio.tazlab.net
```

`certificate.yaml` is byte-identical to `apps/base/hugo-wiki/certificate.yaml` after the name
swap — the wiki's lane exactly.

---

## 4. The site, over HTTPS and in a real browser

**Over HTTPS at the hostname** (curl, plus the TLS verification result the client computed):

```
$ for p in / /index.html /queues.html /doors.html /hands.html /conversation.html /styles.css /logo.png /favicon.ico /fonts/inter.woff2; do
    curl -s -o /dev/null -w '%{http_code} %{content_type} %{size_download} %{ssl_verify_result}\n' --max-time 25 https://ambrogio.tazlab.net$p; done
/                    200 text/html     3928 0
/index.html          200 text/html     3928 0
/queues.html         200 text/html     5574 0
/doors.html          200 text/html     4349 0
/hands.html          200 text/html     4609 0
/conversation.html   200 text/html     4064 0
/styles.css          200 text/css      5259 0
/logo.png            200 image/png     27638 0
/favicon.ico         200 image/x-icon  15086 0
/fonts/inter.woff2   200 font/woff2    48256 0
```

`ssl_verify_result 0` on every one: the chain validates, and the hostname matches.

**The pages render — measured in a real browser, not inferred.** `review-step47/measure-render.py`
drives the box's Chromium (Chrome/131.0.6778.33, the `~/.cache/ms-playwright/chromium-1148`
binary) over CDP, at a phone width (390×844, DPR 3, mobile) and a desktop width (1440×900, DPR 1),
and reads the result out of the live DOM plus Chrome's own Network domain. Full machine-readable
output: `review-step47/render-report.json`.

| width | page | status | title | h1 | cards | viewport | page (scroll) | logo natural → rendered | console errors | exceptions |
|---|---|---|---|---|---|---|---|---|---|---|
| phone | `/` | 200 | Ambrogio — the agent orchestrator of tazlab.net | Ambrogio | 4 | 390×844 | 390×2051 | 192×192 → 28×28 | 0 | 0 |
| phone | `/queues.html` | 200 | The queues, and who accepts them — Ambrogio | The queues, and who accepts them | – | 390×844 | 390×3069 | 192×192 → 28×28 | 0 | 0 |
| phone | `/doors.html` | 200 | The two doors, and the sandbox — Ambrogio | The two doors, and the sandbox | – | 390×844 | 390×2381 | 192×192 → 28×28 | 0 | 0 |
| phone | `/hands.html` | 200 | The hands, the budget and the silence — Ambrogio | The hands, the budget and the silence | – | 390×844 | 390×2485 | 192×192 → 28×28 | 0 | 0 |
| phone | `/conversation.html` | 200 | The conversation — Ambrogio | The conversation | – | 390×844 | 390×2269 | 192×192 → 28×28 | 0 | 0 |
| desktop | `/` | 200 | Ambrogio — the agent orchestrator of tazlab.net | Ambrogio | 4 | 1440×900 | 1440×1295 | 192×192 → 28×28 | 0 | 0 |
| desktop | `/queues.html` | 200 | The queues, and who accepts them — Ambrogio | The queues, and who accepts them | – | 1440×900 | 1440×2088 | 192×192 → 28×28 | 0 | 0 |
| desktop | `/doors.html` | 200 | The two doors, and the sandbox — Ambrogio | The two doors, and the sandbox | – | 1440×900 | 1440×1681 | 192×192 → 28×28 | 0 | 0 |
| desktop | `/hands.html` | 200 | The hands, the budget and the silence — Ambrogio | The hands, the budget and the silence | – | 1440×900 | 1440×1768 | 192×192 → 28×28 | 0 | 0 |
| desktop | `/conversation.html` | 200 | The conversation — Ambrogio | The conversation | – | 1440×900 | 1440×1626 | 192×192 → 28×28 | 0 | 0 |

**The logo loads**: `naturalWidth`/`naturalHeight` = 192×192 (a broken image would be 0×0), laid
out at 28×28, and Chrome's Network domain recorded `https://ambrogio.tazlab.net/logo.png → 200`
on every page, as it did for `styles.css` and `fonts/inter.woff2`. Body font resolves to
`Inter, system-ui, … 17px` and the background to `rgb(20, 22, 26)` — the stylesheet applied
(a page served without its CSS would report the UA defaults, not these). No page raised a
console error or an exception, and no page overflows horizontally (`scrollWidth == innerWidth`
at 390 and at 1440).

**Screenshots** (full page, captured by Chrome at that emulated width):

- `review-step47/shot-phone-390x844.png` — 760,844 B, full page 390×2051.
- `review-step47/shot-desktop-1440x900.png` — 208,600 B, full page 1440×1295.

Both were then inspected: the phone shot shows the single-column layout, the header logo
rendered (a blue/teal mark, not a placeholder), eyebrow "AGENT ORCHESTRATOR", the h1 "Ambrogio",
and the four cards in one column; the desktop shot shows the header logo, the left navigation
with "Home" active, and the four cards in a **2×2 grid**. Dark theme, blue accent, consistent
typography — styled, not broken.

**The Chrome was closed, and that was measured.** The measured exit state, from the run's own
report:

```
chromeBeforeMachine: 13      chromeMineAfter: 0
chromeBeforeMine:    0      chromeOpenedByThisTaskLeftBehind: 0
pgrepChromeAfter:    13      failures: []
```

The 13 are **not this task's**: they are the `omp`-managed puppeteer Chromium
(`/workspace/.tazpod/.omp/puppeteer/chrome/…/chrome --user-data-dir=/tmp/ambrogio-probe-…`)
launched by a *different* session's Go test — `go test ./v2/api -run
TestTheBoardIsFourCardsOnAGridAndEachOneOpens` in `/workspace/ambrogio/v2/api` — which this task
did not open and must not kill. This task's Chrome is the ms-playwright binary with a private
`--user-data-dir=/tmp/chrome-review-*`; the script counts chrome processes by the binary each is
running from (`/proc/<pid>/exe`), so the count that speaks for this task is the one whose binary
is the ms-playwright Chromium: **0 before, 0 after, nothing left behind**. Checked again, outside
the script and without a shell (so `pgrep` cannot match its own command line, `pgrep -c chrome`
and `pgrep -c -f ms-playwright/chromium-1148` both exit non-zero = no match for mine). Later, when
the foreign Go test had finished, a plain `pgrep -c chrome` on the box read **0**.

---

## 5. What did not work, and why

1. **The publish branch is `main` here, but the workflow triggers on `master` — a live trap.**
   This checkout's branch is `main` (`git config branch.main.merge` → `refs/heads/main`, and no
   `remote.origin.push` override), while `publish.yml` fires on `push: branches: [master]`.
   So a plain `git push` in `/workspace/ambrogio-site` lands on `origin/main` and publishes
   **nothing**. It did not break anything today only because the publish commit was pushed
   explicitly as `main:master` — `origin/main` and `origin/master` are both `d8a3bee`, and run
   #1 ran on branch `master`. The three reference lanes have no such gap: their checkout is on
   `master` (`blog-src`, `wiki.tazlab.net`, `teaching.tazlab.net` all report branch `master`
   tracking `refs/heads/master`), so a plain push triggers the build.
   **CLOSED by the fix below (§6)**: `publish.yml` now fires on `main`, the branch the checkout
   carries and this repository's default, and the vestigial `origin/master` ref — the artifact
   of the `main:master` push — is gone. Proven by run #2 firing on `main`.

2. **`docker` needs `sudo`, and the container needs `--security-opt apparmor=unconfined`** on
   this nested host (its AppArmor policy cannot load `docker-default`). `docker.io` was installed
   in step 46; `sudo` is passwordless here. This is environmental, not a defect of the lane, and
   `verify-lane.sh` records it — but anyone reproducing the local build must know it.

3. **`kubectl kustomize infrastructure/cluster-instances` fails under the default load
   restrictions**, on a *pre-existing* path unrelated to this lane: `infrastructure/instances/pgadmin`
   uses a PatchTransformer at `../../common/wait-for-db-patch.yaml`, which kustomize v5 refuses
   outside the root. With `--load-restrictor LoadRestrictionsNone` it builds `rc=0`, and Flux's
   kustomize-controller loads unrestricted, so the cluster is unaffected. The same is true of
   `tests/verify_manifest_purity.sh`, which exits 1 on `instances/longhorn`,
   `operators/traefik`, `instances/homepage`, `instances/tazlab-db` — all pre-existing, none of
   them `ambrogio-site`.
   **CLOSED by §7**: the patch now lives inside each consumer's own kustomize root, so
   `kubectl kustomize infrastructure/instances` and `infrastructure/cluster-instances` (and
   `apps/cluster/mnemosyne-mcp`) build plainly, the rendered manifests are byte-identical, and
   `tests/verify_overlays_build.sh` now checks every root in the repository.

4. **`/workspace/tazlab-k8s` had a dirty working tree when this review opened** — in-flight work
   not authored by the review: `apps/base/mnemosyne-mcp/kustomization.yaml`,
   `apps/base/mnemosyne-mcp/wait-for-db-patch.yaml`,
   `infrastructure/instances/pgadmin/{kustomization.yaml,wait-for-db-patch.yaml}`, and a deletion
   of `infrastructure/common/wait-for-db-patch.yaml`. `git status --porcelain | grep -i ambrogio`
   → none: nothing in flight touched this lane, and Flux reads the remote, not this working tree.
   **Step #49 landed it** (verified byte-for-byte, with the check of §7) because it *is* the fix
   finding 3 asked for; see §7 for what was taken on and how it was verified.

5. **`pgrep -c chrome` has no clean zero baseline on this box** because of the foreign Go test's
   puppeteer Chromium (§4). Handled by counting by binary; recorded here so the next reader does
   not mistake those 13 processes for an orphan left by this step.

6. **Cosmetic residue**: the ReplicaSet `ambrogio-site-5b9dc9bdbc` (image `:latest`, 0 replicas)
   remains from the first apply, before the automation pinned the tag. Harmless, pruned by the
   ReplicaSet controller's history limit.

**Nothing in the chain itself failed.** There was no red condition to explain: the workflow ran
green, the ImageRepository/ImagePolicy/ImageUpdateAutomation are all `Ready=True`, the
Kustomization applied, the Deployment is 1/1, the pod runs the exact digest the
Action pushed, the Service answers, the Ingress is TLS-terminated with a valid Let's Encrypt
certificate for the hostname, and the browser renders all five pages at both widths with the logo
and the stylesheet loaded.

---

## 6. The fix applied by step #48: the publish branch now matches the checkout

**What changed.**

1. `.github/workflows/publish.yml` — the trigger is now the branch the checkout carries, which is
   also this repository's default branch, with a comment naming the reason:

```
on:
  # `main` is this repository's default branch and the branch the checkout carries; the
  # wiki, the blog and the teaching site are published on push to the branch they carry,
  # and this site used to watch `master` while every push went to `main` — a push that
  # published nothing (step 47, finding 1).  Keep this name in step with the default
  # branch: `gh api repos/tazzo/ambrogio.tazlab.net --jq .default_branch`.
  push:
    branches:
      - main
```

2. The vestigial `origin/master` ref is gone. It existed only because the step-46 publish was
   pushed as `main:master`; it pointed at an ancestor of `main` (`d8a3bee`), nothing tracked or
   consumed it, and while it lived there were two names for one branch, one of which the workflow
   ignored — a push there would have been published nothing, the same defect from the other side.

```
$ git push origin --delete master
 - [deleted]         master
$ git ls-remote --heads origin
a5ae413a0c0ef67edb8cf3318a811a31b3ec1ccb        refs/heads/main      # the only branch, and the default
$ curl -s https://api.github.com/repos/tazzo/ambrogio.tazlab.net | jq -r .default_branch
main
```

The repository's other local-only commits went with it: `git push origin main` carried `602bf05`
(the step-46 report and `verify-lane.sh`), `b6fcaab` (this review) and `a5ae413` (the fix) to
`origin/main`, so local `main` and `origin/main` are one line again. The convention is now:
everything lives on `main`, and pushing `main` is what publishes.

**The proof: an ordinary push on `main` ran the whole chain again.** The push of `a5ae413` — the
commit that carries the fix — fired run #2 by itself, because GitHub evaluates the workflow of
the pushed commit, so the same push that fixes the trigger is also its first use:

```
$ curl -s https://api.github.com/repos/tazzo/ambrogio.tazlab.net/actions/runs
2  Publish Ambrogio Site | event: push | branch: main | sha: a5ae413 | run_number: 2 | completed | success | 21:44:14Z  (38177595383)
1  Publish Ambrogio Site | event: push | branch: master | sha: d8a3bee | run_number: 1 | completed | success | 21:18:15Z
```

and it published the tag the chain expects:

```
$ curl -s 'https://hub.docker.com/v2/repositories/tazzo/tazlab-ambrogio-site/tags'
ambrogio-site-2-a5ae413a0c0ef67edb8cf3318a811a31b3ec1ccb  digest sha256:252cc464…f3a18  26,169,378 B  21:44:34Z
ambrogio-site-1-d8a3bee3ba3ef7087ff14b480d38064bec6fa416  digest sha256:b05f71ac…56679  26,169,377 B  21:19:30Z
latest                                                    digest sha256:252cc464…f3a18  26,169,378 B  21:44:31Z
```

Flux read it, resolved it, and committed it, exactly as it did the first time:

```
$ kubectl -n flux-system get imagerepository ambrogio-site -o jsonpath='{.status.lastScanResult.tagCount}:{.status.lastScanResult.scanTime}'
3:2026-10-11T21:44:53Z
$ kubectl -n flux-system get imagepolicy ambrogio-site -o jsonpath='{.status.latestRef.tag}'
ambrogio-site-2-a5ae413a0c0ef67edb8cf3318a811a31b3ec1ccb
$ kubectl -n flux-system get imageupdateautomation ambrogio-site -o jsonpath='{.status.lastPushCommit}:{.status.lastPushTime}:{.status.conditions[0].message}'
828771705f5c9fc670bf6cf1fb84ab7bea4acb83:2026-10-11T21:44:56Z:repository up-to-date
$ git -C /workspace/tazlab-k8s log --oneline -2 origin/master
8287717 chore: self-update ambrogio-site image [skip ci]
7c61115 chore: self-update ambrogio-site image [skip ci]
$ git -C /workspace/tazlab-k8s show origin/master:apps/base/ambrogio-site/ambrogio-site.yaml | grep 'image: tazzo'
image: tazzo/tazlab-ambrogio-site:ambrogio-site-2-a5ae413a0c0ef67edb8cf3318a811a31b3ec1ccb # {"$imagepolicy": "flux-system:ambrogio-site"}
```

and the cluster rolled onto it — the Kustomization applied the new revision, the Deployment took
the new tag, the pod runs the new digest, ready and answering:

```
$ kubectl -n flux-system get kustomization apps-ambrogio-site -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}'
Applied revision: master@sha1:828771705f5c9fc670bf6cf1fb84ab7bea4acb83
$ kubectl -n ambrogio-site get deploy ambrogio-site -o jsonpath='{.spec.template.spec.containers[0].image}'
tazzo/tazlab-ambrogio-site:ambrogio-site-2-a5ae413a0c0ef67edb8cf3318a811a31b3ec1ccb
$ kubectl -n ambrogio-site get pod -l app=ambrogio-site -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'
docker.io/tazzo/tazlab-ambrogio-site@sha256:252cc464111ba0e26774945d266541951ce684d605c039e0521cde03a66f3a18
$ kubectl -n ambrogio-site get deploy ambrogio-site -o jsonpath='{.status.readyReplicas}/{.status.replicas}'    → 1/1
$ curl -s -o /dev/null -w '%{http_code} %{ssl_verify_result} %{size_download}' https://ambrogio.tazlab.net/   → 200 0 3928
```

The pod's digest (`sha256:252cc464…`) is, byte for byte, the registry's digest for the tag run #2
published, so the second pass of the chain closes end to end exactly as the first one did. The
image is one byte larger than run #1's (26,169,378 vs 26,169,377) because it was rebuilt; the
site's own files are unchanged.

Because the publish branch watches *every* push to `main`, so does this repository's
documentation: a docs-only commit mints a tag and rolls the pod — the same behaviour the wiki,
the blog and the teaching site have. That is not a guess: the commit that carried the previous
revision of this report (`f017e89`, documentation only) was pushed, and it ran **run #3** on `main`
(`success`, 21:47Z), published `ambrogio-site-3-f017e8932af30ea3bdd331ef71e36c7c646ac01d`, and
the Automation committed it as `e32a44a` — the Deployment took that tag and the pod is on its
digest. If the behaviour is ever unwanted the fix is a `paths-ignore` on the workflow, not a
change of branch; it is not applied here.

---

## 7. The fix applied by step #49: every kustomize root holds its own patches, and a check says so

**The defect, restated.** `infrastructure/instances/pgadmin/kustomization.yaml` pointed its
PatchTransformer at `../../common/wait-for-db-patch.yaml`, and
`apps/base/mnemosyne-mcp/kustomization.yaml` at `../../../infrastructure/common/wait-for-db-patch.yaml`.
Both paths escape their own kustomize root, which kustomize v5 refuses under its default load
restrictions — so `kubectl kustomize infrastructure/instances` and
`kubectl kustomize infrastructure/cluster-instances` did not build at all, and built only with
`--load-restrictor LoadRestrictionsNone`. Flux was never affected (its kustomize-controller loads
unrestricted), which is exactly why the defect could sit there: the cluster looked right while a
plain build disagreed with it.

**What this step took on.** The working tree already carried the repair, uncommitted, when the
step opened (pgadmin and mnemosyne-mcp repointed at a local copy, `infrastructure/common/`
deleted) — §5 finding 4. Landing it *is* what finding 3 asks for, and the two halves cannot be
split (committing pgadmin alone while the deletion stayed uncommitted would leave mnemosyne-mcp
pointing at a file the commit had removed), so this step adopted both, verified them, and added
the check. This is stated plainly because the diff is not all first-authored here.

**The change, in `/workspace/tazlab-k8s`** (one commit):

```
$ git show --stat --format='%s' f1884ad
kustomize roots: keep the DB-wait patch inside each root, and check that every root builds plainly
 5 files changed, 108 insertions(+), 2 deletions(-)
 rename {infrastructure/common => apps/base/mnemosyne-mcp}/wait-for-db-patch.yaml (100%)
 create mode 100644 infrastructure/instances/pgadmin/wait-for-db-patch.yaml
 create mode 100755 tests/verify_overlays_build.sh
```

```
$ git diff
 apps/base/mnemosyne-mcp/kustomization.yaml
-  - path: ../../../infrastructure/common/wait-for-db-patch.yaml
+  - path: wait-for-db-patch.yaml
 infrastructure/instances/pgadmin/kustomization.yaml
-  - path: ../../common/wait-for-db-patch.yaml
+  - path: wait-for-db-patch.yaml
 infrastructure/common/wait-for-db-patch.yaml      → deleted (its content lives on, unchanged, in the two roots that use it)
```

**Before — proved on a read-only worktree of the pre-fix commit** (`git worktree add
/tmp/k8s-head HEAD`, removed afterwards; the working tree was never disturbed):

```
$ kubectl kustomize /tmp/k8s-head/infrastructure/instances
error: accumulating resources: … accumulating resources from 'pgadmin': …/:pgadmin' must resolve
to a file': … trouble configuring builtin PatchTransformer            → exit ≠ 0
$ kubectl kustomize /tmp/k8s-head/infrastructure/cluster-instances   → exit ≠ 0 (same, via ../instances)
$ kubectl kustomize /tmp/k8s-head/apps/cluster/mnemosyne-mcp         → exit ≠ 0 (same, via ../../base)
$ kubectl kustomize --load-restrictor LoadRestrictionsNone /tmp/k8s-head/infrastructure/instances
                                                                     → exit 0  (the old workaround)
```

**After — plainly, no restrictor flag:**

```
$ kubectl kustomize infrastructure/instances                 → exit 0
$ kubectl kustomize infrastructure/cluster-instances         → exit 0
$ kubectl kustomize apps/cluster/mnemosyne-mcp               → exit 0
$ sh tests/verify_overlays_build.sh                          → exit 0
  OK    65 roots build plainly (4 known-broken, listed in this script)
VERIFY-OVERLAYS: OK
```

**Nothing in the cluster changes — the renders are byte-identical.** This is the check that makes
the repair safe to land, and it is stronger than "it builds":

| overlay | before (pre-fix commit + `LoadRestrictionsNone`) | after (plain) | sha256 (both) |
|---|---|---|---|
| `infrastructure/instances` | 37,053 B | 37,053 B | `f6fe59f8b9942599…` |
| `infrastructure/cluster-instances` | 44,122 B | 44,122 B | `beb4b815d19db7e4…` |
| `apps/cluster/mnemosyne-mcp` | 3,578 B | 3,578 B | `c2f39acc06873a9e…` |

`diff` of each before/after pair prints nothing; the pgadmin Deployment still carries its
`wait-for-db` initContainer, and the overlay still renders its 14 kinds (Deployment, Ingress,
Job, Namespace, PostgresCluster, VaultPKISecret, …). So the patch still applies — it is only the
path to it that moved.

**And the cluster agrees it was a no-op.** After the push, Flux took the new revision and both
consumers re-applied it (the namespace `tazlab-db` holds both workloads):

```
$ kubectl -n flux-system get gitrepository flux-system -o jsonpath='{.status.artifact.revision}'
master@sha1:63c7ee7027cadda82157450db2c29f07112a115d
$ kubectl -n flux-system get kustomization infrastructure-instances -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}'
Applied revision: master@sha1:63c7ee7027cadda82157450db2c29f07112a115d
$ kubectl -n flux-system get kustomization apps-data               → same revision, Ready=True
$ kubectl -n tazlab-db get deploy pgadmin        -o jsonpath=…  → generation 109, resourceVersion 43067172, initContainer wait-for-db
$ kubectl -n tazlab-db get deploy mnemosyne-mcp  -o jsonpath=…  → generation 109, resourceVersion 43051708, initContainer wait-for-db
pods: identical names, creationTimestamps and pod-template-hashes before and after the reconcile
all 28 Flux Kustomizations: Ready=True
```

Generation, resourceVersion and the pods are unchanged across the reconcile: Flux applied the new
commit and **no workload was restarted**, which is what a pure path repair must look like.

The push itself was rebased once: `origin/master` had moved (three `chore: self-update
ambrogio-site image [skip ci]` commits from the ImageUpdateAutomation, one per ambrogio-site tag
minted in §6), none of them touching these files, so the commit landed on top as `63c7ee7`.

**The check: `tests/verify_overlays_build.sh`** (new, 2,773 B, `sh`-runnable from anywhere, exit
0 when every root builds). It walks all 65 kustomization roots under `infrastructure/`, `apps/`
and `clusters/`, runs `kubectl kustomize` with the *default* load restrictions on each, and:

- fails on any root that does not build unless it is listed in `KNOWN_BROKEN` with a reason;
- fails if a listed root starts building — so the list cannot rot;
- prints the reason for each known-broken root.

The four roots that still cannot build plainly are all pre-existing and unrelated to the pgadmin
fix, and the script names each one's cause:

| root | why it cannot build plainly |
|---|---|
| `infrastructure/operators/namespaces` | references `../monitoring/namespace.yaml`, outside its own root |
| `infrastructure/operators/vso-secrets` | references `../vso/vaultconnection.yaml`, outside its own root |
| `infrastructure/operators` | accumulates `operators/namespaces`, which fails above |
| `infrastructure/tls` | `kustomization.yaml` is empty |

**The check catches the regression it was written for.** Copied into the pre-fix worktree and run
there, it exits 1 and names the culprits — `infrastructure/instances/pgadmin`,
`infrastructure/instances`, `infrastructure/cluster-instances`, `apps/base/mnemosyne-mcp` — so it
is not a check that passes by construction.

**Nothing runs the check yet.** `tazlab-k8s` has no CI at all (no `.github/`, no `Makefile`, and
`tests/` holds only this script and `verify_manifest_purity.sh`), so the gate exists but nobody
pulls it. Wiring it into a runner is a decision for the operator, and it is the first child
below.

```
$ sh /workspace/ambrogio-site/verify-lane.sh
== 1. docker build      Successfully tagged tazzo/tazlab-ambrogio-site:local
== 2. serve             11 rows, every one 200 with the right content type
== 3. manifests         5 × kustomize ok, yaml ok 11 manifest files parse, all docs
== 4. live and registry live https 200 0; registry tags 2
VERIFY-LANE: OK          (exit 0)
```

(The run above is the one this review made. The registry carries several tags since — one per
push to the publish branch, §6 — and `verify-lane.sh` only requires a non-zero count.)

## The single command that reproduces the browser half

```
$ python3 /workspace/ambrogio-site/review-step47/measure-render.py
… full JSON report …   RENDER-REVIEW: OK   (exit 0)
```

It writes `review-step47/render-report.json` and the two screenshots, and exits 1 if any page
does not answer 200, the logo does not decode, a subresource 404s, a page raises a script error,
a page overflows horizontally, or this task's Chrome is still running when it returns.

## Verdict

**The chain is whole**: the commit publishes an image whose bytes the pod is running, and the
pages answer over HTTPS and render correctly at phone and desktop widths.

Both defects this review found are **closed**: the publish workflow watching `master` while every
push went to `main` (§6 — `publish.yml` now watches `main`, the branch the checkout carries and
the repository's default; the vestigial `origin/master` ref is deleted; the closing push fired
run #2 on `main`, published `ambrogio-site-2-a5ae413…`, and Flux read, resolved, committed and
rolled onto it), and the `pgadmin`/`mnemosyne-mcp` PatchTransformers escaping their kustomize
roots (§7 — the patch now lives in each consumer's own root, the two overlays build with a plain
`kubectl kustomize`, the rendered manifests are byte-identical so no workload moved, and
`tazlab-k8s/tests/verify_overlays_build.sh` checks every root in the repository).

What remains open is what the check now makes visible and cannot fix by itself: the three other
roots that still cannot build plainly (`infrastructure/operators/namespaces`,
`infrastructure/operators/vso-secrets`, and the empty `infrastructure/tls`), the fact that nothing
in `tazlab-k8s` runs the check (the repository has no CI), and the observation that a docs-only
push to a publish branch mints an image tag, as it does for the wiki, the blog and the teaching
site.
