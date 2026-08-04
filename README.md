

<!-- README.md is generated from README.qmd. Please edit that file, then run build.R -->

# λέξις: a Quarto slide template

## by John Paul Helveston

Written: July 08 2026

Updated: August 04 2026

λέξις (lexis) is a **template** for making slides with
[Quarto](https://quarto.org)’s
[reveal.js](https://quarto.org/docs/presentations/revealjs/) format. It
is a port of the original [lexis xaringan
theme](https://github.com/jhelvy/lexis), and it preserves that theme’s
authoring conventions: **every `---` starts a new slide**, headings are
just *text sizes within* a slide, and slide modifiers like `inverse` /
`center` / `middle` are short declarative shortcodes.

It also adds a **slide grid** that reveal.js doesn’t have. Press `o`
and, instead of reveal’s single sideways row of slides, you get
xaringan’s tile view: a scrollable grid of thumbnails you can spin
through with the mouse wheel or the arrow keys, highlighting whatever is
selected. Click a slide or press `Enter` to jump to it.

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

### Cards

For a grid of icon-and-text boxes, write consecutive `::: {.card}` divs
— same deal as `.col`, no wrapper:

``` markdown
::: {.card .icon-left color="dodgerblue"}
{{< fa map >}}

### Plan

Make a plan before doing big work.

[read-only]{.tag}
:::

::: {.card .icon-left color="orange"}
{{< fa bolt >}}

### Auto

Approves everything.

[use with care]{.tag}
:::
```

Up to four cards go in one row; more wrap into a balanced grid. Set
`cols="2"` (or any number) on any card in the run to say it yourself,
and `gap=` for the gutter.

**An icon on the card’s first line becomes the icon tile** — and it can
come from any icon library, because lexis sees it only after the
shortcode has already expanded: `{{< fa map >}}` (Font Awesome),
`{{< bi map >}}` (Bootstrap Icons), `{{< iconify mdi:map >}}`, ``, an
emoji, or `![](images/icons/map.svg)`. Icon *fonts* take the card’s
accent color automatically. The starter template ships the
[fontawesome](https://github.com/quarto-ext/fontawesome) extension, so
`{{< fa >}}` works in a new deck with nothing to install.

| Attribute | Effect |
|----|----|
| `icon=` | Shorthand for an image file or an emoji, instead of a first line |
| `image=` | Cropped photo band across the top of the card |
| `color=` | Accent color: a palette name (`green`) or any CSS color |
| `badge=` | Small accent flag in the top-right corner |
| `cols=` | Cards per row |
| `gap=` | Gutter between cards |

| Class        | Effect                                            |
|--------------|---------------------------------------------------|
| `.icon-left` | Icon beside the heading instead of above it       |
| `.tint`      | Paint the accent color through an SVG icon *file* |
| `.highlight` | Accent fill and halo — “this one”                 |
| `.center`    | Center the card’s contents                        |
| `.fragment`  | Reveal this card on its own click                 |

One `color=` drives the whole box: heading, icon tile, border, chip,
badge. The `[text]{.tag}` chip works anywhere on a slide, and inside a
card it picks up that accent and sits on the card’s bottom edge, so a
row of cards lines its chips up however much prose each one has.

`.tint` is for icon *files*: it lets one set of plain line-art SVGs
serve a whole deck, each card painting its own accent through the file
instead of showing the file’s colors. Icon-font glyphs don’t need it —
they take the accent on their own. Everything is sized in `em`, so
wrapping a grid in `::: {.font80}` scales the boxes, tiles, and chips
together.

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

### Incremental content

`. . .` on its own line is xaringan’s `--`: everything after it on the
slide arrives on the next click. Use it as many times as you want steps.

``` markdown
# Findings

The headline number.

. . .

# But look closer

The caveat.
```

Headings step just like anything else, since in lexis they’re only text.
For finer control, `::: {.incremental}` around a list steps through its
items, and `::: {.fragment}` reveals one specific block.

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

### Presenting

Press `o` for the slide grid — lexis replaces reveal.js’s single
sideways row of slides with xaringan’s tile view, a scrollable grid of
thumbnails that opens on wherever you are in the deck.

| Key     | In the grid                                             |
|---------|---------------------------------------------------------|
| `o`     | Open the grid, or close it back onto the selected slide |
| `←` `→` | Previous / next slide                                   |
| `↑` `↓` | Up / down a whole row                                   |
| `Enter` | Go to the selected slide                                |
| `Esc`   | Close the grid                                          |

The mouse works too: scroll to fly through the deck, hover to highlight,
click a slide to jump to it.

Add `mouse-wheel: true` to the YAML and the wheel steps through the deck
outside the grid as well: one click, one increment or slide. (reveal.js
on its own throttles this to one step per second and discards whatever
arrives inside that second, so increments fall behind the moment you
scroll at any speed; lexis replaces that handler with one that keeps
up.)

Press `r` to read the deck back as one long scrolling page. lexis makes
that page **one screen per slide**, with every increment already showing
— reveal on its own gives you one scroll step per increment, starting
each slide blank. One click of the wheel moves one slide; a trackpad
swipe still scrolls freely.

Leaving the deck and coming back — clicking a link, then hitting the
browser’s back button — returns you to the slide *and* the increment you
left off on, rather than resetting the reveals: lexis keeps the fragment
index in the URL (`#/12/0/2`).

## What’s in the extension

    _extensions/lexis/
      _extension.yml         # contributes format: lexis-revealjs (slide-level: 0, theme, filter)
      lexis.scss             # the theme (fonts, palette, helper classes)
      lexis.lua              # slide-modifier filter (the core mechanism)
      lexis-shortcodes.lua   # the inverse / center / middle / … shortcodes
      title-slide.html       # empty — suppresses Quarto's built-in title slide
      lexis-overview.html    # the slide grid (`o`), with lexis.scss
      lexis-nav.html         # snappier mouse-wheel navigation
    template.qmd             # the starter deck: a full port of the lexis demo

## Exporting to PDF

Press `e` in a deck to flip reveal.js into PDF export mode, then print
from the browser (`Cmd`/`Ctrl` + `P`, “Save as PDF”, background graphics
on). You get one page per slide, laid out exactly like the slides on
screen.

To do the whole deck from R without touching the browser:

``` r
renderthis::to_pdf("my-slides.html", "my-slides.pdf")
```

Point it at the **rendered `.html`**, not the `.qmd` — it drives
headless Chrome through the same export mode.

Two things necessarily differ from presenting:

- Incremental content (`. . .`, `.fragment`) prints fully revealed, so
  nothing is missing from the page.
- A `::: {.panel-tabset}` prints only the tab that’s open. Put anything
  that has to survive the export on its own slide.

## Using with Claude Code

The repo ships two **Claude Code skills** in `.claude/skills/`:

- **`lexis`** teaches Claude the lexis authoring paradigm — the
  `---`-per-slide model, the shortcodes, the styling classes, and the
  knitr/fragment gotchas — so that “write me a lexis slide about X” or
  “make this a two-column slide” produces correct markup instead of
  stock Quarto `##`-per-slide decks.
- **`lexis-clean`** is an audit command: run `/lexis-clean` on a deck
  and Claude checks the `.qmd` for errors (unclosed divs, broken image
  paths), silent no-ops (missing class dots), leftover xaringan syntax,
  and markup worth simplifying — reports what it finds, then applies the
  fixes you approve.

You get them automatically in two situations:

- **Working in this repo** — Claude Code auto-discovers project skills
  in `.claude/skills/`, so they’re active whenever you develop the
  template here.
- **A deck created from the template** — both
  `quarto use template jhelvy/quarto-lexis` and the zip download include
  `.claude/skills/` alongside the extension, so every new deck comes
  with the skills and Claude picks them up when you open that folder.

To use them across **all** your decks regardless of how they were made,
copy the folders into your user-level skills once:

``` bash
cp -r .claude/skills/lexis .claude/skills/lexis-clean ~/.claude/skills/
```

Each skill is a single self-contained `SKILL.md` — nothing to build or
install. They’re only relevant if you use Claude Code; if you don’t, the
`.claude/` directory is inert and can be deleted.

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
