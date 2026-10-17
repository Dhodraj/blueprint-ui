# The rules

Defaults for building a screen. A brief can overrule any of them, and saying
which one it overrules is part of the proposal. Attribution is in NOTICE.

## The numbers


| What | Rule |
|---|---|
| Body text | 16px or larger, line height 1.5 to 1.6 |
| Line length | 45 to 75 characters for prose |
| Heading line height | 1.1 to 1.3 |
| Type sizes | five on a screen at most |
| Font weights | two, such as 400 and 600 |
| Text contrast | 4.5:1 for body and placeholder text, 3:1 for text above 18px |
| Boundary contrast | 3:1 for component edges and for focus rings |
| Tap targets | 44 by 44 pixels, 8 pixels apart |
| Spacing scale | 4, 8, 12, 16, 24, 32, 48, 64, 96. Each step at least 25% above the last |
| Grouping | space inside a group smaller than space between groups |
| Headings | more space above a heading than below it |
| Primary action | one per view. Others are outlined or quiet |
| Greys | 8 to 10 of them. Text is never #000 |
| Brand colour | 5 to 10 shades of each |
| Shadows | nothing at rest carries one. Separate surfaces by tone |
| Cards | never nested |
| Borders | no coloured side stripe wider than 1px |
| Gradients | no gradient on text. Weight and size carry emphasis |
| States | empty, loading, one item, many items, error, disabled, hover |

Contrast ratios are WCAG 2.2 AA. The 44px target is Apple's Human Interface
Guidelines. The rest is adapted, in my own words, from pbakaus/impeccable
(Apache-2.0) and nextlevelbuilder/ui-ux-pro-max-skill (MIT).

## Dense screens

A table, a run list or a dependency view is not a landing page. For those:

- Row height stays constant. Density is a choice made once for the screen.
- Numbers align right, and a column of numbers uses tabular figures.
- A status is a word plus a shape or a position, never colour alone.
- The header row stays visible while the body scrolls.
- A long identifier truncates in the middle, with the full value available.
- Every column earns its width. A column nobody reads is a column to drop.
- An action that applies to a row lives in that row, not only in a bar above it.
