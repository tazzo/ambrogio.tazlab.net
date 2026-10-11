# step #51 — the logx vocabulary was red: declaring the key `step`

## What was wrong, and how it was found

The tree's own vocabulary gate was red, and it was red **before** this queue's rename: the writer
at `v2/queue/carry.go:479` logs a key nobody had declared.

```
$ go test ./logx/ -run TestEveryFieldAWriterUsesIsDeclared -count=1
--- FAIL: TestEveryFieldAWriterUsesIsDeclared (0.27s)
    vocabulary_test.go:289: the writer at v2/queue/carry.go:479 logs the key "step",
    which logx.FieldKeys does not declare. Declare it as logx.Identity if its value names
    the incident — a task, a run, a count — or as logx.Plain if it is a word of the fact.
```

The call site (the line the previous step's rename touched, and nothing else about it):

```
$ sed -n '478,479p' v2/queue/carry.go
                    "stopped and the queue is not closed over it",
                    logx.F("queue", q.ID), logx.F("step", next.ID))
```

It mattered beyond the one test: **the gate runs `go test ./logx/...` inside the tree it is
judging**, so a red vocabulary refuses every delivery that touches the log writers, and three
tests of `v2/runner` were failing on it — `TestTheGateRefusesATreeThatDoesNotCompile`,
`TestTheGateLetsACompilingTreeThrough`, `TestTheGateLetsAWriterThroughWhenTheKeyIsDeclared`.
Measured identically in a clean checkout of `HEAD` (`git worktree add /tmp/head-check HEAD`,
then the same command there), which is what proves the red was the trunk's and not the rename's.

## The class: `Identity`, and why it is not `Plain`

The value is `next.ID` — **which** task the line is about. That is the definition of an identity
in `logx/vocabulary.go`:

> `Plain` is a field whose value is a word of the fact: an error, a reason, a branch, a state. It
> stays in the shape, because the cause is made of these words.
> `Identity` is a field whose value names the incident and not the cause: which task, which run,
> which agent, which process, which row, how many this time. It leaves the shape.

The two classes are not a style choice, they are what the shape is built from: `shapeID`
(`v2/engine/autopilot.go:493`) is `shapeRe(logx.IdentityKeys())`, so a key declared `Identity` has
its value **and the number written after it** taken out of the cause. Declaring `step` `Plain`
would have kept every step's id in the shape, and the same refusal on two different steps would
count as two shapes — each seen once, so the note would name neither. `step` sits beside its
neighbours `task` (`t.ID`), `run` (`r.ID`) and `queue`, which are declared `Identity` for exactly
this reason.

## The change — one line

`logx/vocabulary.go`, in the identity half of `FieldKeys`, alphabetically between `steers` and
`steps`:

```go
	"steers":          Identity, // len(st.Steers)
	"step":            Identity, // next.ID, the step the line is about (v2/queue/carry.go:479),
	"steps":           Identity, // q.StepsSpent/q.StepsCap, rep.Ran(),
```

The comment names the call site, the way every other row of the table does. Nothing else moved:
the writer is not touched, the reader is not touched (it reads `IdentityKeys()` at run time), and
no list is re-typed anywhere — that is the point of the table.

## What I ran, and what it printed

All of it in `review-step51/gate.log`, from the module root `/workspace/ambrogio`:

```
$ go test ./logx/ -count=1
ok  	github.com/tazzo/ambrogio/logx	0.489s

$ go test ./v2/runner/ -run 'TestTheGateRefusesATreeThatDoesNotCompile|TestTheGateLetsACompilingTreeThrough|TestTheGateLetsAWriterThroughWhenTheKeyIsDeclared' -count=1
ok  	github.com/tazzo/ambrogio/v2/runner	15.639s

$ go test -count=1 ./v2/runner/ ./v2/engine/ ./v2/queue/
ok  	github.com/tazzo/ambrogio/v2/runner	98.445s
ok  	github.com/tazzo/ambrogio/v2/engine	4.637s
ok  	github.com/tazzo/ambrogio/v2/queue	19.556s
```

The third command is the one that needed the whole package and not only the three names: the
shape machinery lives in `v2/engine` (`shapeID`, `shapeid_test.go`) and the writer in
`v2/queue`, so a key added to the vocabulary could have moved either. Neither moved.

**A fact a future reader needs.** The vocabulary tests **walk the module's sources**, so the gate
must be run from the module root. Run from a tree that only carries symlinks into the module, the
walk finds no writers and a second test fails — measured, on the way here, running the gate from
`/workspace/ambrogio-site`:

```
vocabulary_test.go:487: logx.FieldKeys declares "worker", and no writer in this module logs it:
the vocabulary is derived from the writers, so a key nobody writes is a key nobody measured
```

That is why the declared command below is `cd /workspace/ambrogio && go test ./logx/ -count=1`,
and why the site tree (the tree this queue's steps run in) carries a `logx` symlink to
`/workspace/ambrogio/logx`, beside the `v2` and `tazlab-k8s` symlinks it already carried — so
that the declared path `logx/vocabulary.go` resolves where the step is measured.

## Where the work lives

- `/workspace/ambrogio/logx/vocabulary.go` — the declaration (this step's only source change);
- `/workspace/ambrogio-site/logx` — a symlink to `/workspace/ambrogio/logx`, so the declared path
  resolves in the tree the queue's steps run in (the same shape as the committed
  `v2 -> /workspace/ambrogio/v2` and `tazlab-k8s -> /workspace/tazlab-k8s`);
- `review-step51/gate.log` — the commands and their output;
- this file.
