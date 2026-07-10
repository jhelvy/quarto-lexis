

<!-- README.md is generated from README.qmd. Please edit that file, then run build.R -->

# λέξις: a Quarto slide template

## by John Paul Helveston

Written: July 08 2026

Updated: July 10 2026

λέξις (lexis) is a **template** for making slides with
[Quarto](https://quarto.org)’s
[reveal.js](https://quarto.org/docs/presentations/revealjs/) format. It
is a port of the original [lexis xaringan
theme](https://github.com/jhelvy/lexis), and it preserves that theme’s
authoring conventions: **every `---` starts a new slide**, headings are
just *text sizes within* a slide, and slide modifiers like `inverse` /
`center` / `middle` are short declarative shortcodes.

It has a light gray background and uses [Fira Sans
Condensed](https://fonts.google.com/specimen/Fira+Sans+Condensed) for
headers, [Inter](https://fonts.google.com/specimen/Inter) for body text,
[Lobster Two](https://fonts.google.com/specimen/Lobster+Two) for fancy
text, and [SFMono-Regular](https://developer.apple.com/fonts/) for mono
text (i.e. code). The theme copies ideas from several other themes, most
notably from [Allison Hill](https://alison.rbind.io/)’s xaringan
[workshop](https://github.com/rstudio-education/arm-workshop-rsc2019).

### Demo

- [Preview](https://jhelvy.github.io/quarto-lexis/lexis-template/lexis-demo.html)
  a live demo.
- [Download](https://jhelvy.github.io/quarto-lexis/lexis-template/lexis-template.zip)
  the files to create the demo.
- Read the [full documentation](https://jhelvy.github.io/quarto-lexis).

### Installation

lexis is more than a theme — it is a **Quarto format template**. It
ships a reveal.js *format extension* (the theme, a Lua filter, and a set
of shortcodes) together with a starter deck that exercises every
feature. There are three ways to get it, depending on how much you want.

#### 1. Start a new deck from the template (recommended)

``` bash
quarto use template jhelvy/quarto-lexis
```

Quarto will ask for a directory name and then create it with everything
you need: the starter deck (renamed to match your directory), the
`_extensions/lexis` extension, and the demo images. Render it and you
have the demo deck; edit it and you have your own.

#### 2. Add the extension to an existing project

If you already have a deck and just want the format:

``` bash
quarto add jhelvy/quarto-lexis
```

Then set the format in your deck’s YAML header:

``` yaml
---
title: "My deck"
format: lexis-revealjs
---
```

#### 3. Download the zip

Prefer to grab the files by hand? The zip contains the demo deck, the
extension, and the images.

The zip lives at
<https://jhelvy.github.io/quarto-lexis/lexis-template/lexis-template.zip>.

## Authoring conventions

### Slides

Every `---` starts a new slide. Headings are **styled text**, not slide
breaks:

``` markdown
# Big text

## Smaller text

Regular body text.

---

# The next slide
```

This is the one place lexis deliberately diverges from stock Quarto
reveal.js, which makes every `##` a new slide. The extension sets
`slide-level: 0` to get the xaringan/remark behavior back.

### Slide modifiers

Put these shortcodes anywhere on a slide (their own line is cleanest).
They replace xaringan’s `class:` / `background-*` lines:

| Shortcode | Effect |
|----|----|
| `{{< inverse >}}` | Dark slide: `#121212` background, white text, orange inline code |
| `{{< center >}}` | Center all content horizontally |
| `{{< middle >}}` | Center all content vertically |
| `{{< bg-color "#909099" >}}` | Full-slide background color |
| `{{< bg-image "images/x.jpg" >}}` | Full-slide background image (optional `size=` / `position=`) |
| `{{< no-slide-number >}}` | Hide the slide number on this slide |

They stack, so a section-divider slide is just:

``` markdown
{{< inverse >}}
{{< center >}}
{{< middle >}}

# Section title
```

### Inline text styling

xaringan’s `.class[text]` becomes a Quarto span, `[text]{.class}`:

- `[text]{.fancy}` — Lobster Two display font
- colors: `.red` `.orange` `.yellow` `.green` `.darkgreen` `.blue`
  `.darkblue` `.purple` `.black` `.white` `.gray`
- sizes: `.small` `.large`, or `.font10` through `.font200` for exact
  percentages
- standard markdown `_italic_`, `**bold**`, `~~strike~~`, `` `code` ``

To center just a heading rather than the whole slide, put the class on a
span inside it: `# [Title]{.center}` (also `.left`, `.right`).

### Columns

Write consecutive `::: {.col}` divs — no outer wrapper. Any run of two
or more in a row is grouped automatically and splits the space evenly:

``` markdown
::: {.col}
Left half.
:::

::: {.col}
Right half.
:::
```

For an uneven split, give a column a `width`. Columns without one share
what’s left, so usually you only need to set it on one side:

``` markdown
::: {.col width="65%"}
:::

::: {.col width="35%"}
:::
```

`width` takes any percentage, so there is no fixed set of splits to
remember (this replaces xaringan’s `.leftcol55`, `.rightcol70`,
`.cols3`, and friends). You can also set `gap="3em"` or
`valign="middle"` on any `.col` in a row and it applies to the whole
row.

### Images

Wrap an image in a treatment div:

``` markdown
::: {.border}
![](images/photo.jpg)
:::
```

Available treatments are `.border` `.borderthick` `.whiteborder`
`.whiteborderthick` `.polaroid` `.circle` `.thumbnail` `.noborder` (the
default is no border). Each one works the same way around a rendered
plot — wrap the code cell instead of the `![]()`.

### Panels / tabs

xaringan’s `.panelset` becomes Quarto’s native `::: {.panel-tabset}`,
with a `###` heading naming each tab.

### Title slide

There is no auto-generated title slide. You author it like any other
slide, using Quarto’s built-in `meta` shortcode to pull values from your
YAML front matter instead of retyping them:

``` markdown
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

Drop any line you don’t need and restyle the rest — it’s just markdown.

### Footers

Set `footer: "..."` in the YAML header for the repeated link bar, which
is styled as the lexis black bar. Use `::: {.footer-large}` for the
block footer on title and closing slides.

### Code line highlighting

xaringan’s trailing `#<<` comment becomes the `code-line-numbers` cell
option:

```` markdown
```{r}
#| code-line-numbers: "4,5"
```
````

## What’s in the extension

    _extensions/lexis/
      _extension.yml         # contributes format: lexis-revealjs (slide-level: 0, theme, filter)
      lexis.scss             # the theme (fonts, palette, helper classes)
      lexis.lua              # slide-modifier filter (the core mechanism)
      lexis-shortcodes.lua   # the inverse / center / middle / … shortcodes
      title-slide.html       # empty — suppresses Quarto's built-in title slide
    template.qmd             # the starter deck: a full port of the lexis demo

## Using with Claude Code

The repo ships a **Claude Code skill** at `.claude/skills/lexis/` that
teaches Claude the lexis authoring paradigm — the `---`-per-slide model,
the shortcodes, the styling classes, and the knitr/fragment gotchas — so
that “write me a lexis slide about X” produces correct markup instead of
stock Quarto `##`-per-slide decks.

You get it automatically in two situations:

- **Working in this repo** — Claude Code auto-discovers project skills
  in `.claude/skills/`, so it’s active whenever you develop the template
  here.
- **A deck created from the template** —
  `quarto use template jhelvy/quarto-lexis` copies
  `.claude/skills/lexis/` alongside the extension, so every new deck
  comes with the skill and Claude picks it up when you open that folder.

To use it across **all** your decks regardless of how they were made,
copy the folder into your user-level skills once:

``` bash
cp -r .claude/skills/lexis ~/.claude/skills/
```

The skill is a single self-contained `SKILL.md` — nothing to build or
install — so copying the file is all it takes. It’s only relevant if you
use Claude Code; if you don’t, the `.claude/` directory is inert and can
be deleted.

## Notes

- This deliberately diverges from Quarto’s standard `##`-per-slide
  convention in order to match the xaringan paradigm.
- Because a `---` slide has no heading to hang attributes on, the
  modifier shortcodes leave invisible markers that a Lua filter
  ([`_extensions/lexis/lexis.lua`](_extensions/lexis/lexis.lua)) hoists
  onto the slide’s `<section>` element.
- Headings placed *inside* a fenced div, such as a column, are rendered
  as `.h1`…`.h6` styled text so they can’t accidentally start a new
  slide.

### What does “λέξις” mean?

When communicating an idea to others, there is a fundamental difference
between the *content* of what is be communicated and the *form* of how
it is communicated. Aristotle phrased this as the difference between
[λόγος (logos)](https://en.wikipedia.org/wiki/Logos), the logical
content of a speech, and [λέξις
(lexis)](https://en.wikipedia.org/wiki/Lexis_(Aristotle)), the style and
delivery of a speech (see also [this
article](http://rhetoric.byu.edu/Encompassing%20Terms/Content%20and%20Form.htm)
on content versus form). Since the entire purpose of making a slide
theme is to customize the *form* of how content is delivered, “lexis”
seemed like an appropriate name.

------------------------------------------------------------------------

### License

![](https://i.creativecommons.org/l/by-sa/4.0/88x31.png) This work is
licensed under a [Creative Commons Attribution-ShareAlike 4.0
International License](https://creativecommons.org/licenses/by-sa/4.0/).
