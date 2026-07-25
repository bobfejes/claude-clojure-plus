# metawork.md template

Starter structure for a new `metawork.md`, and the decision-entry format for logging into an existing one.

```markdown
# Metawork

This file is the project's structural memory. It records *why* the project is
organized the way it is and holds in-progress ideas for improving it. It is read
on demand (e.g. via the /meta skill), not loaded every session.

A user will request a summary of the current project structure and critical
metaproject components using `/meta summary`.

## Decisions

Append-only. Each entry is dated. Never edit or delete a past entry — when a
decision changes, add a new entry that references the one it supersedes.

<!-- newest at top -->

### YYYY-MM-DD — <short decision title>
- **Decision:** what we decided.
- **Alternatives considered:** what else was on the table.
- **Why:** the reasoning that settled it.
- **Supersedes:** (optional) the earlier decision this replaces; omit if none.

## Exploring

Mutable scratchpad. Half-formed ideas for improving the structure. Prune freely.
When an idea matures, promote it into Decisions and delete it from here.

- <idea>
```

When logging into an existing file, insert a new entry in that same format at the **top** of Decisions. Keep each field to a sentence or two, capturing the *why* rather than a description of the current tree — the tree is self-documenting and drifts; the reasoning doesn't.
