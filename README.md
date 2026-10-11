# ambrogio.tazlab.net

The presentation site for **Ambrogio**, the agent orchestrator of tazlab.net: one Go binary that
owns one directory, opens work as tasks, carries queues with agents, and keeps the trace of what
is done.

Static pages served by nginx, installed in the tazlab-k8s cluster the same way the wiki, the blog
and the teaching site are: a GitHub Actions workflow builds and pushes the image to Docker Hub as
`tazzo/tazlab-ambrogio-site`, Flux picks the tag up and commits it into the cluster repository,
and a Flux Kustomization carries it.

The project's documents live here too: `RICERCA.md`, `PROGETTO.md`, `AVANZAMENTO.md`.
