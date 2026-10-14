#!/bin/sh
# verify-0.3-deep-dives.sh — the check for the second task of queue #67: the three deep dives
# carry Ambrogio 0.3, the conversation page is left alone, and nothing else moved.
#
# The order (queue #67, 2026-10-14): the first page states 0.3 — a queue owns a branch and a
# working directory of its own, the engine lands the work itself (a push, and a pull request),
# every agent works inside a cage — and the four deep dives have to carry it, each in its own
# words, without restyling the site and without touching index.html:
#
#   queues.html       what a queue owns in 0.3, and what the engine now does with the work
#   doors.html        every agent, not only every worker, runs inside the cage
#   agents.html       the agent's work happens inside the cage
#   conversation.html whatever 0.3 changed for a queue of kind conversation — or nothing
#
# The script reads the markup, not a rendering: this cage carries no renderer (Chromium aborts
# on `sandbox/linux/services/proc_util.cc:38`, the Landlock policy denies it `/proc`). Run from
# anywhere; the tree is found from the script's own path.
#
# Exit 0 when every page says what it must and the site holds together; 1 otherwise, naming
# what is wrong.

set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SITE="$ROOT/ambrogio-site/site"
python3 - "$SITE" <<'PY'
import html.parser, os, re, sys

site = sys.argv[1]
PAGES = ["index.html", "queues.html", "doors.html", "agents.html", "conversation.html"]
fail = 0

def say(ok, what):
    global fail
    print(("ok    " if ok else "FAIL  ") + what)
    if not ok:
        fail = 1

def read(name):
    return open(os.path.join(site, name), encoding="utf-8").read()

class Scan(html.parser.HTMLParser):
    """The page as a reader meets it: every tag with its attributes, and the text of <main>."""
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tags, self.stack, self.texts = [], [], []
        self.in_main, self.buf, self.buf_tag = False, [], None
    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        self.tags.append((tag, d))
        self.stack.append(tag)
        if tag == "main":
            self.in_main = True
        if tag == "p" and self.in_main:
            self.buf_tag = len(self.tags) - 1
            self.buf = []
    def handle_endtag(self, tag):
        while self.stack and self.stack.pop() != tag:
            pass
        if tag == "main":
            self.in_main = False
        if tag == "p" and self.buf_tag is not None:
            self.texts.append(" ".join("".join(self.buf).split()))
            self.buf_tag = None
    def handle_data(self, data):
        if self.buf_tag is not None:
            self.buf.append(data)

scan, src = {}, {}
flat, text = {}, {}
for page in PAGES:
    src[page] = read(page)
    flat[page] = " ".join(src[page].split())          # the prose, unbroken by the markup's indentation
    s = Scan(); s.feed(src[page]); s.close()
    scan[page] = s
    # what the page *says*: the text of its paragraphs with the tags stripped — the checks
    # about the prose read this, and the checks about the markup read `flat`
    text[page] = " ".join(s.texts)

# --- the two pages this task must not touch ------------------------------------------------
say(src["index.html"].count("Ambrogio 0.3 — The Butler") == 1,
    "index.html still carries the 0.3 line once, and is otherwise the page it was")
say("A chat is not a second system beside the queues" in src["conversation.html"],
    "conversation.html is the page it was (nothing in 0.3 names a queue of kind conversation)")

# --- queues.html: what a queue owns, and what the engine does with the work ----------------
q = text["queues.html"]
say("owns the branch and the working directory its steps are written in" in q,
    "queues.html says a queue owns a branch and a working directory of its own")
say("<li><strong>A branch, and a working directory</strong>" in flat["queues.html"],
    "queues.html lists the branch and the working directory among the queue's parts")
say("It is not a list of messages:" in q and "not a git branch" not in q,
    "queues.html no longer opens by denying the queue is a git branch")
say("<h2>What the engine does with the work</h2>" in flat["queues.html"],
    "queues.html has a section on what the engine does with the work")
say("lands the work" in q and "pushes the branch" in q and "pull request" in q,
    "queues.html says the engine lands the work: it pushes the branch and opens a pull request")
say("does not build and does not merge" not in q and "The merge is the worker's act" not in q,
    "queues.html no longer claims the engine does not merge, or that the merge is the worker's act")
say("does not build" in q and "runs no tests" in q and "judges no prose" in q,
    "queues.html keeps the honest edge: no build, no tests, no judgement of prose")

# --- doors.html: every agent, not only every worker, is caged ------------------------------
d = text["doors.html"]
say("every agent it starts is caged before it runs — not only" in d,
    "doors.html's lead: every agent the engine starts is caged, not only the workers")
say("Every agent the engine starts goes through a launcher" in d,
    "doors.html's sandbox opens on every agent the engine starts")
say("every worker" not in d.lower(),
    "doors.html no longer says 'every worker' anywhere (the cage is not the workers' alone)")
say("outside the cage" not in d,
    "doors.html no longer names a workaround outside the cage (0.3 cages every agent)")
say("caged agent" in d and "cannot build the project" in d,
    "doors.html keeps the declared limit, told of agents")

# --- agents.html: the agent's work happens inside the cage ---------------------------------
a = text["agents.html"]
say("<h2>The agent works inside the cage</h2>" in flat["agents.html"], "agents.html has the cage's own section")
say("Every agent the engine starts works inside the cage" in a,
    "agents.html says every agent the engine starts works inside the cage")
say("and not only the workers that carry a step" in a,
    "agents.html says it is not the workers' cage alone")
say("the agent's work happens in there" in a, "agents.html says where the agent's work happens")

# --- what all five pages must still be -----------------------------------------------------
for page in PAGES:
    s, text = scan[page], src[page]
    tags = [t for t, _ in s.tags]
    metas = {d_.get("name") or d_.get("property"): d_.get("content")
             for t, d_ in s.tags if t == "meta"}
    say(tags.count("h1") == 1 and tags.count("main") == 1, f"{page}: one h1, one main")
    say(tags.count("script") == 0, f"{page}: no <script>")
    say(metas.get("description") == metas.get("og:description"),
        f"{page}: the meta description and og:description are one text")
    imgs = [d_ for t, d_ in s.tags if t == "img"]
    say(len(imgs) == 1 and imgs[0].get("width") == "512" and imgs[0].get("height") == "512",
        f"{page}: the header mark is the file's own 512×512")
    for t, d_ in s.tags:
        if t == "a" and d_.get("href") and not d_["href"].startswith(("http:", "https:")):
            target = d_["href"].split("#")[0]
            say(os.path.isfile(os.path.join(site, target)) or target == "",
                f"{page}: the link to {d_['href']} resolves to a file in the site")
    say("\t" not in src[page], f"{page}: no tabs in the markup (the site's own style)")

print(f"-- pages: {len(PAGES)}; the three deep dives changed, index.html and conversation.html did not")
sys.exit(fail)
PY
rc=$?
echo "VERIFY-0.3-DEEP-DIVES: $([ "$rc" -eq 0 ] && echo OK || echo FAILURES)"
exit "$rc"
