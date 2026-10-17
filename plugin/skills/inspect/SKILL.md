---
name: inspect
description: Look at a screen you changed before reporting on it. Renders a page or a running app at 1440, 1024 and 375 in headless Chrome, or with the project's own screenshot tool. Then reads the images against the failures a source diff cannot show. Use after any change to a screen, and before saying a screen is done.
---

# Inspect

A source diff hides what renders. For example: A card that sits off centre. A value clipped
by its container. One screen that carries two buttons with the same label. Each of those shipped to a user, and the user found it, not the session that
made it.

The rule this skill exists to enforce: look at the picture before you say
anything about the screen.

## 1. Render

Use the project's own screenshot script where it has one: it already knows the
routes, the sign-in and the widths. Look for `look`, `shoot`, `screenshot` or
`check-screens` in its task list before writing anything.

Otherwise headless Chrome is on this machine. For a static file or a local
server:

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
for w in 1440 1024 375; do
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --screenshot="${TMPDIR:-/tmp}/shot-$w.png" --window-size="$w,2000" "$URL"
done
```

For a page behind a sign-in or a route, drive it over the DevTools protocol
instead. Use the project's own screenshot script where it has one. Render the
screen again after every change, and report only on what you rendered.

## 2. Look

Open every image with the Read tool. Reading the file list is not looking.

## 3. Judge, in this order

Each line is a failure that renders wrong while the source reads fine.

1. Placement. Is the main element where it belongs? Centre what should be
   centred, align the rest to the grid. Is there a large empty region that
   carries nothing?
2. Containment. Does any text, number or label cross or touch the edge of
   its card, column or button? Right-aligned values and long identifiers fail
   here first.
3. Duplication. Does one screen offer the same action twice? Does a control
   the user had before still exist?
4. Reachability at 375. Is every control on screen, and is each tap target
   at least 44px? Does anything require a horizontal scroll?
5. Contrast. Can you read every label against its own background, including
   a pressed, hovered or selected state?
6. Rhythm. Do spacing and type sizes come from the product's scale? Or were
   they chosen for this screen alone?
7. State. Render the states a user will meet: empty, loading, one item,
   many items, error. A screen built on fixtures hides all but one.

## 4. Report what you saw

Name what you looked at and at which widths. Where something is wrong, say
which of the seven it is. Where you could not render, say so. Do not
describe the source as though you saw it.

## Scope

This is about what renders. Colour tokens, hard-coded hex values and gradients
belong to whatever lint the project runs; they are not what this skill reads.
