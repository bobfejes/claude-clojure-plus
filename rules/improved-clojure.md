---
paths: "**/*.{clj,cljs,cljc}"
---

## Clojure Guidelines

Lean on the core library; let data flow through small pure functions. Conciseness
serves clarity — if a terse expression hides intent, write the plain version.

### Data and shape

- Plain maps and vectors over records, classes, or custom types. Records only for
  protocol dispatch or measured performance wins.
- Namespaced keywords (`:user/id`, `::status`) for keys crossing namespace or
  system boundaries; plain keywords locally.
- Don't return different shapes from different branches of one fn. If callers
  must `cond` on the return shape, the complexity moved rather than went away.

### Choosing constructs

Keywords, maps, and sets are functions — `(:id m)`, `(s x)`, `(m1 k)` over `get`.
Use explicit `get` only when the key may be `nil` or a non-keyword.

`as->` only when threading position genuinely varies — not to be clever.

Prefer `select-keys` + `assoc`/`merge` over `cond->` when the conditions are just
"is this key present":

```
;; instead of
(let [{:keys [k b?]} (fn1)]
  (cond-> {:id "xyz"}
    k          (assoc :k k)
    (some? b?) (assoc :b? b?)))
;; use
(-> (fn1)
    (select-keys [:k :b?])
    (assoc :id "xyz"))
```

`cond->` earns its place when conditions are genuine branching logic
(`(admin? user)`, `(seq xs)`).

Destructure where it clarifies input shape. Skip it for one-line fns using a key
once, in hot loops, and when the pattern is too deep to read at a glance.

`(apply hash-map ...)` only when the data is already a flat alternating k/v
sequence. Needing `interleave`, `flatten`, or `mapcat` to get there means the
wrong tool — reach for `zipmap`, `group-by`, `frequencies`, `into` instead.

### Transformation

Compose a transducer (`into`, `transduce`, `sequence`) when the pipeline has 2+
stages and the seq is consumed once. Single-stage one-shot work stays `(map f xs)`
— don't over-engineer.

### State and side effects

- Side effects at the edges; the middle is a transformation pipeline.
- `atom` for independent state, `ref` + `dosync` only for coordinated multi-ref
  updates, `agent` for async serialized effects.
- `core.async` for pipelines and back-pressure, not as a generic concurrency hammer.
- Pass the world in (`(handle deps request)`) rather than reaching into a global
  atom — it tests better.

### Other

- Macros are for syntax. Wanting to avoid passing a function isn't a reason.
- A `let` with 10+ bindings means the function is doing too much; split it.
- Profile before optimizing. Type hints, `transient`/`persistent!`, and primitive
  math are for measured hot paths, and the last constrains surrounding code.
- Docstrings on public fns give the contract and the *why*, not what the name and
  signature already say. In-function comments are rare and usually signal unclear
  code. `;;` above a line, `;` trailing.
- `comment` blocks at the bottom of a namespace hold scratch expressions showing
  how to invoke the code; a trailing `,` keeps the last form easy to edit:
  ```
  (comment
    (process-batch (load-fixtures :small))
    (reset-state!)
    ,)
  ```
