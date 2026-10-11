# step #54 — the first page loses *Built in the lab it runs*

The operator's filing (2026-10-11): *«take this out of the first page (index.html), the whole
section, heading included»* — the heading *Built in the lab it runs*, the paragraph on
tazlab.net / GitOps / the delivery lane, and the paragraph saying the site is static and is not
the hub. Everything below is the tree `/workspace/ambrogio-site` (the repository
`tazzo/ambrogio.tazlab.net`), served at `https://ambrogio.tazlab.net/`.

*(The step prompt names this work *queue #52*; the repository's own step sequence —
`AVANZAMENTO.md`, the `review-stepNN/` directories — ran to **#53**, so this one is recorded as
**#54**.)*

## 1. What changed, and only this

The change commit is `3717efe` — *"index.html: the "Built in the lab it runs" section is gone"*,
2 files, 1 insertion, 12 deletions (`git show --stat 3717efe`).

```diff
--- a/ambrogio-site/site/index.html
+++ b/ambrogio-site/site/index.html
@@ -72,15 +72,6 @@
             chain, and it waits instead of closing.</p>
         </li>
       </ul>
-
-      <h2>Built in the lab it runs</h2>
-      <p>Ambrogio is part of <a href="https://tazlab.net">tazlab.net</a>, a small homelab on
-        its own hardware and documented in public. A repository holds the desired state, Flux
-        reconciles it, and a push is a deployment — the blog, the wiki and the teaching site
-        arrive the same way.</p>
-      <p>This site is a description, not the product. It is five static pages served by nginx
-        from one replica; the hub itself is a binary beside a data directory on the operator's
-        machine, and it is not reachable from here.</p>
     </main>
```

The page after the removal, in order and unchanged otherwise: the eyebrow, the `h1`, the lead,
the two paragraphs (*what it is*, *why it exists*), the `h2` *The four things worth knowing* and
its four cards, then `</main>`. The side menu, the four card links, the header, the footer
(*Part of [tazlab.net](https://tazlab.net)*) and its link are untouched. **No other page changed**
— `git status` names only `PROGETTO.md` and `ambrogio-site/site/index.html` (`review-step54/`
except`ed as this step's own evidence directory).

**One file besides the page was changed, and it is declared.** `PROGETTO.md` §4 documents
`site/index.html` *file by file* and its last bullet described exactly the paragraph this step
removed:

```diff
--- a/PROGETTO.md
+++ b/PROGETTO.md
@@ -185,9 +185,7 @@ The main page. Five lines and four cards, nothing else:
   and the trace of what was done and why, for whoever comes later (`ambrogio/README.md` §1);
-- **four cards**, one per deep dive, each one sentence naming the question it answers;
-- a closing paragraph, *Built in the lab it runs*: tazlab.net, GitOps, the same delivery lane as
-  the blog and the wiki — and one sentence saying the site is static and is **not** the hub.
+- **four cards**, one per deep dive, each one sentence naming the question it answers.
```

Left alone it would have described a section that no longer exists. It is documentation only —
no page — and the change is declared in the delivery's `deviation`.

## 2. The stylesheet: no rule was used only by that section

**None exists.** The removed markup carried three element selectors and no class, id or
attribute:

- `h2` — also carried by *The four things worth knowing*, which stays;
- `p` — carried by every paragraph on every page;
- `a` — carried by every link on every page (the removed `tazlab.net` link; the footer's
  `tazlab.net` link stays).

Every rule in `ambrogio-site/site/styles.css` (113 lines) is either an element/`*` rule shared
with the rest of the site or a class rule (`.wrap`, `.shell`, `.side-menu`, `.card`, `.cards`,
`.lane`, `.lead`, `.eyebrow`, `.brand`, `.site-footer`, …) that appears on the other pages or in
index.html's remaining markup. There is therefore **no orphaned rule**, and nothing was removed
from the stylesheet — as the task said, a rule nothing uses is not this task's business.

## 3. What I ran, and what it printed

**The two checks the publish workflow runs**, on the pushed tree — both pass, so the push was
publishable (`review-step54/checks.log`):

```
$ sh verify-project.sh --in-repo
verify-project: checked 8 citations, 0 missing
verify-project: 24 citations are in sibling trees this checkout does not carry
    -> rc 0

$ sh verify-logo-files.sh
== 1. the mark in the site          site/logo.png 121589 bytes 626654ac…  (expected the same)
== 2. the markup, on the five pages  pages 5 of 5 carry the file's own 512x512
== 3. the drawn height               logo drawn 40 px tall, expected 40
== 4. the favicon left alone         favicon.ico unchanged (still the tab's favicon.ico)
VERIFY-LOGO-FILES: OK
    -> rc 0
```

**The acceptance, read from the live URL and not from the source** —
`sh review-step54/verify-live.sh` → **rc 0**, `VERIFY-LIVE: OK`
(`review-step54/verify-live.log`):

```
/                    200  3818 bytes
  contains "Built in the lab it runs"                    0
  contains "A repository holds the desired state"        0
  contains "This site is a description, not the product" 0
  contains "not reachable from here"                     0
  menu: links to index.html / queues.html / doors.html / agents.html / conversation.html  2 each
/queues.html         200  6056 bytes  bc874571…  unchanged=yes
/doors.html          200  4799 bytes  d744585f…  unchanged=yes
/agents.html         200  5110 bytes  5758c7e6…  unchanged=yes
/conversation.html   200  4548 bytes  077e668b…  unchanged=yes
```

and the single numbers — `sh review-step54/measure-live.sh section` prints **0**,
`sh review-step54/measure-live.sh bytes` prints **3818**.

**Before and after, on the served bytes** (`review-step54/live-before.txt`,
`review-step54/live-after.txt`, read at 23:47Z and at 23:52Z):

| page | before | after |
|---|---|---|
| `/` | 200, 4419 B, `386c2b71…`, section **present** | 200, 3818 B, `5739af66…`, section **absent** |
| `/queues.html` | 200, 6056 B, `bc874571…` | 200, 6056 B, `bc874571…` |
| `/doors.html` | 200, 4799 B, `d744585f…` | 200, 4799 B, `d744585f…` |
| `/agents.html` | 200, 5110 B, `5758c7e6…` | 200, 5110 B, `5758c7e6…` |
| `/conversation.html` | 200, 4548 B, `077e668b…` | 200, 4548 B, `077e668b…` |

The four deep dives are byte-for-byte the same on both readings; only the first page moved (4419 →
3818 bytes, −601).

## 4. The lane that carried it

Push `3717efe` (23:47:55Z) → GitHub Actions run **#12** (`Publish Ambrogio Site`, id
`38185623235`, conclusion **success**, every step green) → image
`tazzo/tazlab-ambrogio-site:ambrogio-site-12-3717efe11b09f9bdaa65f5087e61e1c1fe0032d4` pushed
23:48:15Z → Flux's `ImageUpdateAutomation` committed **`9ec44cd`** into `tazlab-k8s`
(`apps/base/ambrogio-site/ambrogio-site.yaml` now names that tag) → the pod rolled → the live
page changed between the 23:51:45Z and the 23:52:00Z reading, **about four minutes after the
push**. The readings are in `review-step54/lane.txt`.

## 5. Children this work revealed

None. The removal was self-contained: nothing in the tree depends on the removed section beyond
the one `PROGETTO.md` bullet this step already carried with it.
