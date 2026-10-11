# PROGETTO — `ambrogio.tazlab.net`

The design of the site that presents Ambrogio: **what it says** (the structure), **how it
looks** (the mark, the typeface, the palette), **the pod that serves it**, and **the pages,
file by file**. Every choice that copies an existing site names the file and the line it was
read from; every choice that does not is argued on its own.

The delivery lane is already mapped and re-verified against the live repositories in
`RICERCA.md` (§1–§10); this document only fixes the site's own decisions on top of it.

### What was read to write this

| what | where |
|---|---|
| the delivery lane | `RICERCA.md` §1–§10 (itself read from the trees below) |
| the image half, wiki | `wiki.tazlab.net/Dockerfile:2,19-22` |
| the image half, blog | `blog-src/Dockerfile:24-27` |
| the static pod, wiki | `tazlab-k8s/apps/base/hugo-wiki/hugo-wiki.yaml` (whole file) |
| the static pod, blog | `tazlab-k8s/apps/base/hugo-blog/hugo-blog.yaml` (whole file) |
| probes and resources | `tazlab-k8s/apps/base/teaching/teaching.yaml:56-89` |
| requests are not optional | `tazlab-k8s/apps/base/buzz/helmrelease.yaml:141-142` (TD-105) |
| the two smaller services | `tazlab-k8s/apps/base/mnemosyne-mcp/deployment.yaml:52-58`, `tazlab-k8s/apps/base/hindsight/deployment-dashboard.yaml:60-66` |
| the publish workflow | `blog-src/.github/workflows/publish.yml:4-6,22-25,28-30`; `wiki.tazlab.net/.github/workflows/publish.yml` (same shape) |
| the Flux half | `tazlab-k8s/infrastructure/automation/hugo-wiki/automation.yaml:7-8,19-23,31,43-48`; `tazlab-k8s/clusters/tazlab-k8s/apps-static-wiki.yaml:4-10,17-19` |
| the mark | `ambrogio/v2/api/ambrogio-mark.png` (27638 B, sha256 `7c37248e…`), and `ambrogio/REPORT-task32-the-new-icons.md` §2–§4 |
| the product's colours and face | `ambrogio/v2/api/ui/app.css:15-16,24` |
| the product's own account | `ambrogio/README.md` §2 (queues), §3 (urgency), §4 (the two doors), §5 (the review), §6 (the trace), §7 (the sandbox), §9 (what is not done) |

---

## 1. What the site is

`ambrogio.tazlab.net` is the **public face of the Ambrogio project**: a small static site
that says what the orchestrator is and then explains its mechanisms well enough that an
engineer who has never seen it can decide whether to trust it. It is **not** the hub — the hub
is a binary beside one SQLite file on the operator's machine (`ambrogio/README.md` §8); the
site is a description of it, and it holds no data.

- audience: an engineer reading about the lab, and the operator's future self;
- language: English, everywhere (UI strings included);
- five pages of plain HTML and one stylesheet; no JavaScript required to read any page;
- no login, no CMS, no analytics, no third-party request.

The main page's claim is the operator's own, in one paragraph: **Ambrogio keeps the trace of
what is done; it gives order and documentation to every movement; and its own internal agents
keep it correct.** Everything else on the site is that sentence, spent properly.

---

## 2. The structure — one main page, four deep dives, a side menu

```
ambrogio.tazlab.net
├── index.html            the main page: what this orchestrator is, in a few lines
├── queues.html           deep dive 1 — the queues, and who accepts them
├── doors.html            deep dive 2 — the two doors, and the sandbox
├── hands.html            deep dive 3 — the hands, the budget and the silence
└── conversation.html     deep dive 4 — the conversation
```

**Why four deep dives and not two.** The assignment allows two to four pages on the
mechanisms and names four; each is a different question asked by a different worry, and
merging any two would put two unrelated anxieties on one page:

1. **order** — where does work come from, and who is allowed to start it? (`queues.html`)
2. **boundary** — what may an agent touch on my machine, and who can ask for what? (`doors.html`)
3. **bound** — what stops a hand: its slots, its budget, its silence? (`hands.html`)
4. **the chat** — what is the thing the operator actually talks to? (`conversation.html`)

Four is the top of the allowed range and the site is still five pages: it is the smallest set
in which no page answers two questions at once. There is **no "About" page**: "where Ambrogio
sits in tazlab.net" is three lines at the foot of the main page, not a mechanism.

**The menu** is a **side menu** — a left column, present on every page, listing the four deep
dives plus Home, with the current page marked `aria-current="page"`. It is built from plain
`<a>` elements: no script, no menu state to keep. Below 720 px it collapses to a horizontal
row under the header, by CSS only; nothing is hidden behind a button that needs JavaScript.

**One-page-one-question rule.** Each deep dive opens with the question it answers and closes
with what is *not* true of it (the honest edge), so a reader can leave with the boundary, not
just the pitch.

---

## 3. The visual decisions

### 3.1 The mark — the operator's own art, unmodified

The logo is the file the Ambrogio project already uses, copied byte for byte:

- source: `ambrogio/v2/api/ambrogio-mark.png` — 192×192 RGBA PNG, **27638 B**, sha256
  `7c37248e6cbfb2a5a00b92a22b8c93aa93591743757ad0b21319d92a10a5f0e6`;
- destination: `site/logo.png`, identical bytes;
- it is the file the engine's own bar embeds, and it is **byte-identical to
  `android-chrome-192x192.png`** (`ambrogio/REPORT-task32-the-new-icons.md` §2, §4);
- 192 px is the right source: the header draws it in a **28 px box**, so `192/28 = 6.9` covers
  every realistic device-pixel ratio, and the engine's own comment is written for the 192
  (`REPORT-task32-the-new-icons.md` §4);
- **not re-coloured, not redrawn.** The operator's word is that the delivered colours read on
  both a dark and a light ground (`REPORT-task32-the-new-icons.md` §4); a redraw or a
  `markderive` pass would be a *different* mark, which is not ours to make;
- the favicon is the engine's own `favicon.ico` (three frames, 16/32/48, built in
  `REPORT-task32-the-new-icons.md` §3), copied to `site/favicon.ico`. Same art, same tab.

### 3.2 One typeface — Inter, self-hosted

One family, one file: **Inter**, the variable WOFF2 (weights 100–900), self-hosted as
`site/fonts/inter.woff2` and declared by a single `@font-face`. The variable file is what makes
"one typeface" true in practice: one file serves the headings, the body and the few code
spans, so the site has exactly one font request.

- **self-hosted, no CDN.** This is the assignment's rule and the lab's better practice. No
  existing site is copied here — the two that exist disagree with each other, and both are
  rejected on purpose:
  - the **blog** pulls a display face from Google's CDN
    (`blog-src/assets/css/custom.css:28`, `blog-src/layouts/partials/extend-head.html:1-3`):
    a third-party request on every page view, and an outage the site cannot control. Not
    repeated.
  - the **wiki** ships no font file at all and falls back to the reader's system stack
    (`wiki.tazlab.net/publish/themes/PaperMod/assets/css/core/reset.css:27`): free, but the
    face is the reader's, not ours.
- the site wants one *chosen* face and no *foreign* request, so the face is a file in the
  repository. Licence: Inter is SIL OFL 1.1 — `site/fonts/LICENSE-inter.txt` ships beside it.
- the **product's own page** uses a monospace stack (`ambrogio/v2/api/ui/app.css:24`). The site
  deliberately does not copy the face: that page is a dense operator dashboard read at 14 px,
  the site is prose read once, and prose is not set in a terminal font. It copies the product's
  *colours*, not its *typography*.

### 3.3 The palette — the product's own tokens, read, not invented

The palette is not a new one: it is the one the engine already draws with, read from
`ambrogio/v2/api/ui/app.css:15-16`:

| token | value | where it is used on the site |
|---|---|---|
| `--bg` | `#14161a` | the page ground |
| `--panel` | `#1a1d23` | cards, the sidebar's active row, code blocks |
| `--bar` | `#171a1f` | the header's ground (the engine's own bar) |
| `--fg` | `#e8e6e3` | body text |
| `--dim` | `#8a8f98` | secondary text, the sidebar's idle links |
| `--line` | `#2a2e36` | rules and borders |
| `--accent` | `#7aa2f7` | links, the current-page mark, `:focus` |

- **Why the product's palette and not a fresh one:** the site is the product's public face, and
  the product already fixes its colours in one file. A second palette would be the site arguing
  with the product, and the mark would then sit on a ground it was not made for.
- **The header is `--bar #171a1f`**, the engine's own bar ground: the mark's ground on the site
  is the ground it was made for.
- **The accent is the engine's token, never a colour sampled from the PNG**: the mark's blues
  stay the art's; no `#2f6df6`-style invention.
- **Contrast, measured** with the WCAG formula on these exact values (not asserted): `--fg` on
  `--bg` **14.54:1**, `--dim` on `--bg` **5.57:1**, `--accent` on `--bg` **7.19:1** — all at or
  above 4.5:1, so body, secondary and link text all pass AA.
- The site is dark because the product is. If it reads badly in daylight, the ground is **one
  variable** to move, not a redesign.

### 3.4 One stylesheet, hand-written, no framework

`site/styles.css` — about 150 lines, written by hand, **no framework, no CDN, no build step**.
It defines exactly: the `@font-face`, the tokens above, a `.wrap` measure (max 720 px), the
sidebar grid, the type scale (h1/h2/h3/body/lead/eyebrow), lists, `code`/`pre`, one `.card` for
the four deep dives, the header/footer, and one media query that collapses the sidebar.

- **No framework:** the whole site is five pages and one author. A framework is more bytes than
  the stylesheet, a second vocabulary to keep, and a dependency that must be pinned and audited
  — for a layout that is a grid and a measure.
- **No JavaScript:** nothing on the site needs state. Every link is a link; the current page is
  marked in the HTML the server sent.

---

## 4. The pages, file by file

### `site/index.html` — *Ambrogio — the agent orchestrator of tazlab.net*

The main page. Five lines and four cards, nothing else:

- the claim, in the operator's words §1: it keeps the trace of what is done, gives order and
  documentation to every movement, and its own internal agents keep it correct;
- what it is: one static Go binary beside one SQLite file, supervising resident agent processes
  over the Agent Client Protocol; one HTTP API, one SSE stream, one page of its own;
- why it exists: two problems — several agents working at once without two hands in one place,
  and the trace of what was done and why, for whoever comes later (`ambrogio/README.md` §1);
- **four cards**, one per deep dive, each one sentence naming the question it answers;
- a closing paragraph, *Built in the lab it runs*: tazlab.net, GitOps, the same delivery lane as
  the blog and the wiki — and one sentence saying the site is static and is **not** the hub.

No feature list, no screenshot gallery, no version badge.

### `site/queues.html` — *The queues, and who accepts them*

Answers: where does work come from, and who may start it?

- a **queue** is the unit of work: an **originator** (the operator, or a task the hub opened
  itself), a **kind** (`work` or `conversation`), an ordered **chain of steps**, **one session**
  carried from step to step, a **step ceiling** declared when the queue is accepted, and a
  **state** (`open` / `paused` / `closed`) — `ambrogio/README.md` §2;
- **nothing starts by itself**: acceptance is the operator's act (`POST /api/v1/queues
  {task, role, steps}`); the ceiling is declared *with* the acceptance, and `+N` is a **new
  acceptance**, never a silent extension (`ambrogio/README.md` §2);
- the dispatcher carries queues in **arrival order**; **urgency** orders tasks *inside* a lane
  (the standard band `0..100`; the operator's own requests are born at `90`), and only a task
  **above 100** may preempt a place already taken (`ambrogio/README.md` §3);
- the chain's order is the order the worker packed; between queues it is FIFO — *"whoever
  arrived first does not wait for ever behind whoever arrived later"* (`ambrogio/README.md` §3);
- **at the ceiling the queue closes and comes back to the operator** saying what it did, what is
  missing and why — a *return*, not a bounce (`ambrogio/README.md` §2);
- the order is not the documentation: the three documents — **plan, roadmap, progress** — say
  *why*, and the review refuses a queue whose documents are missing
  (`ambrogio/README.md` §2, §5, §6);
- the honest edge: **the engine does not build and does not merge**, and it runs no tests and
  judges no prose — it checks that the declarations exist where they say
  (`ambrogio/README.md` §5; `ambrogio/VOCABULARY.md`, *the words the code refuses*).

### `site/doors.html` — *The two doors, and the sandbox*

Answers: what may an agent touch on my machine, and who can ask for what?

- **two doors.** One for the **operator** (every verb) and a second for the **agents**
  (`-agents-addr`): the same handlers with a smaller table, so a worker cannot accept work,
  change the settings, or read the operator's material; an operator act on the agents' door
  answers **403** with a sentence saying why (`ambrogio/README.md` §4);
- the **wall** on the operator door: socket credentials, and the token on writes
  (`ambrogio/VOCABULARY.md`, *wall*);
- **the sandbox.** Every worker is started through `v2/cmd/sandbox`, which applies a **Landlock**
  allow-list to itself and `exec`s the target — the process is replaced, so the domain is
  inherited directly and a live worker shows `NoNewPrivs=1` (`ambrogio/README.md` §7);
- the allow-list, in plain words: the system directories read-only, TCP 443 (the model), the
  run's own tree, the IPC scopes restricted; the policy is **per role**, kept in the database
  (`role_policy`) (`ambrogio/README.md` §7);
- the **tools are declared per role** too: a `worker-external` may `read`, `glob`, `grep`,
  `write`, `edit`, `bash` and drive a browser, and it delivers; a `worker-internal` runs inside
  the hub and gets `read`, `glob`, `grep` and the internal APIs — **no `bash`, no `write`**
  (`ambrogio/README.md` §7; `ambrogio/VOCABULARY.md`, *role*);
- the honest edge, named by the project itself: the policy does not grant what the Go toolchain
  needs, so **a caged worker cannot build the project** (`ambrogio/README.md` §9).

### `site/hands.html` — *The hands, the budget and the silence*

Answers: what stops a hand?

- a **hand** is the live form of a **run** — the process doing the work now; a run is one
  execution of one step by one hand, closed with an **outcome** and an **end cause**
  (`ambrogio/VOCABULARY.md`, *run*/*hand*; `ambrogio/README.md` §6);
- **the pool**: the hands the engine spawns, counted per lane (`lane_cap:external`,
  `lane_cap:internal`, and `conversation_slots` for the chats); a queue that holds a place keeps
  it until it closes (`ambrogio/README.md` §2);
- a **free hand** is spawned by nobody here: it takes a work order from `GET /api/v1/free`,
  holds it for a deadline, and hands it in — it holds **no lane and no slot**
  (`ambrogio/README.md` §4; `ambrogio/VOCABULARY.md`, *free hand*);
- **the budget**: a worker estimates the work when it accepts it; the step is carried with a
  **declared budget**, and `+N` is a new acceptance, never a silent extension
  (`ambrogio/README.md` §2);
- **the silence**: a step that says nothing for its **silence limit** is stopped by the engine,
  and **every announcement puts the clock back to the full limit**; a step that needs longer
  **declares a budget for itself**, and the engine's **ceiling** stops it regardless. This is
  the queue engine's own protocol, stated plainly — the step this document is written under
  carries exactly these three numbers;
- **what is left behind** when a hand ends: `task_event` (what happened, in order, read **from a
  cursor**), `run` (who worked, for how long, how it ended), `report` (the account), `review`
  (what the gate checked and refused), `document` (plan, roadmap, progress) —
  `ambrogio/README.md` §6.

### `site/conversation.html` — *The conversation*

Answers: what is the thing the operator actually talks to?

- a **conversation is a queue you talk to**: its kind is `conversation`, and the kind is what
  tells the engine that a queue with nothing left to do **waits** instead of closing
  (`ambrogio/README.md` §2);
- the operator's messages **are its steps**, and **each answer is that step's `brief`**; the
  chain in SQLite **is the transcript** — the queue's id is the conversation's id, so there is
  **no conversation table and no new field on a task** (`ambrogio/README.md` §2;
  `ambrogio/VOCABULARY.md`, *brief*);
- it grows **by a declared function and not by relaxing a refusal**: `Store.AppendMessage` is
  the only way a started queue takes another step, and the `+N` is the operator giving the chat
  more room (`ambrogio/README.md` §2);
- the **idle clock**: after `chat_idle_ms` of silence the engine pauses the chat — the actor is
  `engine`, never the operator — and the next message **resumes** it; the session is untouched
  by both (`ambrogio/README.md` §2);
- a chat has **slots of its own** (`conversation_slots`), so it never waits behind the work; it
  is carried by an **external hand**, and the external **stop** stops the chats too
  (`ambrogio/README.md` §2);
- **the memory is the ledger, not the session**: every prompt carries his messages and the
  briefs they were answered with, read off the disk at every step — *the session is the bonus*
  (`ambrogio/README.md` §2; `ambrogio/VOCABULARY.md`, *ledger*).

### `site/styles.css`, and the assets beside the pages

- `site/styles.css` — the one stylesheet (§3.4);
- `site/logo.png` — the header mark, §3.1, byte-identical to `ambrogio/v2/api/ambrogio-mark.png`;
- `site/favicon.ico` — the tab, §3.1, the engine's own three-frame icon;
- `site/fonts/inter.woff2` + `site/fonts/LICENSE-inter.txt` — the typeface and its licence, §3.2.

### The two build files of the source repository

- `Dockerfile` — §5.1, the single nginx stage;
- `.github/workflows/publish.yml` — the publish job, §5.5.

---

## 5. The pod — static files served by `nginx:stable-alpine`

The pod is the **static half** of the lane: nginx serving a document root on port **80**, one
replica, nothing computed at request time. No database, no PVC, no backend, no application
server (`RICERCA.md` §1, §3–§6).

### 5.1 The Dockerfile

```dockerfile
# ambrogio-site — the pages, served as files. Nothing is computed at request time.
FROM nginx:stable-alpine
COPY site/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

The last three lines are **the wiki's and the blog's own last three lines**
(`wiki.tazlab.net/Dockerfile:19-22`, `blog-src/Dockerfile:24-27`): the same base image, the same
`EXPOSE 80`, the same `CMD`. What differs is what is *above* them — and it differs on purpose:

- the wiki and the blog prepend a Hugo stage (`FROM hugomods/hugo:std`, `RUN hugo --minify` —
  `wiki.tazlab.net/Dockerfile:2`, `blog-src/Dockerfile:2`) because their content is a tree of
  Markdown that has to be rendered;
- this site has **five hand-written pages**, so the generator stage is dropped and the image is
  the single nginx stage. That is the *image half* only: the delivery half (workflow → registry →
  Flux → rollout) is followed name for name (`RICERCA.md` §1, §8).

### 5.2 The port

**80, end to end**, exactly as the wiki: `containerPort: 80`
(`tazlab-k8s/apps/base/hugo-wiki/hugo-wiki.yaml:21`), the Service `port: 80 → targetPort: 80`
(`hugo-wiki.yaml:30-31`), and the Ingress backend `number: 80` (`hugo-wiki.yaml:62-63`).
nginx's default site listens on 80; nothing in the pod moves it.

### 5.3 The probes

Neither static site carries a probe (`tazlab-k8s/apps/base/hugo-wiki/hugo-wiki.yaml:1-22` and
`hugo-blog/hugo-blog.yaml` have no probe block at all). This site adds two, whose **shape is
copied from `teaching.yaml`** with only the path changed:

```yaml
readinessProbe:                 # teaching.yaml:62-67
  httpGet:
    path: /
    port: 80                    # teaching probes /api/healthz, its own health route
  periodSeconds: 5
  failureThreshold: 2
livenessProbe:                  # teaching.yaml:68-72
  httpGet:
    path: /
    port: 80
  periodSeconds: 20
  failureThreshold: 5
```

- **`/` is the probe**: nginx answers it from its own index with a 200; there is no health
  route to invent for a static server, and inventing one would be a route that lies.
- **no `startupProbe`**, unlike teaching (`teaching.yaml:56-61`, `failureThreshold: 15 ×
  2 s`): that one exists for a Python application that has to load before it can answer;
  nginx is ready in well under a second, and a 5 s readiness window already absorbs it.
- **why add them at all if the two static sites have none:** the assignment asks for them, and
  they are cheap and honest — a hung nginx is restarted, and a pod that is not answering is
  taken out of the Service instead of being served from.

### 5.4 The resource limits

```yaml
resources:
  requests:
    cpu: 10m
    memory: 16Mi
  limits:
    cpu: 200m
    memory: 64Mi
```

- **the requests are not optional, and that is the lab's own measurement**: a pod with no
  request is an unranked eviction candidate, so when the node fills up the kubelet picks it
  alongside the pod that actually caused the pressure
  (`tazlab-k8s/apps/base/buzz/helmrelease.yaml:141-142`, TD-105). The two static sites carry no
  request at all (`hugo-wiki.yaml`, `hugo-blog.yaml`); this site does not repeat that.
- **the numbers are the floor, and below the lab's smallest services**: the two smallest that
  do carry resources ask **50m / 128Mi → 200m / 256Mi**
  (`tazlab-k8s/apps/base/mnemosyne-mcp/deployment.yaml:52-58` and
  `hindsight/deployment-dashboard.yaml:60-66`) — both *applications*. nginx:stable-alpine
  serving five files holds a few MB and no measurable CPU, so it asks a fraction of their
  requests; the limits exist to contain a runaway, not to be reached.
- **no `readOnlyRootFilesystem`, no dropped capabilities, no `runAsNonRoot`**: nginx writes its
  cache and pid under `/var`, and the wiki and the blog set no `securityContext` at all
  (`hugo-wiki.yaml:17-21`). Buying the read-only rootfs would cost two `emptyDir` mounts for a
  pod with no writable state worth protecting — the deviation is named where a service needs it
  (`teaching.yaml:85-89`).

### 5.5 The shape of the manifest, and the name and tag rule Flux needs

One file carries Deployment + Service + Ingress, exactly as the two static sites do
(`tazlab-k8s/apps/base/hugo-wiki/hugo-wiki.yaml:1,23,36`): `replicas: 1` (`:7`), the marked
`image:` line, and the Ingress annotations
`traefik.ingress.kubernetes.io/router.entrypoints: web, websecure` and
`router.tls: "true"` (`:40-42`), TLS from `ambrogio-tazlab.net-tls`. Beside it a
`Certificate` (`issuerRef: letsencrypt-issuer` / `ClusterIssuer`, `commonName`
`ambrogio.tazlab.net`, RSA-2048, `rotationPolicy: Always` — the shape of
`apps/base/hugo-wiki/certificate.yaml`) and a `kustomization.yaml` listing the two.

The rule is mechanical, because Flux picks the image up **by name**: the pushed tag, the
ImagePolicy regex and the Deployment marker must agree, or the automation never fires
(`RICERCA.md` §8).

| piece | value | copied from |
|---|---|---|
| Docker Hub image | `tazzo/tazlab-ambrogio-site` | `blog-src/.github/workflows/publish.yml:29-30`, name swapped (`RICERCA.md` §8) |
| tags pushed | `:latest` and `ambrogio-site-${github.run_number}-${github.sha}` | `blog-src/.github/workflows/publish.yml:28-30` |
| trigger | push to `master` | `blog-src/.github/workflows/publish.yml:4-6` |
| registry login | `roberto.tazzoli@gmail.com` + `secrets.DOCKER_PASSWORD` | `blog-src/.github/workflows/publish.yml:22-25` |
| ImageRepository | `tazzo/tazlab-ambrogio-site`, `interval: 1m` | `…/automation/hugo-wiki/automation.yaml:7-8` |
| ImagePolicy | `filterTags.pattern: '^ambrogio-site-(?P<value>[0-9]+)-.*$'`, `extract: '$value'`, `numerical: order: asc` | `…/automation/hugo-wiki/automation.yaml:19-23` |
| marked image line | `tazzo/tazlab-ambrogio-site:latest # {"$imagepolicy": "flux-system:ambrogio-site"}` | `hugo-wiki.yaml:19` |
| ImageUpdateAutomation | `interval: 1m`, commit `chore: self-update ambrogio-site image [skip ci]`, push `master`, `update.path: ./apps/base/ambrogio-site`, `strategy: Setters` | `…/automation/hugo-wiki/automation.yaml:31,43-48` |
| Flux Kustomization | `clusters/tazlab-k8s/apps-ambrogio-site.yaml`, `path: ./apps/cluster/ambrogio-site`, `dependsOn: [infrastructure-configs]`, `postBuild.substituteFrom ConfigMap/cluster-vars` | `clusters/tazlab-k8s/apps-static-wiki.yaml:4-10,17-19` |
| registration | `../automation/ambrogio-site` added to `infrastructure/cluster-instances/kustomization.yaml` | `RICERCA.md` §9 |

**DNS: none.** `*.tazlab.net` is wildcard-resolved to the house IP and Traefik is the MetalLB
VIP `192.168.1.240` (`RICERCA.md` §7), so the hostname answers at the edge before the
Certificate exists.

---

## 6. Non-goals

- No database, no PVC, no backend, no auth, no analytics, no JavaScript.
- No Hugo or any generator: five fixed pages do not need one.
- No new `ClusterIssuer`, no new Traefik entrypoint, no new MetalLB pool — the existing chassis
  carries it (`RICERCA.md` §7).
- No CMS, no editable content, no search: changing the site is a commit.
- The site is **not** a copy of the hub's own page: the hub's page is an operator console, this
  is a description of the product.

---

## 7. Definition of done

- `https://ambrogio.tazlab.net/` returns **200** with a valid Let's Encrypt chain;
- the five pages are reachable from the side menu, and every one of them renders with
  JavaScript disabled;
- a push to `master` publishes `tazzo/tazlab-ambrogio-site:ambrogio-site-<N>-<sha>`, Flux
  commits the new tag into `apps/base/ambrogio-site/ambrogio-site.yaml` on its own, and the
  Deployment rolls out;
- `kubectl get deploy -n ambrogio-site` shows **one** ready replica, and the pod serves only
  static files.

---

## 8. State of the tree, so the build step is not puzzled

`ambrogio-site/site/` currently holds a **first pass** written before this document: one main
page and three deep dives (`what-it-does.html`, `how-it-works.html`, `about.html`). This design
**supersedes its page set**: the deep dives become the four mechanism pages of §2/§4
(`queues.html`, `doors.html`, `hands.html`, `conversation.html`), the "About" content folds
into three lines at the foot of the main page, and the inline hand-drawn `logo.svg` of that
first pass is replaced by the operator's own mark (§3.1) — a redrawn mark is not the mark. The
one-stylesheet approach (no framework, no JavaScript), the "one typeface, self-hosted" rule,
and the single-nginx-stage pod of that pass are kept; its palette is moved to the product's own
tokens (§3.3) and its top navigation becomes the side menu of §2.
