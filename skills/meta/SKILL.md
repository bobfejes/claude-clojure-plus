---
name: meta
description: Maintainer mode for a Claude Code project — audit and improve the project's own structure, tooling, skills, rules, hooks, and CLAUDE.md, and record structural decisions in metawork.md. Use this whenever the user wants to step back from building features and instead work ON the project itself: reviewing or proposing project structure, deciding whether to add a skill/rule/hook, auditing or trimming CLAUDE.md, reconciling docs against the real tree, or logging an architectural/structural decision. Trigger on phrases like "let's do some metawork", "improve the project structure", "audit my CLAUDE.md", "should this be a skill", "is this set up right", "log a decision", or when the user explicitly invokes /meta — even if they don't use the word "metawork".
---

# Meta — project maintainer mode

This skill flips you from *building the project* into *tending the project*. Normal sessions write application code; this mode works on the scaffolding around it: directory structure, `CLAUDE.md`, `.claude/skills/`, `.claude/rules/`, `.claude/hooks/`, MCP config, and the decision record in `metawork.md`.

The distinction matters because the two activities have opposite instincts. Feature work wants to move fast and add code. Meta work wants to slow down, question structure, remove cruft, and write down *why*. When the user invokes this, they are deliberately changing gears — match that.

## The core artifact: metawork.md

Every project using this skill keeps a single `metawork.md` at the project root. It is the durable memory of how and why the project is structured the way it is. Without it, every meta session starts from zero and structural decisions get silently re-litigated or quietly contradicted.

`metawork.md` has three sections with different rules:


1. **Decisions** — an append-only, dated decision record (ADR-style). Never edit or delete past entries. When a decision is superseded, add a *new* dated entry that references the old one and explains what changed. This append-only discipline is the whole point: the value compounds only if history stays intact.
2. **Exploring** — a mutable scratchpad for half-formed ideas about improving the structure. Prune freely. When an idea here matures into a real decision, promote it into Decisions and remove it from here.

Keep entries focused on **why**, not **what**. The "what" (where files live, what scripts exist) is visible in the tree and goes stale the moment it drifts. The "why" (the reasoning, the alternatives rejected) stays true far longer and is the thing future-you and Claude actually can't reconstruct from the code.

If `metawork.md` doesn't exist when this skill runs, offer to create it from the template in `references/metawork-template.md`.

## What to do when invoked

Figure out which of these the user wants — ask only if it's genuinely ambiguous — then do it. Don't run all of them every time.

### 1. Reconcile (do this first if metawork.md exists and you haven't this session)
Before proposing anything, check whether `metawork.md` still matches reality. Read it, then scan the actual tree (`CLAUDE.md`, `.claude/`, top-level dirs). Flag any decision that the current structure contradicts. A decision record that has drifted from the truth is worse than none, because it gets trusted. Report divergences plainly; propose either fixing the tree or logging a superseding decision.

### 2. Audit structure
Review the project's scaffolding and surface concrete, prioritized improvements. Look for:
- **CLAUDE.md bloat** — it should stay small (aim under ~200 lines) and human-readable. Long reference material belongs in skills or imported files, pulled in on demand, not stuffed into the always-loaded root file. Flag stale or redundant content.
- **Skill vs. rule vs. hook mismatches** — see the decision guide below. A recurring manual check that should be a hook, a convention buried in prose that should be a rule, a multi-step workflow that should be a skill.
- **Misplaced subdirectory CLAUDE.md files** — these auto-load when Claude works in that part of the tree. Make sure that's intended and that they carry module context, not general docs.
- **Missing scaffolding** — no `/init`-generated baseline, no rules for known constraints (e.g. "never commit secrets"), conventions that exist only in your head.

Present findings as a short prioritized list with the reasoning for each, not a wall of text. Let the user pick what to act on.

### 3. Decide where something belongs
When the user asks "should this be a skill / rule / hook / just a CLAUDE.md line?", use this guide:

- **CLAUDE.md line** — a small, always-relevant fact Claude needs every session (tech stack, key commands, top-level layout). Cheap, always loaded. Reserve for things that are short and universally relevant.
- **Rule** (`.claude/rules/`) — a constraint or convention that should consistently shape behavior ("API paths use kebab-case", "always paginate list endpoints"). Declarative "how we do things here."
- **Skill** (`.claude/skills/`) — a multi-step capability or workflow that's worth invoking by name and only matters sometimes. Procedural "here's how to do X." Loaded on demand, so it can be long without costing baseline context.
- **Hook** (`.claude/hooks/`) — anything that should run *automatically and deterministically* on an event (pre-commit, post-write): linting, formatting, blocking writes to generated files, secret scanning. If the rule is "this must always happen and shouldn't depend on Claude remembering," it's a hook, not a rule.

Rule of thumb: if it must happen every time without fail → hook. If it shapes judgment → rule. If it's an invokable procedure → skill. If it's a one-line universal fact → CLAUDE.md.

### 4. Log a decision
When a structural choice is made (in this session or reported from before), append it to the Decisions section of `metawork.md` using the entry format in `references/metawork-template.md`: date, decision, alternatives considered, why. Confirm the wording with the user before writing. Never modify prior entries — supersede instead.

## Boundaries

- This skill is for working *on* the project's structure, not its features. If the user drifts into actual feature implementation, that's fine — just note you're leaving meta mode so the gear-change is explicit.
- Editing `CLAUDE.md`, adding skills/rules/hooks, and writing to `metawork.md` are normal edits — make them directly. But **confirm wording with the user before appending a decision**, since decision entries are append-only and meant to be permanent.
- Don't let `metawork.md` get imported into `CLAUDE.md`'s always-loaded path. It's an on-demand document; a single pointer line in CLAUDE.md ("structural decisions live in metawork.md") is enough.

## Reference files
- `references/metawork-template.md` — the starter structure for a new `metawork.md` and the exact decision-entry format. Read it when creating the file or logging a decision.
