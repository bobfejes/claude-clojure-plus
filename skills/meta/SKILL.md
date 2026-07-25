---
name: meta
description: Maintainer mode for a Claude Code project — audit and improve the project's own structure, tooling, skills, rules, hooks, and CLAUDE.md, and record structural decisions in metawork.md. Use this whenever the user wants to step back from building features and instead work ON the project itself: reviewing or proposing project structure, deciding whether to add a skill/rule/hook, auditing or trimming CLAUDE.md, reconciling docs against the real tree, summarizing the current structure and meta components, or logging an architectural/structural decision. Trigger on phrases like "let's do some metawork", "improve the project structure", "audit my CLAUDE.md", "should this be a skill", "is this set up right", "log a decision", "summarize my project setup", or when the user explicitly invokes /meta — even if they don't use the word "metawork".
---

# Meta — project maintainer mode

Work on the scaffolding, not the features: directory structure, `CLAUDE.md`, `.claude/skills/`, `.claude/rules/`, `.claude/hooks/`, MCP config, and the decision record in `metawork.md`. The user invoking this is deliberately changing gears — slow down, question structure, remove cruft, write down *why*.

## The core artifact: metawork.md

Every project using this skill keeps one `metawork.md` at the project root, with two sections:

1. **Decisions** — append-only, dated, ADR-style. Never edit or delete a past entry; supersede it with a new dated entry that references the old one and says what changed. The record only compounds if history stays intact.
2. **Exploring** — mutable scratchpad for half-formed structural ideas. Prune freely; promote matured ideas into Decisions and delete them here.

Entries capture **why**, not **what**. The tree already documents what exists and drifts the moment it changes; the reasoning and the rejected alternatives are what can't be reconstructed later.

If `metawork.md` doesn't exist, offer to create it from `references/metawork-template.md`.

## What to do when invoked

Pick the one the user wants — ask only if genuinely ambiguous. Don't run all five.

### 1. Reconcile — first, if metawork.md exists and you haven't yet this session
Read `metawork.md`, scan the real tree (`CLAUDE.md`, `.claude/`, top-level dirs), and flag decisions the current structure contradicts. A drifted decision record is worse than none because it still gets trusted. Propose either fixing the tree or logging a superseding decision.

### 2. Audit structure
Surface concrete, prioritized findings — a short list with reasoning, not a wall of text — and let the user pick:
- **CLAUDE.md bloat** — keep it under ~200 lines. Reference material belongs in on-demand skills or imports, not the always-loaded root file.
- **Skill/rule/hook mismatches** — a manual check that should be a hook, a convention buried in prose that should be a rule, a workflow that should be a skill.
- **Subdirectory CLAUDE.md files** — these auto-load when working in that subtree. Confirm that's intended and that they carry module context, not general docs.
- **Missing scaffolding** — no baseline, no rules for known constraints, conventions that live only in the user's head.

### 3. Decide where something belongs
- **CLAUDE.md line** — short, universally relevant fact needed every session (stack, key commands, layout). Always loaded.
- **Rule** (`.claude/rules/`) — a constraint that should consistently shape judgment ("API paths use kebab-case").
- **Skill** (`.claude/skills/`) — an invokable multi-step procedure that only matters sometimes. On-demand, so length is cheap.
- **Hook** (`.claude/hooks/`) — must run automatically and deterministically on an event: formatting, secret scanning, blocking writes to generated files. If it can't depend on Claude remembering, it's a hook.

### 4. Log a decision
Append to Decisions using the entry format in `references/metawork-template.md`. Confirm the wording with the user before writing — entries are permanent. Never modify a prior entry; supersede it.

### 5. Summarize — `/meta summary`
Report the project's current structure and meta components. Read-only: this mode never edits, even if something looks obviously wrong. Cover, as a compact list or table:
- Root layout — top-level dirs and what each holds.
- `CLAUDE.md` — line count (flag if over ~200) and what it covers; note any subdirectory `CLAUDE.md` files and their scope.
- `.claude/` inventory — each skill, rule, and hook with a one-line purpose. For rules, include the `paths` glob; two rules matching the same glob both load, which is worth flagging.
- MCP servers, if configured.
- `metawork.md` — the most recent decisions and anything currently in Exploring.

Mention drift you notice in passing, but don't fix it here — offer Reconcile or Audit instead.

## Boundaries

- If the user drifts into feature implementation, that's fine — say you're leaving meta mode so the gear-change is explicit.
- Edits to `CLAUDE.md`, skills, rules, and hooks are normal edits; make them directly. Decision entries are the exception that needs confirmation first.
- Don't let `metawork.md` be imported into `CLAUDE.md`'s always-loaded path. A single pointer line there is enough.
