# ambrogio-site

The source of [ambrogio.tazlab.net](https://ambrogio.tazlab.net/) — the presentation site
for **Ambrogio**, the resident-agent hub of tazlab.net.

Plain static HTML and one stylesheet, served by nginx. No database, no backend, nothing
computed at request time: the pod holds static files only.

## Layout

```
site/
  index.html          the main page
  what-it-does.html   deep dive: agents and the work given to them
  how-it-works.html   deep dive: the runtime, and how this site is delivered
  about.html          deep dive: where Ambrogio sits in tazlab.net
  styles.css          the one stylesheet
  logo.svg            the mark (also inlined in each page's header)
  fonts/inter.woff2   the one typeface, self-hosted (no CDN)
Dockerfile
.github/workflows/publish.yml
```

## Build and publish

The image is built by GitHub Actions and pushed to Docker Hub as
`tazzo/tazlab-ambrogio-site`, tagged `latest` and
`ambrogio-site-<run_number>-<sha>`. Flux picks the newest tag up and commits it into the
cluster repository, which rolls the Deployment out.

The runtime image is a single nginx stage:

```
FROM nginx:stable-alpine
COPY site/ /usr/share/nginx/html
EXPOSE 80
```

## Local preview

Any static server over `site/` is enough:

```
python3 -m http.server 8000 --directory site
```
