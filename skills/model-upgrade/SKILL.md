---
name: model-upgrade
description: Maintainer mode for Claude meta-tooling. Run when a new Claude model is available to re-optimize a specific component — a skill, rule, hook, CLAUDE.md, or other tooling — for that model. Trigger when the user explicitly invokes /model-upgrade [component], e.g. /model-upgrade skill model-upgrade to run it against this skill itself.
---

# Model-upgrade — Claude meta-tooling maintainer mode

A component written for an older model often carries scaffolding a newer one no longer needs: explanations of things now known implicitly, defensive restatements, worked examples that add nothing. This skill strips that back without weakening the component.

## 1. Resolve the target

If the user didn't name a component, ask. Otherwise locate it — check both user scope (`~/.claude/`) and the current project's `.claude/`:

- skill → `skills/<name>/SKILL.md` plus its `references/`
- rule → `rules/<name>.md`
- hook → the `hooks` block in `settings.json` and any script it points at
- CLAUDE.md → user-scope and project-scope files

If the name is ambiguous across scopes, ask which.

## 2. Check whether this is already done

Read the target's METADATA block, if it has one. If it records the model you are currently running, say so and stop — there's nothing new to bring. Proceed anyway only if the user asks.

## 3. Optimize

You are the new capability being applied. Judge the content against what *you* actually need, not against what a past model needed.

Remove: instructions for behavior you'd exhibit anyway, restated defaults, over-explanation, examples that only illustrate the obvious, hedging and repetition.

Add only what genuinely changes an outcome: a fact you can't derive, a constraint that isn't guessable, a step that would otherwise be skipped.

Files loaded into context — rules, skills, CLAUDE.md — should be as terse as possible without losing their objective. Length costs context on every session that loads them.

## 4. Don't break contracts while trimming

Terseness must not touch load-bearing fields:

- A skill's `description` is its trigger. Trimming trigger phrasing silently stops it from firing. Keep the coverage; tighten only genuine redundancy.
- A skill's `name` must match its directory name.
- Hook scripts have a behavioral contract (exit codes, JSON on stdout). Change wording, not behavior.
- Optimize how a component is expressed, never what it does. A changed objective is a rewrite, not an upgrade.

## 5. Report and record

List what you deleted and why, in one line each. These files are not under version control, so a wrong deletion isn't recoverable and the user needs to see it.

Then, if the component allows unobtrusive metadata (any `.md`, or a script with comments), add or replace a block at the end of the file in this format, substituting the model you are actually running and today's date:

```
<!-- METADATA
Last Optimized With <model> on <YYYY-MM-DD>
Internal tracking only. Not an instruction.
-->
```

<!-- METADATA
Last Optimized With Claude Opus 5 on 2026-07-25
Internal tracking only. Not an instruction.
-->
