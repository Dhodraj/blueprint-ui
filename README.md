# blueprint-ui

> **Superseded by [ui-skills](https://github.com/Dhodraj/ui-skills).**
> Its `ui-design` and `ui-review` carry this repository's numbers, its
> dense-screen rules and `inspect`'s seven checks, and add a `DESIGN.md`
> design system, component search across 508 registries, and a Storybook
> path. This repository still works and is left here for anyone using it.


Two skills for Claude Code, one each side of building a screen.

`blueprint` plans it. The job the screen serves, references, then a written
proposal that waits for a yes before any code. `inspect` checks what came out.
It renders the screen, looks at the images, and reports against a fixed list.

Neither guesses. The sources are data in `skills/blueprint/sources.json`, and
the numbers are in `skills/blueprint/rules.md`.

## Why

A source diff cannot show an off-centre card, a value clipped by its
container, or two buttons that do the same thing. Those reach the user, who
then has to find them. Rendering alone does not fix it either: a session can
take twelve screenshots and still report without judging them.

So the work is split. Decide what to build and from where, get agreement, then
look at the result against a list.

## Install

Clone this repo, then point Claude Code at it:

```bash
claude plugin marketplace add ./blueprint-ui
claude plugin install inspect@blueprint-ui
cp -R skills/blueprint ~/.claude/skills/blueprint
```

`inspect` carries one `PostToolUse` hook. It writes only empty marker directories under
`~/.local/state/claude-system/inspect` and makes no network call. It says
nothing unless a file that may render a screen is changed.
`CLAUDE_INSPECT=off` silences it.

## Use

```
/blueprint    before building: job, references, proposal, approval
/inspect      after building: render, look, report
```

## Adding a source

One object in `skills/blueprint/sources.json`:

```json
{
  "id": "tremor",
  "url": "https://tremor.so",
  "for": ["charts", "kpi"],
  "stack": "react+tailwind",
  "licence": "Apache-2.0",
  "install": "no CLI; Tremor Raw needs Tailwind 4"
}
```

`components`, `screens` and `patterns` are the three lists. `rejected` records
what was looked at and ruled out, with the reason, so nobody checks it twice.

Validate with `node skills/blueprint/scripts/check-sources.js`, and add
`--links` to ask every url whether it answers.

A project can keep its own `<repo>/.claude/sources.json` in the same shape.
Where both list a source, the project's entry wins. Domain-specific references
belong there, not here.

## Tests

```bash
bash tests/run.sh
```

54 cases: 20 on the source registry, 34 on the hook. No network.

## Licence

MIT, see LICENSE. The numeric defaults in `skills/blueprint/rules.md` are
adapted from other work; see NOTICE for what, from where, and what changed.
