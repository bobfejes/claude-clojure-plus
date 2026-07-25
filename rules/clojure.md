---
paths: "**/*.{clj,cljs,cljc}"
---

## Clojure Guidelines

- Prefer pure functions, immutable data, and idiomatic clojure over imperative and OO styles
- Use destructuring in function args where it aids clarity but not where performance is critical

## Idiomatic Clojure Prefs

# cond-> is great but not when select-keys is cleaner

Instead of:
```
(let [{:keys [k b?]} (fn1)]
  (cond-> {:id "xyz"}
    k (assoc :k k)
    (some? b?) (assoc :b? b?)))
```
Use:
```
(-> (fn1)
    (select-keys [:k :b?])
    (assoc :id "xyz"))
```

# Prefer idiomatic clojure use of sets, maps, and keys as fns instead of `get` explicitly

Instead of:
`(get map1 x)` and `(get set1 x)` and `(get x :y)`
Use:
`(map1 x)` and `(set1 x)` and `(:y x)`
