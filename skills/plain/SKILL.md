---
name: plain
description: Plain-language modes on demand — explain a concept in near-STE English, edit a draft with Orwell and Strunk & White, or walk through a long task in numbered steps. Invoke as /plain [explain|rewrite|walkthrough] <topic or text>.
argument-hint: "[explain|rewrite|walkthrough] <topic or text>"
disable-model-invocation: true
---

# Plain

The CLAUDE.md writing section sets the everyday style. This skill goes further for one
task. Pick the mode from the first argument. With no mode, choose the one that fits the
input: pasted prose means `rewrite`, a question means `explain`, a task means `walkthrough`.

All modes keep these limits:
- Never simplify to the point of being wrong. If a claim needs a caveat, keep it.
- Never change code, commands, identifiers, file names, or quoted material.
- Rules serve clarity. Break one rather than write something awkward.

## explain

Explain the topic in ASD-STE100 style, about 80% strict. The full spec reads as stiff,
so relax it where a strict rule makes the text harder to read.

- Sentences of about 20 words or fewer for explanations, 15 or fewer for instructions.
- Use one word for one meaning. Don't switch between synonyms for the same thing.
- Active voice and present tense.
- Define each technical term once, when it first appears.
- Start with what the thing is or does. Then give one concrete example. Then add detail.
- Stop when the question is answered.

## rewrite

Edit the user's draft. Keep their meaning, voice, and structure unless the structure is
the problem. Apply these, from Orwell's *Politics and the English Language* and Strunk &
White:

1. Replace stale figures of speech with plain words or a fresh concrete image.
2. Use a short word where a long one does the same job (use, not utilize).
3. Cut words that carry nothing ("in order to" becomes "to", "it is important to note
   that" goes away).
4. Use active voice unless the actor is unknown or doesn't matter.
5. Use everyday words instead of jargon, buzzwords, or foreign phrases, unless the
   reader needs the precise term.
6. Put statements in positive form ("forgot", not "did not remember").
7. Put the emphatic words at the end of the sentence.

Return the revised text first. After it, list only the changes that a reader might
question. Don't list every cut.

## walkthrough

Guide the user through a multi-step task. This mode helps when they will do the steps
themselves and may lose their place.

- First line: the first thing to do. No background before it.
- Number the steps. Each step is one action with a visible result to check.
- If there are more than about 7 steps, group them into phases and show one phase at a
  time.
- In follow-up turns, start with where they are: "Step 4 of 9: ...".
- When a step fails, say what failed and the single next action to fix it.
- Put side issues at the end under "Later". Don't interrupt the main path with them.
