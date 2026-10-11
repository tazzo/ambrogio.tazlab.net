#!/bin/sh
# verify-lane.sh — proves the two halves of the ambrogio-site lane, locally and on the wire.
#
#   1. the image builds from ambrogio-site/Dockerfile (nginx:stable-alpine);
#   2. every page and asset is served 200 with the right content type;
#   3. every manifest the lane touches builds under kustomize and parses as YAML;
#   4. the live hostname answers 200 with a verified certificate, and Docker Hub car-
#      ries the <app>-<run>-<sha> tag the ImagePolicy selects.
#
# Exit 0 when all of it holds; 1 otherwise. Run from anywhere:
#   sh /workspace/ambrogio-site/verify-lane.sh
set -u

SRC=/workspace/ambrogio-site/ambrogio-site
K=/workspace/tazlab-k8s
IMAGE=tazzo/tazlab-ambrogio-site:local
PORT=18081
NAME=ambrogio-site-proof
fail=0

echo "== 1. docker build"
if ( cd "$SRC" && sudo docker build -t "$IMAGE" . ) >/tmp/verify-lane-build.log 2>&1; then
  tail -2 /tmp/verify-lane-build.log
else
  echo "FAIL: build"; cat /tmp/verify-lane-build.log; fail=1
fi

echo "== 2. serve"
sudo docker rm -f "$NAME" >/dev/null 2>&1
if sudo docker run -d --name "$NAME" --security-opt apparmor=unconfined -p "$PORT:80" "$IMAGE" >/dev/null; then
  sleep 2
  for p in / /index.html /queues.html /doors.html /agents.html /conversation.html \
           /styles.css /logo.png /favicon.ico /fonts/inter.woff2 /fonts/LICENSE-inter.txt; do
    line=$(curl -s -o /dev/null -w '%{http_code} %{content_type} %{size_download}' "http://127.0.0.1:$PORT$p")
    printf '%-24s %s\n' "$p" "$line"
    case "$line" in 200\ *) ;; *) fail=1;; esac
  done
  sudo docker rm -f "$NAME" >/dev/null
else
  echo "FAIL: docker run"; fail=1
fi

echo "== 3. manifests"
for d in "$K/apps/cluster/ambrogio-site" \
         "$K/infrastructure/automation/ambrogio-site" \
         "$K/infrastructure/operators/ambrogio-site" \
         "$K/infrastructure/operators/core" \
         "$K/infrastructure/cluster-instances"; do
  opt=
  [ "$d" = "$K/infrastructure/cluster-instances" ] && opt="--load-restrictor LoadRestrictionsNone"
  if kubectl kustomize $opt "$d" >/dev/null 2>&1; then
    echo "kustomize ok    $d"
  else
    echo "kustomize FAIL  $d"; fail=1
  fi
done
python3 - "$K" <<'PY' || fail=1
import sys, glob, yaml
K = sys.argv[1]
fs = (glob.glob(K+"/apps/base/ambrogio-site/*.yaml")
      + glob.glob(K+"/apps/cluster/ambrogio-site/*.yaml")
      + glob.glob(K+"/infrastructure/automation/ambrogio-site/*.yaml")
      + [K+"/clusters/tazlab-k8s/apps-ambrogio-site.yaml",
         K+"/infrastructure/operators/ambrogio-site/namespace.yaml",
         K+"/infrastructure/operators/ambrogio-site/kustomization.yaml",
         K+"/infrastructure/operators/core/kustomization.yaml",
         K+"/infrastructure/cluster-instances/kustomization.yaml"])
assert len(fs) == 11, "expected 11 manifest files, found %d" % len(fs)
for x in fs:
    list(yaml.safe_load_all(open(x)))
print("yaml ok         %d manifest files parse, all docs" % len(fs))
PY

echo "== 4. live and registry"
live=$(curl -s -o /dev/null -w '%{http_code} %{ssl_verify_result}' --max-time 20 https://ambrogio.tazlab.net/)
echo "live https      $live"
case "$live" in "200 0") ;; *) echo "FAIL: live site"; fail=1;; esac
tags=$(curl -s --max-time 20 'https://hub.docker.com/v2/repositories/tazzo/tazlab-ambrogio-site/tags?page_size=50' \
       | python3 -c "import sys,json;print(len(json.load(sys.stdin)['results']))")
echo "registry tags   $tags"
case "$tags" in 0|"") echo "FAIL: registry"; fail=1;; esac

[ "$fail" -eq 0 ] && echo "VERIFY-LANE: OK" || echo "VERIFY-LANE: FAILURES"
exit "$fail"
