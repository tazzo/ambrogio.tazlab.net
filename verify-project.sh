#!/bin/sh
# verify-project.sh — checks that every source PROGETTO.md cites still exists and has the lines
# it names. PROGETTO.md is a design: its citations are its evidence, and this is the check that
# they are real. Run it from anywhere; paths are absolute on purpose.
#
#   sh /workspace/ambrogio-site/verify-project.sh             # the full check, against the lab root
#   sh /workspace/ambrogio-site/verify-project.sh --in-repo   # only what this checkout carries
#
# `--in-repo` is the mode the publish workflow runs: a runner has this repository and nothing
# else, so the citations that live in the sibling trees (`wiki.tazlab.net/`, `blog-src/`,
# `tazlab-k8s/`, `ambrogio/`) are counted and reported as **not carried here** rather than
# called missing, and the checks that read those trees are skipped the same way. The full
# mode is the one to run on the operator's machine, where every citation is reachable.
#
# Exit 0 when nothing that was checked is missing; 1 otherwise.

set -u
IN_REPO=0
[ "${1:-}" = "--in-repo" ] && IN_REPO=1
ROOT=$(cd "$(dirname "$0")" && pwd)
# The lab root is where the citations are written from (`ambrogio-site/PROGETTO.md` is
# `/workspace/ambrogio-site/PROGETTO.md`); in the repository-only mode the root is the
# repository itself and the scope below is what keeps the check honest.
W=/workspace
[ "$IN_REPO" -eq 1 ] && W=$ROOT
DOC=$W/ambrogio-site/PROGETTO.md
[ "$IN_REPO" -eq 1 ] && DOC=$W/PROGETTO.md
checked=0
missing=0
skipped=0

check() {
  p="$1"; lines="${2:-}"
  # In the repository-only mode a citation this checkout cannot carry is not a failure and
  # not silence either: it is counted, and the summary says how many were left out.
  if [ "$IN_REPO" -eq 1 ]; then
    case "$p" in
      ambrogio-site/*) f="$W/${p#ambrogio-site/}" ;;   # the citations are written from the lab root
      *) skipped=$((skipped + 1)); return;;
    esac
  else
    f="$W/$p"
  fi
  checked=$((checked + 1))
  if [ ! -e "$f" ]; then
    echo "MISSING FILE  $p"
    missing=$((missing + 1))
    return
  fi
  [ -z "$lines" ] && return
  n=$(awk 'END{print NR}' "$f")
  for l in $(echo "$lines" | tr ',' ' '); do
    if [ "$l" -gt "$n" ]; then
      echo "MISSING LINE  $p:$l  (file has $n lines)"
      missing=$((missing + 1))
    fi
  done
}

check ambrogio-site/RICERCA.md
check wiki.tazlab.net/Dockerfile 2,19,20,21,22
check blog-src/Dockerfile 2,24,25,26,27
check tazlab-k8s/apps/base/hugo-wiki/hugo-wiki.yaml 7,17,19,21,23,30,31,36,40,41,42,62,63
check tazlab-k8s/apps/base/hugo-blog/hugo-blog.yaml
check tazlab-k8s/apps/base/hugo-wiki/certificate.yaml
check tazlab-k8s/apps/base/teaching/teaching.yaml 56,62,68,78,84,85,87,89
check tazlab-k8s/apps/base/buzz/helmrelease.yaml 141,142
check tazlab-k8s/apps/base/mnemosyne-mcp/deployment.yaml 52,58
check tazlab-k8s/apps/base/hindsight/deployment-dashboard.yaml 60,66
check blog-src/.github/workflows/publish.yml 4,5,6,22,25,28,29,30
check wiki.tazlab.net/.github/workflows/publish.yml
check tazlab-k8s/infrastructure/automation/hugo-wiki/automation.yaml 7,8,19,20,21,22,23,31,43,45,47,48
check tazlab-k8s/clusters/tazlab-k8s/apps-static-wiki.yaml 4,7,10,17,19
check tazlab-k8s/infrastructure/cluster-instances/kustomization.yaml
check blog-src/assets/css/custom.css 28
check blog-src/layouts/partials/extend-head.html 1,2,3
check wiki.tazlab.net/publish/themes/PaperMod/assets/css/core/reset.css 27
check ambrogio/v2/api/ambrogio-mark.png
check ambrogio/v2/api/android-chrome-512x512.png
check ambrogio/v2/api/ui/app.css 15,16,24
check ambrogio/REPORT-task32-the-new-icons.md
check ambrogio/README.md
check ambrogio/VOCABULARY.md
check ambrogio-site/PROGETTO.md

# the mark's digest, as PROGETTO.md §3.1 states it — the 512 the site takes
if [ "$IN_REPO" -eq 1 ]; then
  skipped=$((skipped + 1))
  echo "skipped        the mark's digest against the icon set's file (ambrogio/v2/api/android-chrome-512x512.png is a sibling checkout)"
else
  want=626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9
  got=$(sha256sum "$W/ambrogio/v2/api/android-chrome-512x512.png" | cut -d' ' -f1)
  checked=$((checked + 1))
  if [ "$want" != "$got" ]; then
    echo "DIGEST MISMATCH  android-chrome-512x512.png  want $want  got $got"
    missing=$((missing + 1))
  fi
fi

# the digest PROGETTO.md itself declares for the mark must be the one in the file
checked=$((checked + 1))
if ! grep -q "626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9" "$DOC"; then
  echo "PROGETTO.md does not name the mark's digest"
  missing=$((missing + 1))
fi

# the page set PROGETTO.md fixes, and the sections an artifact must carry
for want in "index.html" "queues.html" "doors.html" "hands.html" "conversation.html"; do
  checked=$((checked + 1))
  grep -q "$want" "$DOC" || { echo "PROGETTO.md does not name $want"; missing=$((missing + 1)); }
done

echo "verify-project: checked $checked citations, $missing missing"
[ "$skipped" -gt 0 ] && echo "verify-project: $skipped citations are in sibling trees this checkout does not carry (run without --in-repo on the operator's machine)"
[ "$missing" -eq 0 ] || exit 1
exit 0
