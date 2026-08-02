# claude-config

My personal [Claude Code](https://claude.com/claude-code) configuration,
tracked from `~/.claude`.

This repo git-ignores everything by default and re-includes only the handful of files I
actually wrote. Anything new is untracked by git by default, so if you add a file you want
tracked, add a matching `!` line to `.gitignore` or git won't see it.

## What's here

`rules/clojure.md` A rule to help Claude write more idiomatic Clojure code!

`skills/model-upgrade` Run when a new Claude model is released to optimize components
written with older models. `/model-upgrade [component]` rewrites a component for the
current model and commits an `Optimized-With:` trailer; `/model-upgrade check-version`
reads those trailers back to show what's stale.

`skills/meta` is maintainer mode for a project's own scaffolding — `/meta` to audit
structure or decide whether something belongs in `CLAUDE.md`, a rule, a skill or a hook,
`/meta summary` for a read-only inventory. Decisions get logged to an append-only
`metawork.md` that records *why*, not what.

## Using it

Clone into `~/.claude` on a fresh machine, or copy individual pieces. Nothing here is
machine-specific except the personal details in `CLAUDE.md`, which you'll want to replace.
The skills/rules are self-contained and can be dropped into any project's `.claude/`
matching subfolders.

## License

MIT — see [LICENSE](LICENSE).
