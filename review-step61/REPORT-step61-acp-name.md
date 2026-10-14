# Step 61 — the name of the protocol on the site

**Queue #61, role worker-external. Operator, 2026-10-12:**

> "c'e' scritto a un certo punto che usiamo ACP e vuol dire 'Agent Client Protocol', ma e'
> sbagliato: ACP vuol dire 'Agent Communication Protocol'. Quindi lancia un task per
> verificare, controllare e correggere questa cosa sul sito."

The order asked: **verify, then check, then correct.** The correction is about what `ACP`
stands for, not about the acronym; the acronym was not to be renamed on a guess.

## Verdict (the honest answer)

**The site is CORRECT. Nothing was changed.** The `ACP` that Ambrogio speaks — and that the
site names — *is* the **Agent Client Protocol**, and only that. The expansion the operator
proposes, **Agent Communication Protocol**, names a *different* protocol that the engine does
not speak. Applying the correction would have made the site say something false, so the
correction was not applied.

`Agent Communication Protocol` (BeeAI / Linux Foundation, now folded into A2A) is a **REST /
HTTP** agent-interoperability protocol — agents, runs, threads, MIME content; its own docs
open with *"ACP uses simple, well-defined REST endpoints … unlike protocols requiring
specialized communication methods (such as JSON-RPC)"*. It has no `session/prompt`, no
`session/request_permission`, no stdio transport. Ambrogio does none of that: it drives
`omp acp` over **JSON-RPC on stdio**, with exactly the Agent Client Protocol's method surface.

## What the verification read, and what it printed

Four independent sources, all agreeing.

**1. The site's own text.** The site names the protocol in exactly two places, and both
already spell it *Agent Client Protocol*:

```
ambrogio-site/site/index.html:49:  things. Ambrogio supervises resident agent processes over the Agent Client Protocol,
PROGETTO.md:189:                   over the Agent Client Protocol without two agents in one place; one HTTP API and one event
```

`AVANZAMENTO.md` and `RICERCA.md` do not name the protocol at all (the only "protocol" words
in them are "the queue engine's own protocol", `PROGETTO.md:272`, and "the Open Graph
protocol", `AVANZAMENTO.md:126` — neither is ACP). **The page's metadata** (`<title>`,
`<meta name="description">`, the `og:*` block) names no protocol, so there was nothing to
correct there either. The site and its documents already agree.

**2. What the engine's own source says it speaks.**

```
/workspace/ambrogio/README.md:8-9      "…**supervises AI agents over the Agent
                                         Client Protocol** (`omp acp`)…"
/workspace/ambrogio/v2/worker/acp.go:40 "…an agent that speaks the Agent
                                         Client Protocol, driven by the hub."
/workspace/ambrogio/v2/acp/acp.go:1     "Package acp is the hub as the **client** of an
                                         agent that speaks the Agent Client Protocol."
/workspace/ambrogio/v2/worker/acp.go:757 const acpTurn = "You are an agent of Ambrogio
                                         speaking the Agent Client Protocol. …"
```

That last line is the transport prompt the engine hands **every** ACP agent — it is
character-for-character the sentence this step's own task carries, which is the strongest
possible proof of which protocol is in play.

**3. The process the dispatcher starts, `omp acp`, says it itself.**

```
$ omp acp --help
Run Oh My Pi as an ACP (Agent Client Protocol) server over stdio
```

and the dispatcher starts exactly that (`v2/queue/dispatch.go:743`:
`prog, args := d.Agent, []string{"acp"}`; `v2/cmd/ambrogio/main.go:391`:
`r.Worker = &worker.ACP{Program: "omp", Args: []string{"acp"}}`). The method surface the
client implements — `initialize`, `authenticate`, `session/new`, `session/list`,
`session/prompt`, `session/update`, `session/request_permission`, `fs/read_text_file`,
`fs/write_text_file`, `terminal/*`, `elicitation/*`, `session/set_config_option`, `nes/*`,
`$/cancel_request` — is the Agent Client Protocol's v1 surface, including the methods added by
its RFDs (Next Edit Suggestions, Configurable LLM Providers, Request Cancellation,
Elicitation, Session Config Options).

**4. The protocol's own documentation.**

- **Agent Client Protocol** — `https://agentclientprotocol.com` — *"standardizes
  communication between code editors/IDEs and coding agents"*, *"JSON-RPC 2.0"*, agents as
  sub-processes *"communicating via JSON-RPC over stdio"*; its method list is the one the
  engine implements (`session/new`, `session/prompt`, `session/update`,
  `session/request_permission`, `fs/read_text_file`, `terminal/create`, `elicitation/create`,
  `session/set_config_option`, …).
- **Agent Communication Protocol** — `https://agentcommunicationprotocol.dev` — *"an open
  protocol for agent interoperability"* over *"a standardized RESTful API"*, *"REST-based
  Communication … simple, well-defined REST endpoints"*; **not** the engine's protocol.

## Files and lines changed

**None.** No file in the site, in its metadata, or in `PROGETTO.md` / `AVANZAMENTO.md` was
edited — the expansion in use matches the protocol the engine speaks. The files inspected,
with the lines that carry (or would carry) the name:

| File | Line | Reads |
|---|---|---|
| `ambrogio-site/site/index.html` | 49 | "…over the Agent Client Protocol," |
| `PROGETTO.md` | 189 | "…over the Agent Client Protocol…" |
| `AVANZAMENTO.md` | — | no mention of ACP |
| `ambrogio-site/site/{queues,doors,agents,conversation}.html` | — | no mention of ACP in text or metadata |

Added (work artifacts, no site text touched): this report, `verify-acp.sh`,
`evidence-verify.log`, `evidence-protocol-docs.md` — all under `review-step61/`.

## The site still answers

```
$ for p in index queues doors agents conversation; do … curl -w '%{http_code}' …/$p.html; done
index.html     200
queues.html    200
doors.html     200
agents.html    200
conversation.html 200
```

and the **LIVE page** spells the protocol `Agent Client Protocol`:

```
$ curl -s https://ambrogio.tazlab.net/ | grep -o 'Agent [A-Za-z]* Protocol' | sort -u
Agent Client Protocol
```

## Reproduce

```
sh review-step61/verify-acp.sh      # exit 0 → the four sources agree with the site
```

## What this leaves

The site is right; the confusion is the operator's own. If the operator still wants the words
changed, the change would be *adding* a disambiguating line ("…the Agent **Client** Protocol
(ACP) — not the Agent Communication Protocol of BeeAI") rather than renaming anything — but
that is the operator's call, and this step does not invent it.
