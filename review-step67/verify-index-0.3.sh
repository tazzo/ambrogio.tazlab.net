#!/bin/sh
# verify-index-0.3.sh — the check for step #67: the first page states the new version, in one
# line and one sentence, and nothing else on it moved.
#
# The step's order (queue #67, 2026-10-14): add the line «Ambrogio 0.3 — The Butler» to
# `ambrogio-site/site/index.html` and, under it, one sentence on what changed — a queue owns a
# branch and a working directory of its own, the engine lands the work (push and pull request),
# every agent works inside a cage — and touch no other page.
#
# The script reads the markup, not a rendering: this cage carries no renderer (Chromium aborts
# on `sandbox/linux/services/proc_util.cc:38`, the Landlock policy denies it `/proc`), so the
# page is checked as the document nginx will serve — the exact strings, as text nodes of
# `<main>`, above the body copy, in a page whose structure is otherwise the one that was
# published. Run from anywhere; the tree is found from the script's own path.
#
# Exit 0 when the page says it; 1 otherwise, naming what is wrong.

set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PAGE="$ROOT/ambrogio-site/site/index.html"
LINE='Ambrogio 0.3 — The Butler'
NOTE='In 0.3 a queue owns a branch and a working directory of its own, the engine lands the work itself — a push, and a pull request — and every agent works inside a cage.'

[ -f "$PAGE" ] || { echo "MISSING  ambrogio-site/site/index.html"; exit 1; }

python3 - "$PAGE" "$LINE" "$NOTE" <<'PY'
import html.parser, sys

page, line, note = sys.argv[1], sys.argv[2], sys.argv[3]
src = open(page, encoding="utf-8").read()

class Scan(html.parser.HTMLParser):
    """The page as a reader meets it: the text of `<main>`, and how the tags nest."""
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack, self.main, self.tags, self.texts, self.imgs = [], 0, [], [], []
        self.in_main, self.buf, self.buf_tag = False, [], None
    def handle_starttag(self, tag, attrs):
        if tag == "main":
            self.main += 1; self.in_main = True
        self.stack.append(tag); self.tags.append((tag, dict(attrs)))
        if tag == "img":
            self.imgs.append(dict(attrs))
        if tag == "p" and self.in_main:
            self.buf_tag = len(self.tags) - 1; self.buf = []
    def handle_endtag(self, tag):
        while self.stack and self.stack.pop() != tag:
            pass
        if tag == "main":
            self.in_main = False
        if tag == "p" and self.buf_tag is not None:
            self.texts.append((self.buf_tag, " ".join("".join(self.buf).split())))
            self.buf_tag = None
    def handle_data(self, data):
        if self.buf_tag is not None:
            self.buf.append(data)

s = Scan(); s.feed(src); s.close()
fail = 0
def say(ok, what):
    global fail
    print(("ok    " if ok else "FAIL  ") + what)
    fail = fail or (0 if ok else 1)

# 1. the line, verbatim, once
say(src.count(line) == 1, f"the page carries «{line}» exactly once (found {src.count(line)})")
# 2. it is a paragraph of its own, and the sentence below it is the next one
paras = [t for _, t in s.texts]
say(line in paras, "the line is the text of a <p> of its own in <main>, not a comment or an attribute")
i = paras.index(line) if line in paras else -1
say(i >= 0 and i + 1 < len(paras) and paras[i + 1] == note,
    "the sentence sits directly under the line, as the next paragraph")
say(src.count('class="release"') == 1 and src.count('class="release-note"') == 1,
    "the two paragraphs are marked .release and .release-note (one each)")
# 3. one sentence, and it is the three changes the order names
say(note.endswith(".") and ". " not in note, f"the note is one sentence ({note.count('. ')} further sentence ends)")
for frag in ("a queue owns a branch and a working directory of its own",
             "the engine lands the work itself — a push, and a pull request —",
             "every agent works inside a cage"):
    say(frag in note, f"the sentence names: {frag}")
# 4. in the markup's own order: hero, then the release line, then the body copy
anchors = {k: src.find(v) for k, v in (("lead", '<p class="lead">'), ("release", '<p class="release">'), ("h2", "<h2>"))}
say(all(v >= 0 for v in anchors.values()) and anchors["lead"] < anchors["release"] < anchors["h2"],
    "the order is: the hero, the release line, then the page's body (before the first <h2>)")
# 5. the page is otherwise the one that was published: same skeleton
say(len(s.tags) > 0, "the markup parses (no unclosed tag swallowed the document)")
for tag, want in (("h1", 1), ("h2", 1), ("main", 1)):
    got = sum(1 for t, _ in s.tags if t == tag)
    say(got == want, f"<{tag}> ×{got} (was ×{want})")
got = sum(1 for t, a_ in s.tags if t == "li" and a_.get("class") == "card")
say(got == 4, f"the four cards are still four (×{got})")
say(sum(1 for t, _ in s.tags if t == "script") == 0, "still no <script>")
say(len(s.imgs) == 1 and s.imgs[0].get("width") == "512" and s.imgs[0].get("height") == "512",
    "the header mark is still the file's own 512×512")
print(f"-- the page's paragraphs in <main>: {len(paras)} (the published page had 11: the eyebrow, the lead, five body, the register and four cards; the release line and its sentence are the two more)")
sys.exit(fail)
PY
rc=$?
echo "VERIFY-INDEX-0.3: $([ "$rc" -eq 0 ] && echo OK || echo FAILURES)"
exit "$rc"
