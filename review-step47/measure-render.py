#!/usr/bin/env python3
"""measure-render.py — the browser half of the step-47 review.

Opens the live site https://ambrogio.tazlab.net/ in a real Chromium (the one the box
already carries under ~/.cache/ms-playwright) driven over CDP, at two widths —
a phone width (390x844, DPR 3, mobile) and a desktop width (1440x900, DPR 1) — and
measures, per page and per width:

  * the HTTP status of the document and of every subresource Chrome actually fetched
    (the logo among them), taken from the Network domain, not from curl;
  * the rendered page: title, h1, card count, stylesheet, body font, the logo's
    naturalWidth (0 = the image did not load) and its laid-out box, and its
    naturalWidth/naturalHeight ratio (a broken image renders 0x0);
  * console errors and page exceptions.

It writes one full-page screenshot per width into this directory and prints a JSON
report.  Exit 0 only when every page loaded 200, the logo decoded (naturalWidth > 0),
the CSS applied, and no page raised a script error.
"""

import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request

from websockets.sync.client import connect

CHROME = "/home/tazpod/.cache/ms-playwright/chromium-1148/chrome-linux/chrome"
HERE = os.path.dirname(os.path.abspath(__file__))
HOST = "https://ambrogio.tazlab.net"
PAGES = ["/", "/queues.html", "/doors.html", "/hands.html", "/conversation.html"]
WIDTHS = [("phone", 390, 844, 3, True), ("desktop", 1440, 900, 1, False)]
PORT = 9333

MEASURE_JS = r"""
(() => {
  const imgs = [...document.images].map(i => ({
    src: i.getAttribute('src'), complete: i.complete,
    naturalWidth: i.naturalWidth, naturalHeight: i.naturalHeight,
    renderedWidth: Math.round(i.getBoundingClientRect().width),
    renderedHeight: Math.round(i.getBoundingClientRect().height)
  }));
  const logo = imgs.find(i => /logo/.test(i.src || '')) || imgs[0] || null;
  const body = getComputedStyle(document.body);
  return {
    url: location.href,
    title: document.title,
    h1: (document.querySelector('h1') || {}).textContent || null,
    cards: document.querySelectorAll('.card').length,
    scripts: document.querySelectorAll('script').length,
    window: [window.innerWidth, window.innerHeight],
    page: [document.documentElement.scrollWidth, document.documentElement.scrollHeight],
    bodyFont: body.fontFamily + ' ' + body.fontSize,
    bodyBackground: body.backgroundColor,
    logo: logo,
    images: imgs,
    stylesheets: [...document.styleSheets].map(s => s.href),
    headingColour: (document.querySelector('h1') ? getComputedStyle(document.querySelector('h1')).color : null)
  };
})()
"""


class CDP:
    def __init__(self, ws):
        self.ws = ws
        self.n = 0
        self.events = []

    def send(self, method, params=None, timeout=30):
        self.n += 1
        mid = self.n
        self.ws.send(json.dumps({"id": mid, "method": method, "params": params or {}}))
        deadline = time.time() + timeout
        while time.time() < deadline:
            msg = json.loads(self.ws.recv(timeout=timeout))
            if msg.get("id") == mid:
                if "error" in msg:
                    raise RuntimeError(f"{method}: {msg['error']}")
                return msg.get("result", {})
            if "method" in msg:
                self.events.append(msg)
        raise TimeoutError(method)


def wait_json(url, timeout=20):
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(url, timeout=3) as r:
                return json.load(r)
        except Exception:
            time.sleep(0.3)
    raise TimeoutError(url)


def chrome_procs():
    """Every process named `chrome` on the box, with the binary it is running from.

    Read from /proc directly rather than through a shell: `pgrep -f <pattern>` inside
    `/bin/sh -c ...` matches its own command line and would count itself.
    """
    r = subprocess.run(["pgrep", "-x", "chrome"], capture_output=True, text=True)
    out = []
    for pid in (r.stdout.split() if r.returncode == 0 else []):
        try:
            exe = os.readlink(f"/proc/{pid}/exe")
            cmd = open(f"/proc/{pid}/cmdline", "rb").read().replace(b"\0", b" ").decode(
                errors="replace")
        except OSError:
            continue
        out.append({"pid": int(pid), "exe": exe, "mine": CHROME in exe,
                    "cmd": cmd[:160]})
    return out


def chrome_count(pattern=None):
    cmd = ["pgrep", "-c", "chrome"] if pattern is None else ["pgrep", "-c", "-f", pattern]
    r = subprocess.run(cmd, capture_output=True, text=True)
    return 0 if r.returncode != 0 else int((r.stdout or "0").strip() or 0)


def main():
    profile = tempfile.mkdtemp(prefix="chrome-review-")
    report = {"host": HOST, "chrome": CHROME, "widths": {}, "failures": []}
    report["chromeBeforeMachine"] = len(chrome_procs())      # everything named chrome on the box
    report["chromeBeforeMine"] = sum(1 for p in chrome_procs() if p["mine"])
    proc = subprocess.Popen(
        [CHROME, "--headless=new", "--no-sandbox", "--disable-gpu",
         "--disable-dev-shm-usage", "--no-first-run", "--hide-scrollbars",
         "--disable-background-networking", f"--remote-debugging-port={PORT}",
         f"--user-data-dir={profile}", "about:blank"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        ver = wait_json(f"http://127.0.0.1:{PORT}/json/version")
        report["chromeVersion"] = ver.get("Browser")
        ws_url = ver["webSocketDebuggerUrl"]
        with connect(ws_url, max_size=64 * 1024 * 1024) as ws:
            browser = CDP(ws)
            tgt = browser.send("Target.createTarget", {"url": "about:blank"})["targetId"]
            # attach to the page target and speak on its own session
            page_ws_url = f"ws://127.0.0.1:{PORT}/devtools/page/{tgt}"
        with connect(page_ws_url, max_size=64 * 1024 * 1024) as pws:
            cdp = CDP(pws)
            cdp.send("Page.enable")
            cdp.send("Runtime.enable")
            cdp.send("Network.enable")
            cdp.send("Log.enable")
            for label, w, h, dpr, mobile in WIDTHS:
                cdp.send("Emulation.setDeviceMetricsOverride",
                         {"width": w, "height": h, "deviceScaleFactor": dpr, "mobile": mobile})
                per = {}
                for path in PAGES:
                    url = HOST + path
                    cdp.events.clear()
                    cdp.send("Page.navigate", {"url": url})
                    # wait for the load event
                    deadline = time.time() + 30
                    loaded = False
                    while time.time() < deadline and not loaded:
                        try:
                            msg = json.loads(pws.recv(timeout=30))
                        except TimeoutError:
                            break
                        if msg.get("method") == "Page.loadEventFired":
                            loaded = True
                        elif "method" in msg:
                            cdp.events.append(msg)
                    time.sleep(0.8)  # let late subresources land
                    m = cdp.send("Runtime.evaluate",
                                 {"expression": MEASURE_JS, "returnByValue": True})["result"]["value"]
                    # drain whatever arrived while we measured
                    try:
                        while True:
                            msg = json.loads(pws.recv(timeout=0.2))
                            if "method" in msg:
                                cdp.events.append(msg)
                    except TimeoutError:
                        pass
                    net = {}
                    for e in cdp.events:
                        if e.get("method") == "Network.responseReceived":
                            r = e["params"]["response"]
                            net[r["url"]] = r["status"]
                    errs = [e["params"] for e in cdp.events if e.get("method") == "Log.entryAdded"
                            and e["params"]["entry"]["level"] == "error"]
                    excs = [e["params"] for e in cdp.events if e.get("method") == "Runtime.exceptionThrown"]
                    m["documentStatus"] = net.get(url)
                    m["subresources"] = {k: v for k, v in net.items() if k != url}
                    m["consoleErrors"] = [x["entry"]["text"] for x in errs]
                    m["exceptions"] = [x["exceptionDetails"]["text"] for x in excs]
                    if m["documentStatus"] != 200:
                        report["failures"].append(f"{label}{path}: document status {m['documentStatus']}")
                    if not m["logo"] or m["logo"]["naturalWidth"] <= 0:
                        report["failures"].append(f"{label}{path}: logo did not decode")
                    for k, v in m["subresources"].items():
                        if v >= 400:
                            report["failures"].append(f"{label}{path}: subresource {k} -> {v}")
                    if m["exceptions"]:
                        report["failures"].append(f"{label}{path}: script exception {m['exceptions']}")
                    if m["page"][0] > m["window"][0] + 1:
                        report["failures"].append(
                            f"{label}{path}: horizontal overflow {m['page'][0]} > {m['window'][0]}")
                    per[path] = m
                # screenshot of the landing page at this width
                cdp.send("Page.navigate", {"url": HOST + "/"})
                time.sleep(2.0)
                metrics = cdp.send("Page.getLayoutMetrics")["cssContentSize"]
                shot = cdp.send("Page.captureScreenshot",
                                {"format": "png", "captureBeyondViewport": True,
                                 "clip": {"x": 0, "y": 0, "width": metrics["width"],
                                          "height": metrics["height"], "scale": 1}})
                fn = os.path.join(HERE, f"shot-{label}-{w}x{h}.png")
                with open(fn, "wb") as fh:
                    fh.write(base64.b64decode(shot["data"]))
                report["widths"][label] = {"viewport": [w, h, dpr], "pages": per,
                                           "screenshot": fn,
                                           "screenshotBytes": os.path.getsize(fn),
                                           "fullPageCss": [metrics["width"], metrics["height"]]}
            try:
                cdp.send("Target.closeTarget", {"targetId": tgt}, timeout=5)
            except Exception:
                pass  # the process teardown below is the real close
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=15)
        except subprocess.TimeoutExpired:
            proc.kill()
        # Chromium leaves zygote/renderer children behind if the parent is killed before it
        # has quiesced; sweep by this run's own profile path (never another instance), then
        # prove the box is clean, because "the Chrome is closed" must be measured.
        subprocess.run(["pkill", "-f", "--", profile], capture_output=True)
        deadline = time.time() + 20
        while time.time() < deadline and any(p["mine"] for p in chrome_procs()):
            time.sleep(0.5)
        # `pgrep -c chrome` is reported as-is, and so is the composition: on this box a
        # *different* session's Go test (`go test ./v2/api` in /workspace/ambrogio) starts and
        # stops its own puppeteer Chromium while this script runs, which this task neither
        # opened nor may kill.  The count that speaks for this task is the one whose binary is
        # this task's Chromium: zero, and no growth in that set.
        procs = chrome_procs()
        mine_after = [p for p in procs if p["mine"]]
        report["pgrepChromeAfter"] = chrome_count()
        report["chromeBinaryAfter"] = sorted({p["exe"] for p in procs})
        report["chromeMineAfter"] = len(mine_after)
        report["chromeOpenedByThisTaskLeftBehind"] = len(mine_after)
        if mine_after:
            report["failures"].append(
                f"this task's chrome still running after close: {[p['pid'] for p in mine_after]}")
        shutil.rmtree(profile, ignore_errors=True)

    with open(os.path.join(HERE, "render-report.json"), "w") as fh:
        json.dump(report, fh, indent=2)
    print(json.dumps(report, indent=2))
    if report["failures"]:
        print("RENDER-REVIEW: FAILURES", file=sys.stderr)
        return 1
    print("RENDER-REVIEW: OK", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
