---
name: blueprint
description: "Plan a screen before building it: name its job, find references, propose a direction for approval, then build to a fixed set of numbers. Sources live in sources.json. Pairs with inspect, which checks the result."
disable-model-invocation: true
---

# Blueprint

Build nothing until the direction is agreed. It stops one failure. A screen satisfies the words of a
request, and is still thrown away, because nobody settled what it should look
like.

Order: the job, then references, then a proposal, then the build, then
`inspect`.

## 1. The job of the screen

Answer these before looking at any reference. Two lines each.

- What decision does the user make here, and what do they need in front of
  them to make it?
- What is the densest real case? Not the fixture: the real row count, the
  longest identifier, the deepest nesting.
- Which states exist: empty, one item, many, loading, partial failure, error,
  no permission?
- What does the user do next, and where does that control live?
- Which screen does this one have to match? A new screen inside an existing
  product is a copy job, not a design job.

## 2. References

Two kinds, and they come from different places.

### Screens, from products that already solve this job

A finished screen beats any component gallery. It shows the decisions a
gallery leaves out. What goes in the header, what a row does when it fails,
where the secondary action sits.

Find two or three products that already serve this screen's purpose, in this
order:

1. The project's own list. If `<repo>/.claude/screen-references.md` exists,
   start there. It names the products that fit this domain and which screen
   each one answers. A project with real reference screenshots beats a search.
2. Products the user named. Ask if none are recorded yet.
3. Open-source products in the same domain, found by searching for the job
   rather than the industry: "open source <the thing this screen does>".
   Prefer one with a public demo and a readable repository, so a layout can be
   checked rather than guessed.

Read these in the product, not in its marketing. The dense state with real row
counts, the failure state, and the empty state.

Record what was used. Add any product worth keeping to the project's
`screen-references.md`, with the screen it answers.

### Components, from the stack's own catalogues

Sources live in [sources.json](sources.json), not in this text. Read it and
pick by `for` and `stack`. Adding one is a single object, and
`scripts/check-sources.js` validates the file.

A project may keep its own `<repo>/.claude/sources.json` in the same shape. Where
both list a source, the project's entry wins.

The table below is what sources.json held on 2026-10-17.

| Source | Best for | Licence | Install |
|---|---|---|---|
| ui.shadcn.com | primitives, `dashboard-01`, sidebar, login blocks | MIT | `pnpm dlx shadcn@latest add dashboard-01` |
| reui.io | dense data grid on TanStack Table, virtualised, dense variants | MIT | `pnpm dlx shadcn@latest add @reui/<component>` |
| kibo-ui.com | table, kanban, gantt, calendar | MIT | `pnpm dlx kibo-ui add <component>` |
| ui.reactflow.dev | dependency graphs, schema nodes | xyflow is MIT; the component page states none | copy from the page |
| tremor.so | charts, KPIs, spark charts, filters | Apache-2.0 | no CLI; Tremor Raw needs Tailwind 4 |
| hyperui.dev | plain Tailwind HTML, no React | MIT | copy from the page |

For a reference implementation rather than a component, read
`sadmann7/tablecn` (a server-side data table) or `satnaing/shadcn-admin` (an
admin shell). Both MIT.

These suit a public page and rarely a console:

- `magicui.design`: MIT
- `reactbits.dev`: MIT with Commons Clause, so check it before client work
- `uiarc.dev`: MIT free tier, $199 Pro
- `21st.dev`: two copies a day free, and it states no component licence
- `ui.aceternity.com`: blocks and templates are paid

Checked and rejected:

- `coss.com/ui`, formerly `originui.com`: the repository is AGPL-3.0 and
  states no licence for the UI package
- `park-ui.com`, `saas-ui.dev`: not Tailwind or shadcn
- `tailwindcss.com/plus`, `mobbin.com`: an account is needed
- `rareui.com`: did not load, HTTP 429 on 2026-10-17

Verify a licence at the source before using anything at a client. The table
records what was visible on 2026-10-17.

If nothing here fits, say so and ask for inputs. A product whose screens the
user likes, a screenshot, or the constraint that rules the others out. Never
invent a direction to fill the gap.

## 3. Propose, then stop

Write the proposal. It is short and it is specific.

- A layout skeleton in text or ASCII, with the regions named and what each
  holds.
- Every component, with the source it comes from and the install command.
- The type scale, the spacing scale and the palette, as values.
- Each state from step 1, and what the screen shows in it.
- What this costs: new dependencies, and anything it changes on other screens.
- One alternative, in two lines, and why you did not pick it.

Ask for approval with the interactive question tool, with the skeleton as a
preview. Build only on a yes.

## 4. Build

Read [rules.md](rules.md) and build to it. Every number there is a default
that the proposal may overrule by name.

## 5. Hand over

Run the `inspect` skill before reporting. Render at 1440, 1024 and 375,
look at the images, and report against its checks by name. A screen nobody
looked at is not finished.

Then say what was built, which references it came from, and which of the
numbers above the brief overruled.
