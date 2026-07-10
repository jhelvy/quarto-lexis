# Project: `quarto-lexis` — a bespoke Quarto reveal.js extension for John's slide paradigm

## The goal (why this exists)

Build a **custom Quarto reveal.js extension + theme** that lets John author slides
using the **exact conventions he already uses** in his xaringan **`lexis`** theme
(https://github.com/jhelvy/lexis). He uses this paradigm for *all* his courses, so
getting one clean extension right makes porting every future deck nearly mechanical.

The non-negotiable authoring conventions to preserve:

1. **`---` denotes every slide break** (NOT `##`). John thinks in `---`-delimited
   slides; headings are just *text sizes* within a slide, exactly like xaringan/remark.
2. **Slide-level modifiers via shortcodes** — e.g. center everything, vertically
   middle everything, or invert the slide colors (dark bg / light text). In xaringan
   these were `class: center, middle, inverse` written after the `---`. John wants the
   Quarto equivalent to be **short, declarative shortcodes** (his words: "use short
   codes to do things like place everything on the page in the center, the middle, or
   invert the slide colors").
3. Keep the **inline styling / layout classes** from lexis (colors, columns, image
   treatments, panels) working with minimal syntax changes.

The end state: John writes a `.qmd` that looks and feels like his xaringan `.Rmd`,
sets `format: lexis-revealjs`, and it Just Works.

## Why this is its own project (not part of the EDA course repo)

This was spun out of a long session porting the Fall-2026 EDA "Getting Started" deck
(`~/gh/teaching/EDA/2026-Fall/class/1-getting-started/index.qmd`) from xaringan to
Quarto reveal.js. That port works, but it forced the *standard* Quarto convention
(`##` = one slide) which meant demoting a lot of headers and doesn't match John's
mental model. Rather than keep fighting it deck-by-deck, build the reusable extension
once. The EDA deck is a real-world test case but is **not** the deliverable here.

---

## The core technical problem (this is the crux — solve it FIRST)

Quarto reveal.js, by default (`slide-level: 2`), treats **every `##` as a new slide**.
Headers *at or above* the slide level create slides; only headers *below* it are
in-slide content. To get John's paradigm (`---` = slides, all headers = in-slide text)
you set **`slide-level: 0`** — then *only* `---` starts a slide and `#`/`##`/`###` are
all just styled text. **This half works.**

**The blocker:** slide-level modifiers (inverse/center/middle, background color/image)
are normally set as **attributes on the slide's heading** (`## Title {.inverse
background-color="#121212"}`). At `slide-level: 0` the heading is no longer the slide
boundary — the `---` is — and a `---`-delimited slide has **no heading to hang
attributes on**. Verified empirically this session: under `slide-level: 0`, an
`## Outline {.inverse}` slide renders **light** because the `.inverse` class/attribute
never reaches the `<section>`. (Under `slide-level: 2` the same slide renders dark,
because the heading *is* the section.)

**So the whole project hinges on:** a mechanism to apply center/middle/inverse/
background to a `---`-delimited (headingless) slide. John's proposed approach — which
is the right one — is a **Lua filter + shortcodes**:

- A shortcode like `{{< inverse >}}` / `{{< center >}}` / `{{< middle >}}` placed in a
  slide emits a marker.
- A companion **Lua filter** finds those markers within each slide region and applies
  the modifier to the enclosing reveal `<section>` (add classes like `inverse`/`center`,
  set `data-background-color`, etc.), then removes the marker.

### First task: prototype the filter mechanism

Before building anything else, **prove you can set a `---`-slide's background + class
from a Lua filter.** This is make-or-break. Things to investigate/try:

- A Lua filter that walks the Pandoc AST, splits top-level blocks on `HorizontalRule`
  (`---`) into slide regions, detects a marker (from the shortcode) in a region, and
  attaches attributes to that slide. The open question is *where* the attributes need
  to land so Quarto's reveal writer emits them on `<section>` — investigate whether
  Quarto exposes a slide/section Div at some filter phase (try `at: pre-quarto` vs
  `at: post-quarto`), or whether a `RawBlock` of reveal markup is needed.
- Fallback ideas if direct attribution is hard: inject `data-background-color` via a
  raw HTML hook; or reconsider whether a shortcode can set section attributes through
  Quarto's own slide-attribute machinery.
- Confirm it works for: inverse (dark bg + light text), `background-color="…"`,
  `background-image="…"`, `center`, `middle`, and combinations.

If this prototype works, everything else is styling and packaging. If it can't be made
clean, fall back to documenting the standard `##`-per-slide convention (what the EDA
deck already uses) — but exhaust the filter approach first, since it's the whole point.

---

## The lexis conventions to replicate (from the demo deck)

Reference: `starting-assets/lexis-demo-16-9-ORIGINAL.Rmd` (the canonical demo to port),
`starting-assets/lexis-original-xaringan.css` (original styles), and the live demo at
https://jhelvy.github.io/lexis/lexis-theme/lexis-demo-16-9.html

**Slide modifiers** (xaringan `class:` after `---`) → Quarto shortcodes to design:
- `center` — center all content horizontally
- `middle` — vertically center content
- `inverse` — dark background (#121212), white text, orange inline code
- `background-image: url(...)` and `background-color: #hex`
- `title-slide` and `no-slide-number` variants

**Inline text styling** (xaringan `.class[text]`) → Quarto spans `[text]{.class}`:
- `.fancy` (Lobster Two display font)
- colors: `.red .orange .yellow .green .darkgreen .blue .darkblue .purple .black .white`
- standard markdown: `_italic_`, `**bold**`, `~~strike~~`, `` `code` ``

**Columns** (xaringan `.leftcol[]`/`.rightcol[]`) → Quarto divs `::: {.leftcol}`:
- 50/50: `.leftcol` / `.rightcol` (aka `.pull-left`/`.pull-right`)
- splits: `.leftcol55/60/65/70/75/80` + matching `.rightcolNN`, and the reverse
- three equal: `.cols3`

**Image treatments** (xaringan `.class[<img>]`) → Quarto divs or a `{.class}` on the image:
- `.border` (thin black), `.borderthick`, `.whiteborder`, `.whiteborderthick`,
  `.polaroid`, `.circle`, `.thumbnail`, `.noborder` (default = no border)
- must also work wrapping a **rendered ggplot** (`.border` around a code cell's figure)

**Panels/tabs** (xaringan `.panelset[.panel[.panel-name[...]]]`) → Quarto `.panel-tabset`.

**Footers:** `.footer-small` (link bar) / `.footer-large`; xaringan used `layout: true`
to repeat a footer on all slides — find the Quarto equivalent (partial or filter).

**Code line highlighting:** xaringan `#<<` trailing comment → Quarto
`#| code-line-numbers: "3,4"`.

**Fonts/colors (already ported):** Inter (body), Fira Sans Condensed (headers),
Lobster Two (`.fancy`), SFMono (code). Palette in `lexis.scss` `scss:defaults`.

---

## Hard-won findings from the porting session (don't rediscover these)

- **Header levels & slides:** `##` = new slide at `slide-level: 2`. Headers at/above
  slide-level make slides (h1 becomes a section divider slide). `slide-level: 0` ⇒
  only `---` makes slides, all headers become in-slide text. This is THE xaringan-vs-
  Quarto difference and the basis of this project.
- **Inverse background** is a reveal DOM layer painted from a slide **attribute**
  (`data-background-color`) — CSS/SCSS alone can't set it per-slide; it needs to be an
  attribute on the `<section>`. Hence the filter. (Current `inverse-bg.lua` injects it
  onto `.inverse` *headings*, which only works at `slide-level: 2` — it must be
  generalized for the `---`/slide-level-0 world.)
- **Display-only code chunks:** knitr runs *before* Pandoc and greedily parses any
  ` ```{r} ` — even inside a four-backtick ` ````markdown ` block — as a real chunk
  (caused a "duplicate chunk label" render error). To *show* code without running it:
  use plain ` ```r ` / ` ```markdown ` fences; to show a **literal** ` ```{r} ` chunk,
  prefix the inner fence with an empty inline expr: `` `r ''` `` before the backticks
  (the classic knitr escape — renders clean, verified). `#| echo: fenced` +
  `#| eval: false` also shows a chunk unevaluated but prints the `#|` option lines.
- **Fragments / incremental (xaringan `--`):** `. . .` (pause) fragments paragraphs and
  lists but **NOT headings**. `::: {.incremental}` only works wrapping a **bare list**
  (a heading+paragraph+list inside it produces zero fragments). `::: {.fragment}` works
  on **anything** (wrap each heading in its own `.fragment` to step through headings).
  The extension should define a clean, minimal incremental convention to replace `--`.
- **Sizing:** for a 1600×900 canvas, root font **34px** matches xaringan's proportions
  (28px was ~25% too small); `code-block-font-size: 0.85em`. In `lexis.scss` these are
  `$presentation-font-size-root` and `$code-block-font-size`.
- **Title slide:** built as a `template-partials: [title-slide.html]` — a dark section
  with the logo left, fancy title + subtitle/author/date with FontAwesome icons right.
  Icons are inline SVGs (generate via R: `fontawesome::fa(name, fill="white")`). Current
  version hardcodes the text per-deck; a real extension should thread YAML metadata
  (`$title$` etc.) or provide a documented pattern.
- **Quarto's `##`-per-slide is the standard**; we are deliberately diverging from it to
  match John. Keep that trade-off explicit in the docs.

---

## Starting assets (in `starting-assets/`, copied from the EDA deck)

- `lexis.scss` — the SCSS theme already ported from `lexis.css`+`lexis-fonts.css`
  (scss:defaults = fonts/colors/reveal vars; scss:rules = retargeted rules + helper
  classes: `.fancy`, colors, `.font10..200`, `.code10..100`, image treatments,
  `.inverse`, `.center`/`.left`, `.blackborder`, `.footnote`, `.slimtitle`). Solid base.
- `title-slide.html` — the dark title-slide partial (logo + icons + fancy title).
- `inverse-bg.lua` — current filter: adds `background-color="#121212"` to headers with
  class `inverse` (works at slide-level 2 only; **generalize this** for slide-level 0).
- `demo.qmd` — Convention A demo (slide-level 2, `##` = slides). Renders correctly.
- `demoB.qmd` — Convention B demo (slide-level 0, `---` = slides). Renders, structure
  matches A, **but inverse slide is light** — this is the exact problem to solve.
- `lexis-demo-16-9-ORIGINAL.Rmd` — the xaringan demo to fully replicate in Quarto.
- `lexis-original-xaringan.css` — original lexis styles for reference.

---

## Suggested deliverable & structure

A **Quarto format extension** so decks use `format: lexis-revealjs`:

```
_extensions/lexis/
  _extension.yml        # contributes a revealjs-based format:
                        #   theme: lexis.scss, slide-level: 0,
                        #   filters: [lexis.lua], template-partials, defaults
  lexis.scss            # the theme (from starting-assets, refined)
  lexis.lua             # the slide-modifier filter (inverse/center/middle/bg)
  title-slide.html      # title partial
  shortcodes...         # if shortcodes are separate .lua files
demo.qmd                # full port of lexis-demo-16-9 proving every feature
```

**Definition of done:** the ported `demo.qmd` reproduces every slide of
`lexis-demo-16-9-ORIGINAL.Rmd` (text styling, inverse, colors, tables, blockquotes,
code highlighting, panels, all column splits, background image/color, all image
treatments) authored in John's `---` + shortcode paradigm, and a second real deck (the
EDA Getting Started deck) ports cleanly onto it.

**Reference docs:** Quarto extensions (https://quarto.org/docs/extensions/),
format extensions (https://quarto.org/docs/extensions/formats.html), shortcodes
(https://quarto.org/docs/extensions/shortcodes.html), Lua filters/`at:` phases,
reveal.js format reference. Use the `quarto-authoring` skill.

## Immediate next steps for the fresh session

1. **Prototype the Lua-filter mechanism** for setting a `---`-slide's background+class
   at `slide-level: 0` (use `demoB.qmd` as the test bed — make its Outline slide go
   dark via a `{{< inverse >}}` shortcode + filter). Nothing else matters until this works.
2. Once proven, design the shortcode set (`inverse`/`center`/`middle`/`background-*`).
3. Scaffold the `_extensions/lexis/` format extension; move `lexis.scss` in.
4. Port `lexis-demo-16-9` slide-by-slide as the acceptance test.
5. Port the EDA Getting Started deck onto the extension as the real-world test.

Everything above the "next steps" is context; start at step 1.
