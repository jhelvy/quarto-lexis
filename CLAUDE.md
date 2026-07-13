# Project: `quarto-lexis`

A Quarto reveal.js **format extension + starter template** that ports John's
xaringan [`lexis`](https://github.com/jhelvy/lexis) theme and authoring
conventions to Quarto. Ships as `format: lexis-revealjs`. **Built and
working** — this file is a summary for orienting future work, not a design
brief.

## Core paradigm

- **`---` starts every slide** (not `##`). The extension sets
  `slide-level: 0`, so all headings (`#`/`##`/`###`) become in-slide styled
  text instead of slide breaks — matching xaringan/remark behavior.
- **Slide modifiers are shortcodes**, not heading attributes, because a
  `---`-delimited slide has no heading to hang attributes on:
  `{{< inverse >}}`, `{{< center >}}`, `{{< middle >}}`,
  `{{< bg-color "#hex" >}}`, `{{< bg-image "path" >}}`,
  `{{< no-slide-number >}}`. A Lua filter (`_extensions/lexis/lexis.lua`)
  splits the doc into slide regions on `HorizontalRule`, finds each
  shortcode's marker within a region, and hoists it onto that slide's
  `<section>` as a class/attribute (e.g. `data-background-color`), then
  removes the marker. This was the whole technical crux of the project.
- Inline styling uses Quarto spans (`[text]{.class}`) and fenced divs
  (`::: {.class}`) for colors, columns (`.col` with optional `width=`),
  image treatments (`.border`, `.polaroid`, `.circle`, etc.), and panels
  (`::: {.panel-tabset}`).

Full authoring conventions for end users (shortcode table, column syntax,
image treatments, title-slide pattern, code-line-highlighting convention)
live in `README.md` / `index.qmd` — read those, not this file, for details.

## Repo layout

```
_extensions/lexis/
  _extension.yml         # format: lexis-revealjs (slide-level: 0, theme, filter)
  lexis.scss             # theme (fonts, palette, helper classes)
  lexis.lua              # slide-modifier filter — the core mechanism
  lexis-shortcodes.lua   # inverse / center / middle / bg-color / bg-image / no-slide-number
  title-slide.html       # empty partial — suppresses Quarto's built-in title slide
template.qmd              # starter deck: full port of the lexis xaringan demo
lexis-template/           # packaged `quarto use template` output (demo + zip)
.claude/skills/lexis/     # Claude Code skill teaching this authoring paradigm
.claude/skills/lexis-clean/  # /lexis-clean — audits a deck for errors/legacy syntax/cleanups
README.qmd / README.md    # user-facing docs (README.md is generated — edit README.qmd, run build.R)
index.qmd / index.html    # published docs site
```

## Notes for future work here

- `README.md` is generated from `README.qmd` via `build.R` — edit the
  `.qmd`, not the `.md`, then rebuild.
- The project deliberately diverges from Quarto's standard `##`-per-slide
  convention to match the xaringan/remark paradigm — intentional, not a bug.
- The `lexis` Claude Code skill (`.claude/skills/lexis/SKILL.md`) is the
  authoritative reference for authoring decks in this paradigm; it's copied
  into every deck created from the template.
