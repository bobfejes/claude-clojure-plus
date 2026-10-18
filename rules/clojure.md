---
paths: "**/*.{clj,cljs,cljc}"
---

## Clojure files (*.clj, *.cljs, *.cljc)

Conciseness serves clarity — if a terse expression hides intent, write the plain
version.

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

`as->` only when threading position genuinely varies.

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

Skip destructuring for one-line fns using a key once, in hot loops, and when the
pattern is too deep to read at a glance.

`(apply hash-map ...)` only when the data is already a flat alternating k/v
sequence. Needing `interleave`, `flatten`, or `mapcat` to get there means the
wrong tool — reach for `zipmap`, `group-by`, `frequencies`, `into` instead.

### Transformation

Compose a transducer (`into`, `transduce`, `sequence`) when the pipeline has 2+
stages and the seq is consumed once. Single-stage one-shot work stays `(map f xs)`.

### State and side effects

- Side effects at the edges; the middle is a transformation pipeline.
- `core.async` for pipelines and back-pressure, not as a generic concurrency hammer.
- Pass the world in (`(handle deps request)`) rather than reaching into a global
  atom.

### Other

- A `let` with 10+ bindings means the function is doing too much; split it.
- Type hints, `transient`/`persistent!`, and primitive math only on measured hot
  paths; primitive math constrains surrounding code.
- Docstrings on public fns give the contract and the *why*, not what the name and
  signature already say. In-function comments are rare.
- A `comment` block at the bottom of a namespace holds scratch expressions showing
  how to invoke the code.
