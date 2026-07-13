---
name: lexis-clean
description: >
  Audit and clean up a lexis-revealjs Quarto slide deck (`.qmd`). Use when the
  user asks to clean, lint, tidy, audit, or check a lexis deck — finds render
  errors, silent no-ops (missing class dots, malformed shortcodes), leftover
  xaringan syntax (`.codeNN`, `.class[text]`, `.leftcol`), nested divs that
  should combine into one, and layout smells; reports findings by severity,
  then applies the fixes the user approves.
metadata:
  author: John Paul Helveston
  repo: https://github.com/jhelvy/quarto-lexis
  version: "1.0.0"
---

# Cleaning a lexis deck

This is an **audit-then-fix** workflow for a `.qmd` deck in the lexis paradigm.
The paradigm itself (slide model, shortcodes, classes) is defined in the
companion `lexis` skill — load that first if it isn't already in context; every
check below assumes its rules.

## Procedure

1. **Find the target.** Use the file the user named; otherwise look for `.qmd`
   files with `format: lexis-revealjs` in the front matter. If several match,
   ask which one.
2. **Read the whole deck** and run every check below, recording each finding
   with its line number.
3. **Report before touching anything.** Group findings by severity (order
   below) and show the proposed fix for each. If the deck is clean, say so and
   stop.
4. **Apply fixes.** If the user already said to fix things, apply everything
   mechanical and flag the judgment calls; otherwise ask which groups to apply.
5. **Verify.** After editing, run `quarto render <file>` and report the result.
   If render fails, fix what broke before finishing.

## Checks

### Errors (break the render or the slide)

- **Unbalanced `:::` fences** within a slide region — count opens/closes
  between each pair of `---` breaks.
- **Literal ```` ```{r} ```` inside a display fence** without the `` `r ''` ``
  knitr escape — renders as a real (often duplicate-label) chunk.
- **Duplicate chunk labels.**
- **Broken image paths** — every `![](path)` and `{{< bg-image "path" >}}`
  must exist on disk (skip URLs).
- **Malformed or unknown shortcodes** — only `inverse`, `center`, `middle`,
  `bg-color`, `bg-image`, `no-slide-number` exist; anything else (typo, wrong
  quoting, shortcode not on its own line) silently does nothing or prints
  literally.

### Silent no-ops (look fine, do nothing)

- **Classes missing the leading dot**: `{.col font60}` drops `font60`;
  `{font60}` does nothing at all. Every class needs its own dot.
- **`width` values without `%`** or unquoted (`width=65`) on `.col`.
- **A lone `.col` div** — column layout needs a run of two or more.
- **Column widths that sum past 100%** across one `.col` run.
- **xaringan-era `.codeNN` classes** (`.code70` etc.) — no longer exist;
  convert to `.fontNN`.

### Legacy xaringan syntax (from ported decks)

- `.class[text]` remark spans → `[text]{.class}`
- `class: center, middle, inverse` after a `---` → the shortcode stack
- `background-image: url(x)` / `background-color: #hex` → `{{< bg-image >}}` /
  `{{< bg-color >}}`
- `.leftcol[]` / `.rightcol[]` / `.leftcol60[]` / `.cols3` → consecutive
  `::: {.col}` divs (with `width=` for uneven splits)
- `#<<` trailing highlight comments → `#| code-line-numbers:`
- `.panelset` / `.panel[.panel-name[]]` → `::: {.panel-tabset}` + `###` tabs
- `???` presenter-note separators → `::: {.notes}`
- `##` used as a slide break (stock-Quarto habit): if new topics start at `##`
  headings with no `---` between them, the deck is in the wrong paradigm —
  flag it, and propose inserting `---` breaks (do **not** silently restructure).

### Cleanups (correct but worth simplifying)

- **Nested single-class divs → one fence**: `::: {.col}` wrapping
  `::: {.font60}` becomes `::: {.col .font60}`. Apply everywhere it's safe
  (i.e., the inner div wraps all of the outer div's content).
- **Redundant markup**: `width="50%"` on both columns of an even pair;
  `[text]{.center}` on every element of a slide that could be one
  `{{< center >}}`; empty divs; `{{< center >}}`/`{{< middle >}}` duplicated
  on the same slide.
- **Stacked `<br>` used for vertical centering** where `{{< middle >}}` does
  the job.
- **Trailing `---` at the end of the file** or two `---` with nothing between
  them — creates a blank slide.
- **Headings demoted to fit** (`#` turned into `##` to "make room") — heading
  level is only a text size; suggest a `---` break or `.fontNN` instead.

## Report format

Keep it compact — one line per finding:

```
Errors
  L42  unclosed ::: (opened L38)         → add closing :::
Silent no-ops
  L57  {.col font60} missing dot          → {.col .font60}
Cleanups
  L88  nested {.col} + {.font70}          → ::: {.col .font70}
```

Line numbers refer to the file as it is now; re-check them as you edit.
