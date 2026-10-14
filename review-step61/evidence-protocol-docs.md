# evidence — the two protocols, from their own documentation

## Agent Client Protocol (what the engine speaks)

Source: https://agentclientprotocol.com/get-started/introduction

> The Agent Client Protocol (ACP) standardizes communication between code editors/IDEs and
> coding agents and is suitable for both local and remote scenarios.
>
> * **Local agents** run as sub-processes of the code editor, communicating via JSON-RPC over
>   stdio.

Source: https://agentclientprotocol.com/protocol/v1/overview

> The protocol follows the [JSON-RPC 2.0] specification with two types of messages …
>
> * Client → Agent: `initialize` …
> * Client → Agent: `session/new` …
> * Client → Agent: `session/prompt` to send user message
> * Agent → Client: `session/update` notifications for progress updates
> * Client → Agent: `session/cancel` …
> * `session/request_permission` … `fs/read_text_file` … `terminal/create` …
>   `elicitation/create` …

The method surface is the one `v2/acp/protocol.go` implements. The doc index
(https://agentclientprotocol.com/llms.txt) also lists the RFDs the engine uses: "Next Edit
Suggestions" (`nes/*`), "Configurable LLM Providers" (`providers/*`), "Request Cancellation
Mechanism" (`$/cancel_request`), "Elicitation" (`elicitation/*`), "Session Config Options"
(`session/set_config_option`).

## Agent Communication Protocol (a DIFFERENT protocol — not what the engine speaks)

Source: https://agentcommunicationprotocol.dev/introduction/welcome

> ## 🚀 IMPORTANT UPDATE
> **ACP is now part of A2A under the Linux Foundation!**
>
> The **Agent Communication Protocol (ACP)** is an open protocol for agent interoperability …
> enabling agents to communicate through a standardized RESTful API …
>
> * **REST-based Communication:** ACP uses simple, well-defined REST endpoints … Unlike
>   protocols requiring specialized communication methods (such as JSON-RPC), ACP leverages
>   familiar HTTP conventions …

REST/HTTP, agents/runs/threads, MIME content — no `session/prompt`, no stdio, no JSON-RPC.
This is the protocol the operator named in the correction, and it is **not** the one Ambrogio,
the site, or `omp acp` use.

## `omp acp` — the agent process — says it itself

```
$ omp acp --help
Run Oh My Pi as an ACP (Agent Client Protocol) server over stdio
```
