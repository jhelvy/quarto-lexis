---
name: lexis
description: >
  Author and edit Quarto reveal.js slide decks that use the lexis theme
  (`format: lexis-revealjs`, the jhelvy/quarto-lexis extension). Use this whenever
  writing or editing a `.qmd` slide deck in the lexis paradigm — where `---` (not
  `##`) starts every slide, headings are just styled text, and slide modifiers
  (inverse / center / middle / backgrounds) are `{{< … >}}` shortcodes. Covers the
  slide model, shortcodes, inline styling classes, columns, image treatments,
  panels, the hand-authored title slide, footers, code line highlighting, and the
  knitr/fragment gotchas specific to this format. Also porting xaringan/remark
  `.Rmd` decks (the original lexis theme) to lexis-revealjs.
metadata:
  author: John Paul Helveston
  repo: https://github.com/jhelvy/quarto-lexis
  version: "1.0.0"
---

# Authoring lexis slides

lexis is a Quarto reveal.js **format extension** (`format: lexis-revealjs`, from
`jhelvy/quarto-lexis`). It ports the xaringan/remark `lexis` theme, so it keeps
that theme's authoring model rather than stock Quarto's. **The paradigm is the
whole point — get it right and everything else follows.**

## The one rule that changes everything

**`---` starts every slide. `#`/`##`/`###` are just text sizes _within_ a slide,
never slide breaks.** The format sets `slide-level: 0` to get this.

This is the opposite of stock Quarto reveal.js, where every `##` begins a new
slide. When writing or editing a lexis deck, **never** reach for `##` to make a
new slide — use `---`. Use headings only to size text on the current slide.

```markdown
# Big text

## Smaller text

Regular body text.

---

# The next slide
```

A heading placed **inside** a fenced div (e.g. a column) is rendered as styled
text (`.h1`…`.h6`) so it can't accidentally break the slide.

## Slide modifiers (shortcodes)

A `---`-delimited slide has no heading to hang attributes on, so slide-level
modifiers are **shortcodes**. Put each on its own line, anywhere on the slide
(top is cleanest). They stack.

| Shortcode | Effect |
|---|---|
| `{{< inverse >}}` | Dark slide: `#121212` bg, white text, orange inline code |
| `{{< center >}}` | Center all content horizontally |
| `{{< middle >}}` | Center all content vertically |
| `{{< bg-color "#909099" >}}` | Full-slide background color |
| `{{< bg-image "images/x.jpg" >}}` | Full-slide background image (optional `size=` / `position=`) |
| `{{< no-slide-number >}}` | Hide the slide number on this slide |

A section-divider slide is just the stack:

```markdown
{{< inverse >}}
{{< center >}}
{{< middle >}}

# Section title
```

Mechanism (for debugging, not for authoring): each shortcode emits an invisible
marker span; the `lexis.lua` filter (running `post-quarto`) hoists it onto the
slide's `<section>`. If a modifier "doesn't take," check the shortcode is spelled
exactly as above and sits inside the intended `---`…`---` region.

## Inline text styling

xaringan's `.class[text]` becomes a Quarto span: `[text]{.class}`.

- `[text]{.fancy}` — Lobster Two display font
- **Colors:** `.red` `.orange` `.yellow` `.green` `.darkgreen` `.blue`
  `.darkblue` `.purple` `.black` `.white` `.gray`
- **Sizes:** `.small` `.large`, or `.font10` … `.font200` for an exact percentage
- Standard markdown works: `_italic_`, `**bold**`, `~~strike~~`, `` `code` ``

To align just a heading (not the whole slide), put the class on a span inside it:
`# [Title]{.center}` — also `.left`, `.right`. (Whole-slide centering is the
`{{< center >}}` shortcode instead.)

## Columns

Write **consecutive `::: {.col}` divs with no outer wrapper**. Any run of two or
more `.col` divs in a row is grouped automatically and splits the space evenly —
there is no separate class for 2 vs 3 vs 4 columns.

```markdown
::: {.col}
Left half.
:::

::: {.col}
Right half.
:::
```

For an uneven split, set `width` on a column. Columns without one share what's
left, so usually you set it on only one side:

```markdown
::: {.col width="65%"}
:::

::: {.col width="35%"}
:::
```

`width` takes any percentage (no fixed set of splits). You can also set
`gap="3em"` or `valign="middle"` on any `.col` in a row and it applies to the
whole row.

## Images

Wrap the image (or a code cell that renders a plot) in a treatment div:

```markdown
::: {.border}
![](images/photo.jpg)
:::
```

Treatments: `.border` `.borderthick` `.whiteborder` `.whiteborderthick`
`.polaroid` `.circle` `.thumbnail` `.noborder`. **The default is no border** —
only wrap when you want a treatment. Each works identically around a rendered
ggplot: wrap the ```` ```{r} ```` cell instead of the `![]()`.

## Panels / tabs

xaringan's `.panelset` → Quarto's native `::: {.panel-tabset}`, with a `###`
heading naming each tab.

```markdown
::: {.panel-tabset}

### R Code
```{r}
#| echo: true
#| fig-show: hide
plot(1:10)
```

### Plot
```{r}
#| echo: false
plot(1:10)
```

:::
```

## Title slide

**There is no auto-generated title slide** (the extension ships an empty
`title-slide.html` partial that suppresses Quarto's). Author the title slide as
the deck's **first `---` slide**, pulling values from the YAML front matter with
Quarto's built-in `{{< meta >}}` shortcode so nothing is duplicated:

```markdown
{{< inverse >}}
{{< center >}}
{{< middle >}}
{{< no-slide-number >}}

# {{< meta title >}}

## [{{< meta subtitle >}}]{.fancy}

<br>

[{{< meta author >}}]{.large}

{{< meta date >}}
```

Drop any line you don't need; restyle the rest — it's just markdown.

## Footers

Set `footer: "..."` in the YAML header for the repeated black link bar. Use
`::: {.footer-large}` for the block footer on title/closing slides.

## Code line highlighting

xaringan's trailing `#<<` comment → the `code-line-numbers` cell option:

```` markdown
```{r}
#| code-line-numbers: "4,5"
```
````

## Minimal deck skeleton

```markdown
---
title: "My deck"
subtitle: "a subtitle"
author: "Your Name"
date: "2026-07-10"
format: lexis-revealjs
footer: "<https://example.com>"
footer-align: center
execute:
  echo: false
  warning: false
  message: false
---

{{< inverse >}}
{{< center >}}
{{< middle >}}
{{< no-slide-number >}}

# {{< meta title >}}

## [{{< meta subtitle >}}]{.fancy}

<br>

[{{< meta author >}}]{.large}

{{< meta date >}}

---

# First content slide

Body text.
```

The extension must be present at `_extensions/lexis/` (via
`quarto use template jhelvy/quarto-lexis` or `quarto add jhelvy/quarto-lexis`).
The canonical, feature-complete example is the extension's own `template.qmd`.

## Gotchas (these bite; don't rediscover them)

- **Showing a literal ```` ```{r} ```` chunk in a code block:** knitr runs
  *before* Pandoc and greedily parses any ```` ```{r} ```` — even nested inside a
  four-backtick ```` ````markdown ```` block — as a real chunk (→ "duplicate chunk
  label" render error). To *display* code without running it, use a plain
  ```` ```r ```` / ```` ```markdown ```` fence. To show a **literal** ```` ```{r} ````
  chunk, prefix the inner fence with an empty inline expr — `` `r ''` `` — right
  before the backticks (the classic knitr escape).
- **Fragments / incremental (xaringan's `--`):** `. . .` fragments paragraphs and
  list items but **not headings**. `::: {.incremental}` only fragments a **bare
  list**. `::: {.fragment}` fragments **anything** — wrap each heading in its own
  `.fragment` to step through headings.
- **Backgrounds are attributes, not CSS:** a per-slide background is a reveal DOM
  layer set from a `<section>` attribute — that's why it's a shortcode
  (`{{< bg-color >}}` / `{{< bg-image >}}` / `{{< inverse >}}`), not something you
  style in SCSS.
- **Sizing:** the canvas is 1600×900 with a 34px root font (tuned to match
  xaringan proportions). Prefer relative figure sizes (`out-width`, `fig-width`)
  over pixel-perfect tweaks.
- **Don't demote headings to make slides fit.** If you find yourself turning `#`
  into `##` to "make a new slide," stop — insert a `---` instead. Heading level is
  purely visual size here.

## Porting an xaringan/remark `.Rmd` to lexis

Mechanical mapping when converting an original-lexis `.Rmd` deck:

| xaringan | lexis (Quarto) |
|---|---|
| `---` slide break | `---` (same — keep them) |
| `class: center, middle, inverse` after `---` | `{{< center >}}` `{{< middle >}}` `{{< inverse >}}` lines |
| `background-image: url(x.jpg)` | `{{< bg-image "x.jpg" >}}` |
| `background-color: #hex` | `{{< bg-color "#hex" >}}` |
| `.red[text]`, `.fancy[text]`, etc. | `[text]{.red}`, `[text]{.fancy}` |
| `.leftcol[]` / `.rightcol[]` / `.cols3` / `.leftcol60[]` … | consecutive `::: {.col}` (add `width=` for splits) |
| `.border[<img>]`, `.circle[<img>]`, … | `::: {.border}` / `::: {.circle}` wrapping the image |
| `.panelset[.panel[.panel-name[…]]]` | `::: {.panel-tabset}` + `###` tab headings |
| `#<<` line-highlight comment | `#| code-line-numbers: "3,4"` |
| `layout: true` footer repeat | `footer:` in YAML |
| the auto title slide | hand-authored first `---` slide with `{{< meta … >}}` |
