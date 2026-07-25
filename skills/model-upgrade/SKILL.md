---
name: model-upgrade
description: Maintainer mode for Claude meta-tooling. Run when a new Claude model is available to re-optimize a specific component — a skill, rule, hook, CLAUDE.md, or other tooling — for that model. Trigger when the user explicitly invokes /model-upgrade [component], e.g. /model-upgrade skill model-upgrade to run it against this skill itself. Also handles /model-upgrade check-version [component], which reports when each component was last optimized and by which model, without changing anything.
---

# Model-upgrade — Claude meta-tooling maintainer mode

A component written for an older model often carries scaffolding a newer one no longer needs: explanations of things now known implicitly, defensive restatements, worked examples that add nothing. This skill strips that back without weakening the component.

Two modes:

- `/model-upgrade check-version [component]` — report only, change nothing. See below.
- `/model-upgrade [component]` — the upgrade itself, steps 1–5.

## check-version — report, don't touch

Named component: resolve its path as in step 1 and report its last upgrade. Component omitted: report every component in scope.

```
for f in CLAUDE.md settings.json rules/*.md skills/*/SKILL.md; do
  r=$(git log -1 --grep='^Optimized-With:' --date=short \
        --format='%h %ad  %(trailers:key=Optimized-With,valueonly)' -- "$f")
  printf '%-38s %s\n' "$f" "${r:-never optimized}"
done
```

Report the results as a short table, flagging anything whose model differs from the one you are running — those are the candidates for an upgrade run. A path with no matching commit has never been through this skill, which is not a problem in itself; say so without implying it needs fixing.

Then stop. This mode never edits or commits, even if a component looks obviously stale — offer the upgrade command instead and let the user decide.

## 1. Resolve the target

If the user didn't name a component, ask. Otherwise locate it — check both user scope (`~/.claude/`) and the current project's `.claude/`:

- skill → `skills/<name>/SKILL.md` plus its `references/`
- rule → `rules/<name>.md`
- hook → the `hooks` block in `settings.json` and any script it points at
- CLAUDE.md → user-scope and project-scope files

If the name is ambiguous across scopes, ask which.

## 2. Check whether this is already done

If the component is in a git repo, find the last upgrade of that path:

```
git log -1 --grep='^Optimized-With:' --date=short \
  --format='%h %ad  %(trailers:key=Optimized-With,valueonly)' -- <path>
```

If that names the model you are currently running, say so and stop — there's nothing new to bring. Proceed only if the user asks.

If it isn't in a repo, there's no record to check. Continue, but say so in the final report: edits there aren't recoverable.

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

## 5. Report and commit

Summarize the change in chat: every deletion in one line with its reason, plus anything added. The user should be able to judge it without reading the diff.

Then commit — the git log is the durable record, so nothing goes in the files themselves.

Before committing, check the target paths were already clean (`git status --short -- <paths>`). If they carried uncommitted edits from before this session, stop and ask rather than folding unrelated work into the upgrade commit. Commit only the paths you touched:

```
Optimize <component> for <model>

<why each significant removal or addition was made>

Optimized-With: <model>
```

Write the model's product name (e.g. `Claude Opus 5`) and keep it identical across runs — step 2 matches on that trailer.

Never add metadata blocks, "last optimized" comments, or changelog entries to the component. The log answers that already, and in-file metadata costs context on every load.

If the component isn't in a repo, leave the files edited, report, and let the user record it however they like.
