# REPORT — step #49: the mark on ambrogio.tazlab.net, bigger and the right file

Date: 2026-10-11. Tree: `/workspace/ambrogio-site`. Role: worker-external.
Queue 49. Branch `main`, the published commit `73e8ad0`.

## What this step asked

The operator, looking at the live site: *«il logo deve essere piu' grande; dovremmo averne una
versione»*. The page's mark was `site/logo.png` = **27,638 B**, drawn at 28×28; the icon set in
the Ambrogio repository holds a **121,589 B** version. The step: put the bigger file in the
site, size it as a header mark and not as a favicon, state the drawn height in the stylesheet
and the file's own dimensions in the markup, leave `favicon.ico` alone, check 320 px and a
desktop width, and keep the change to the logo's own rules.

## Which file, and from where — the choice

The icon set is `ambrogio/v2/api/` (it comes from `/mnt/shared/app-icons.zip`; the zip was
opened and read member by member before choosing):

| candidate | size | sha256 | where |
|---|---|---|---|
| **`android-chrome-512x512.png`** | **121,589 B** | `626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9` | `ambrogio/v2/api/` — **taken** |
| `android-chrome-192x192.png` | 27,638 B | `7c37248e6cbfb2a5a00b92a22b8c93aa93591743757ad0b21319d92a10a5f0e6` | `ambrogio/v2/api/` — what the site served |
| `ambrogio-mark.png` | 27,638 B | `7c37248e…` (same as the 192) | `ambrogio/v2/api/` |
| `web/icon-512x512.png`, `web/safari-pinned-tab.png`, `android/playstore-icon.png`, `macos/…/icon-512.png` | 121,589 B each | `626654ac…` (all five the same bytes) | inside `app-icons.zip` |
| `ios/…/icon-1024.png`, `macos/…/icon-512@2x.png` | 316,769 B each | `d24e8b61349a954edde3eeb4520d1433…` | inside `app-icons.zip` only |

The zip holds **no SVG** (`[n for n in z.namelist() if n.endswith('.svg')]` → `[]`), and neither
does the Ambrogio repository (`find /workspace/ambrogio -name '*.svg'` → empty). The largest
raster **the repository's icon set carries** is the 512 — the 1024 exists only in the zip's
iOS/macOS app-icon sets, and it was left there: the mark is drawn at 40 CSS px (80 device px at
2×), which the 512 already covers six times over, so the 1024's extra 195 KB would buy no pixel
(declared in `deviation`). Provenance is byte-verified: the site now carries the *same bytes* as
`v2/api/android-chrome-512x512.png`, and the 192 it replaced was byte-identical to
`v2/api/android-chrome-192x192.png` (both `7c37248e…`), so the site was serving the 192 drawn
small — exactly as the operator said.

## What changed

```
ambrogio-site/site/logo.png          Bin 27638 -> 121589 bytes     (the 512, same file name)
ambrogio-site/site/index.html        |   2 +-     width="28" height="28" -> width="512" height="512"
ambrogio-site/site/queues.html       |   2 +-     same
ambrogio-site/site/doors.html        |   2 +-     same
ambrogio-site/site/hands.html        |   2 +-     same
ambrogio-site/site/conversation.html |   2 +-     same
ambrogio-site/site/styles.css        |   7 ++++++-  the mark's own rule, 28px -> 40px, with the why
```

The stylesheet, `.brand img` (styles.css:52-57) — the drawn height, stated:

```css
/* The mark. site/logo.png is android-chrome-512x512.png of the Ambrogio icon set
   (ambrogio/v2/api/, from app-icons.zip): 512×512, 121,589 B — the largest the set
   holds. Drawn at 40 px, a header mark and not a favicon (the favicon stays
   favicon.ico, in the tab's business). 40 px keeps the header's own 62 px min-height
   in charge, so the mark grows without moving anything else on the page. */
.brand img { display: block; width: 40px; height: 40px; }
```

**Why 40 px.** The header's own `min-height: 62px` (styles.css:49) with its 10 + 10 px padding
leaves 42 px of room, so a 40 px mark still fits inside the header the site already had: the bar
stays 62 px of content box (63 px with its border) and **nothing else on the page moves** —
measured below. The mark goes from 28 px to 40 px, ×1.43, and the header stops looking like a
favicon row. The markup carries the file's own 512×512 on all five pages, so the aspect ratio is
known before the bytes arrive (CSS overrides the used size).

`favicon.ico` was not touched: 15,086 B, `b88644a59fa5dad99bf7aa9371ee52b8e2da5d24f1e6f31d45943500bf40377f`,
before and after. The tab's business is not the page's mark.

## The numbers — rendered, at 320 and at a desktop width

Measured in Chrome over the **live** hostname (`https://ambrogio.tazlab.net/`), viewport 320×640
and 1440×900, DOM geometry read from the page (`natural`, `getBoundingClientRect`,
`clientWidth/scrollWidth`); the harness is in `review-step49/live-render-report.json` and
`review-step49/render-report.json` (the same page measured locally against the built image):

| | phone 320 | desktop 1440 |
|---|---|---|
| file's own pixels (`naturalWidth×naturalHeight`) | 512×512 | 512×512 |
| markup `width`/`height` | 512 / 512 | 512 / 512 |
| **drawn** (`getBoundingClientRect`) | **40 × 40 CSS px** | **40 × 40 CSS px** |
| computed `width`/`height` | 40px / 40px | 40px / 40px |
| mark's device pixels (dpr 1.25 here) | 50 × 50 | 50 × 50 |
| header height | 63 px (62 + border) | 63 px (62 + border) |
| brand block right edge / wrap right edge | 256.39 / 320 | 446.17 / 1250 |
| `scrollWidth` vs `clientWidth` | 320 vs 320 — no overflow | 1440 vs 1440 — no overflow |
| page scroll height | 2461 | **1295** |
| bytes of `logo.png` on the wire | 121,589 (`decodedBodySize`) | 121,589 |
| body background / font | `rgb(20,22,26)` / Inter — the stylesheet applied | same |

The desktop scroll height **1295** is the number step #47 measured on the same page before this
change (`review-step47/REPORT-step47-end-to-end-review.md`, the render table: `1440×1295`), and
the old logo was `192×192 → 28×28` there. So the only thing that changed on the page is the
mark's size.

Screenshots (PNG, live hostname): `review-step49/live-phone-320-header.png` (400×113 at dpr 1.25,
the header band), `live-phone-320-full.png` (400×3076, whole page),
`live-desktop-1440-header.png` (1800×113), `live-desktop-1440-full.png` (1800×1619). The
`shot-*.png` beside them are the same two widths against the locally built image. Inspected: the
mark renders sharp and big in the header beside the wordmark, the nav wraps to one column at 320,
the four cards fall to one column at 320 and to a 2×2 grid at 1440, the footer stays put — no
overflow, no broken layout.

## The live URL — the bytes, read and compared

```
$ curl -sS -D - -o live-logo.png https://ambrogio.tazlab.net/logo.png
HTTP/2 200
content-type: image/png
etag: "6acc0cbb-1daf5"
last-modified: Sun, 11 Oct 2026 22:24:59 GMT
server: nginx/1.30.5
content-length: 121589

live bytes     121589   sha256 626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
site/logo.png  121589   sha256 626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
v2/api/android-chrome-512x512.png
               121589   sha256 626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
cmp: live == site == repository icon set — byte for byte
```

`review-step49/live-logo.png` is the file fetched from the live URL, kept as the raw evidence
(121,589 B, same digest). `favicon.ico` live: `200 image/x-icon 15086` — unchanged. The live
`styles.css` carries the new rule (line 52-57) and the live `/` carries
`logo.png" width="512" height="512"`.

`sh /workspace/ambrogio-site/verify-logo.sh` runs all four checks (repository ↔ site, live URL,
the drawn height the stylesheet states, the five pages' markup with the favicon's digest) and
ends `VERIFY-LOGO: OK`, exit 0:

```
== 1. the mark in the site, against the icon set in the Ambrogio repository
/workspace/ambrogio/v2/api/android-chrome-512x512.png        121589 bytes  626654acf4cc90b4…
/workspace/ambrogio-site/ambrogio-site/site/logo.png         121589 bytes  626654acf4cc90b4…
cmp            site/logo.png == v2/api/android-chrome-512x512.png  (byte for byte)
== 2. the live URL
GET https://ambrogio.tazlab.net/logo.png -> 200 image/png 121589
live bytes     121589
live sha256    626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
cmp            live bytes == site/logo.png  (byte for byte)
== 3. the drawn height the stylesheet states
logo drawn     40 px tall (and as wide)
== 4. the markup, and the favicon left alone
pages          5 of 5 carry the file's own 512x512
favicon.ico    15086 bytes  b88644a59fa5dad99bf7aa9371ee52b8e2da5d24f1e6f31d45943500bf40377f
favicon        unchanged (still the tab's favicon.ico)
VERIFY-LOGO: OK
```

## How it reached the live hostname

The lane is the one step #46 built and step #47 reviewed — no new machinery:

```
git push origin main                       b590081..73e8ad0  (site: the header carries the 512 mark)
GitHub Actions run 6 (38180325680)         in_progress -> success, job build-and-push
Docker Hub tag                             ambrogio-site-6-73e8ad079f38aa6a2dd09c0a8b9d1a8777a41414
                                           (26,262,254 B compressed, 22:25:16Z; :latest same)
flux reconcile image repository ambrogio-site -n flux-system    ✔ scan fetched 7 tags
ImagePolicy ambrogio-site latestRef        ambrogio-site-6-73e8ad079f38aa6a2dd09c0a8b9d1a8777a41414
flux reconcile image update ambrogio-site -n flux-system        ✔ repository up-to-date
ImageUpdateAutomation lastPushCommit       2f1c9852bb9f48067aa27bcbbfc78fc36346e1f2 (22:25:54Z)
tazlab-k8s origin/master                   2f1c985 chore: self-update ambrogio-site image [skip ci]
                                           image: tazzo/tazlab-ambrogio-site:ambrogio-site-6-73e8ad0…
flux reconcile kustomization apps-ambrogio-site --with-source   ✔ applied revision master@sha1:2f1c985
kubectl rollout status deploy/ambrogio-site                     ✔ successfully rolled out
pod ambrogio-site-774d84746b-w7vhw         docker.io/tazzo/tazlab-ambrogio-site@sha256:f53eb075b5e3…
                                           started 22:28:10Z, ready 1/1
live https://ambrogio.tazlab.net/logo.png   200 image/png 121589  (verified twice, 22:28Z and after)
```

Two image builds were **not** needed for the evidence: the report and the screenshots are added
to the repository with `[skip ci]`, because a docs-only commit rebuilds bytes that are already
identical (the same convention the Flux automation uses for its own commits).

## Acceptance, against the assignment

| the step asked | measured |
|---|---|
| the served logo is the bigger file, byte count and digest read from the live URL and compared with the repository | live `121589 / 626654ac…`, `cmp` clean against `ambrogio/v2/api/android-chrome-512x512.png` — and the file taken is named above, with its path |
| the logo's drawn height is stated in the stylesheet | `.brand img { … width: 40px; height: 40px; }` (styles.css:52-57) |
| screenshots at 320 and a desktop width show the mark at its new size, layout unbroken | `review-step49/live-phone-320-*.png`, `review-step49/live-desktop-1440-*.png`; 40×40 drawn at both, no horizontal overflow either, desktop scroll height unchanged at 1295 |
| the favicon stays as it is | `favicon.ico` 15,086 B / `b88644a5…`, live `200 image/x-icon 15086`, untouched in the diff |
| the change stays the logo's own rules | the diff is one binary, one attribute on five pages, and the `.brand img` rule — nothing else |

## The documents that named the old file

- **The project's own documents named the old file, and were cut over with it.** `PROGETTO.md`
  §3.1 (`source: … ambrogio-mark.png — 192×192 … 27638 B`, `the header draws it in a 28 px box`)
  and its source table (§"What was read", the `the mark` row), `ambrogio-site/README.md` (the
  layout line and the "the mark is the operator's art" bullet), and `verify-project.sh`'s digest
  check (it asserted `7c37248e…` of `ambrogio-mark.png` **and** that PROGETTO names it) all
  stated the 192 as the site's source. They now state the 512 and its digest, and
  `verify-project.sh` checks `626654ac…` of `v2/api/android-chrome-512x512.png` — it exits 0
  (`checked 32 citations, 0 missing`). `AVANZAMENTO.md` keeps its step #46 line as written (it
  was true then), gains a step #49 entry, and its closed logo question carries a
  `Superseded [step #49]` sentence. The engine's own bar still embeds the 192
  (`v2/api/ambrogio-mark.png`, drawn in a 20 px box) — unchanged, and out of this step's way.

## What is left

- **The other four pages were not photographed at 320/1440** — they carry the same header, the
  same stylesheet, and the same file, and the phone/desktop shots are of `/`; the byte-level
  checks do cover all five pages' markup.
- **The icon set's own gap: `v2/api/` has no 1024 and no SVG.** If the operator ever wants the mark at
  hero scale (a landing block, a card icon at 3× DPR), the 1024 that lives in `app-icons.zip`
  (`ios/AppIcon.appiconset/icon-1024.png`) would have to be added to `v2/api/` first — the site
  can only take what the set carries.
