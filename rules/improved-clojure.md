---
paths: "**/*.{clj,cljs,cljc}"
---

## Clojure Guidelines

Write Clojure the way an experienced practitioner would: lean on the core
library, let data flow through small pure functions, and reach for the
simplest construct that fits. Conciseness is a means to clarity, not a goal
in itself — if a terse expression hides intent, prefer the plain version.

### Core principles

- Pure functions, immutable data, value-oriented design. Side effects live
  at the edges; the middle is a transformation pipeline.
- Functions are small and named for what they return, not how they work.
- Data is data. Prefer plain maps and vectors over records, classes, or
  custom types. Reach for records only when you need protocol dispatch or
  measurable performance gains.
- Namespaced keywords (`:user/id`, `::status`) for keys that travel between
  systems or namespaces. Plain keywords are fine locally.

### Choosing the right construct

#### Lookups: keywords, maps, and sets are functions

Instead of:
```
(get m :id)
(get s x)
(get m1 k)
```
Use:
```
(:id m)
(s x)
(m1 k)
```

Two caveats: use explicit `get` when the key may be `nil` or non-keyword,
and when readers need to see the lookup operation clearly (rare).

#### Threading: pick the macro that matches the data shape

- `->` when the value is the first arg (most fns operating on maps/records).
- `->>` when the value is the last arg (most seq fns: `map`, `filter`, `reduce`).
- `as->` only when threading position genuinely varies; don't reach for it
  to "be clever."
- `some->` / `some->>` when any step may yield `nil` and you want short-circuit.
- `cond->` / `cond->>` for conditional accumulation — but see below.
- `doto` for a sequence of side-effecting calls on the same object (Java interop).

#### `cond->` is great, but not when something simpler works

The original guidance still holds: prefer `select-keys` + `merge`/`assoc`
when you're building a map from optional pieces.

Instead of:
```
(let [{:keys [k b?]} (fn1)]
  (cond-> {:id "xyz"}
    k         (assoc :k k)
    (some? b?) (assoc :b? b?)))
```
Use:
```
(-> (fn1)
    (select-keys [:k :b?])
    (assoc :id "xyz"))
```

`cond->` shines when the conditions are *not* "is this key present" but
genuine branching logic (`(admin? user)`, `(seq xs)`, …).

#### `if` vs `when` vs `cond`

- `when` for one-armed conditionals, especially when the body is a side
  effect or you want `nil` on the false branch.
- `if` for two-armed conditionals with both values meaningful.
- `cond` for three or more branches. Use `:else` (not `true` or `:default`)
  as the final clause.
- `condp` when every branch tests the same predicate against a value.
- `case` when dispatching on compile-time constants — it's a jump table,
  much faster than `cond`.

#### Bindings with conditionals

Reach for `if-let`, `when-let`, `if-some`, `when-some` instead of nested
`let` + `if`. Use `-some` variants when `false` is a valid value and only
`nil` should fail the binding.

```
(when-let [user (find-user id)]
  (notify user))
```

#### Destructuring

Use it where it clarifies the shape of the input. Skip it when:
- The function is one line and the keys are used once — `(:id user)` is fine.
- You're in a hot loop where the extra map ops matter.
- The destructuring pattern is so deep that a reader can't see it at a glance.

Prefer `:keys` over individually naming bindings:
```
(defn greet [{:keys [first-name last-name]}]
  (str "Hello, " first-name " " last-name))
```

For namespaced keys, use the namespaced `:keys` form:
```
(defn handle [{:user/keys [id email]}]
  ...)
```

### Sequences and transformation

#### Don't chain map/filter when a transducer composes cleaner

If you're going to consume the seq once and the pipeline has 2+ stages,
reach for `transduce`, `into`, or `sequence` with a transducer:

```
(into []
      (comp (map parse-line)
            (filter valid?)
            (map ->record))
      lines)
```

For one-shot single-stage work, `(map f xs)` is perfectly fine — don't
over-engineer.

#### Use `reduce` over `loop`/`recur` when accumulating

`loop`/`recur` is a code smell when the underlying intent is "fold this
collection into a value." Save it for cases where you genuinely need
multiple state variables that don't fit in a single accumulator.

#### `seq` over `(empty? ...)` and `(count ...) > 0`

Idiomatic Clojure uses `seq` to test for non-emptiness, especially in
`when`/`if`:
```
(when (seq xs)
  (process xs))
```

#### Avoid `(apply hash-map ...)` and friends when better alternative exists

- `(zipmap ks vs)` instead of `(apply hash-map (interleave ks vs))`.
- `(into {} (map ...))` for transforming pairs into a map.
- `(group-by f xs)`, `(frequencies xs)`, `(partition-by f xs)` — know these
  exist before reinventing them.

Use (apply hash-map ...) only when data is already a single, flat sequence of
alternating keys and values (like & kwargs). If you have to call interleave,
flatten, or mapcat to get your data into that shape, you are probably using
the wrong  tool.

### Naming conventions

- `predicate?` — returns boolean (or truthy/falsy).
- `mutate!` — performs side effects (state change, I/O, mutation).
- `lower-level*` — "raw" or unwrapped variant of a public fn.
- `->Type` — constructor.
- `Type->other` / `from->to` — conversion functions.
- `kebab-case` for everything except Java interop where `camelCase` is forced.

### Avoid these anti-patterns

- `def` inside a function — use `let`. `def` always interns at the
  namespace level, even when nested.
- `(count coll)` to test emptiness — use `seq` or `empty?`.
- Re-binding via shadowing when a new name would be clearer.
- Over-deep `let` blocks. If a `let` has 10+ bindings, the function is
  doing too much; split it.
- Reaching for macros when a higher-order function works. Macros are for
  syntax, not for "I want to avoid passing a function."
- `(if x true false)` — `x` (or `(boolean x)` if you really need a bool).
- `(if (not x) a b)` — flip the branches: `(if x b a)`.
- Returning different shapes from different branches of the same fn. If
  callers must `cond` on the return shape, you've moved the complexity, not
  removed it.

### State and side effects

- `atom` for independent state. `swap!` and `reset!` are your tools.
- `ref` + `dosync` only when you need coordinated updates across multiple
  refs — rare in practice.
- `agent` for async, serialized side effects.
- `core.async` channels for pipelines and back-pressure, not as a generic
  concurrency hammer.
- Keep state out of the function signature when you can. A function that
  takes the world as an argument (`(handle deps request)`) is easier to
  test than one that reaches into a global atom.

### Performance — only when it matters

- Profile before optimizing. Clojure is fast enough for most code.
- Type hints (`^long`, `^String`) eliminate reflection in hot interop.
- `transient`/`persistent!` for tight inner loops building large collections.
- Transducers avoid intermediate seq allocation.
- `set!` and primitive math are last resorts, and they constrain what you
  can do with the surrounding code.

### Comments and docstrings

- Docstrings on public functions explain *why* and the contract — not
  what's already obvious from the name and signature.
- In-function comments are rare. If you need one, it's usually a sign the
  code can be clearer.
- `;;` for line comments above the line, `;` for trailing comments. Two
  semicolons is conventional and tooling formats them differently.

### REPL-driven development

- Write small functions you can exercise at the REPL.
- `comment` blocks at the bottom of namespaces hold scratch expressions
  that document how to invoke the code:
  ```
  (comment
    (process-batch (load-fixtures :small))
    (reset-state!)
    ,)
  ```
