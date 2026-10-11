# ambrogio-site

The source of [ambrogio.tazlab.net](https://ambrogio.tazlab.net/) — the presentation site
for **Ambrogio**, the Personal Agent Orchestrator of tazlab.net.

Plain static HTML and one stylesheet, served by nginx. No database, no backend, no
JavaScript, nothing computed at request time: the pod holds static files only.

## Layout

```
site/
  index.html          the main page: what Ambrogio is, and the four things worth knowing
  queues.html         deep dive: the queues, and who accepts them
  doors.html          deep dive: the two doors, and the sandbox
  agents.html          deep dive: the agents, the budget and the silence
  conversation.html   deep dive: the conversation
  styles.css          the one stylesheet, hand-written, no framework, no CDN
  logo.png            the mark — ambrogio/v2/api/android-chrome-512x512.png, drawn at 40 px
  favicon.ico         the tab — the engine's own three-frame icon
  fonts/inter.woff2   the one typeface, self-hosted (see fonts/LICENSE-inter.txt)
Dockerfile
.github/workflows/publish.yml
```

## Design

The design is fixed in `../PROGETTO.md` (its §2 the structure, §3 the visual decisions, §4
the pages, §5 the pod). Two points worth keeping in the source:

- **the palette is the product's own**, read from the engine's stylesheet
  (`ambrogio/v2/api/ui/app.css:15-16`): `--bg #14161a`, `--panel #1a1d23`, `--bar #171a1f`,
  `--fg #e8e6e3`, `--dim #8a8f98`, `--line #2a2e36`, `--accent #7aa2f7`. Do not invent a
  colour here: the mark sits on that ground;
- **the mark is the operator's art, unmodified.** `site/logo.png` is a byte-for-byte copy of
  `ambrogio/v2/api/android-chrome-512x512.png`, the largest raster the Ambrogio icon set holds
  (512×512, 121,589 bytes, sha256
  `626654acf4cc90b4b571c9ef49d1e002b60289aaabbb77db4985401e5d766fb9`); it is not redrawn and
  not re-coloured, and `.brand img` draws it at 40 px — the header's mark, not the tab's. Same
  art as the engine's own bar, which embeds the 192 of the same set.

Every UI string is English.

## Build and publish

The image is built by GitHub Actions and pushed to Docker Hub as
`tazzo/tazlab-ambrogio-site`, tagged `latest` and
`ambrogio-site-<run_number>-<sha>`. Flux picks the newest tag up and commits it into the
cluster repository, which rolls the Deployment out.

The runtime image is a single nginx stage — the wiki and the blog add a Hugo stage above it,
because their content is a tree of Markdown; this site's five pages are hand-written, so
there is nothing to generate:

```
FROM nginx:stable-alpine
COPY site/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Local preview

Any static server over `site/` is enough:

```
python3 -m http.server 8000 --directory site
```
