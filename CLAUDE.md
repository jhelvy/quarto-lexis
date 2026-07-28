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
  _extension.yml         # format: lexis-revealjs (slide-level: 0, theme, filter,
                         #  fragment-in-url — see navigation notes below)
  lexis.scss             # theme (fonts, palette, helper classes)
  lexis.lua              # slide-modifier filter — the core mechanism
  lexis-shortcodes.lua   # inverse / center / middle / bg-color / bg-image / no-slide-number
  title-slide.html       # empty partial — suppresses Quarto's built-in title slide
  lexis-overview.html    # include-in-header script: xaringan tile grid for `o`
                         # (the layout is CSS in lexis.scss; this is the few
                         #  measurements CSS can't make — see both headers)
  lexis-nav.html         # include-in-header script: replaces reveal's wheel
                         # handler (hard-coded 1 step/second) with one click =
                         # one step, for `mouse-wheel: true` decks. Clicks are
                         # told from trackpad streams by CADENCE, not delta
                         # size — macOS acceleration makes one click report
                         # anywhere from 4px to 50px. `?wheelDebug=1` on the
                         # deck URL shows the live readout used to tune it.
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
- Every deck carries its **own copy** of `_extensions/lexis/`, so changes here
  don't reach an existing deck (or a running `quarto preview`) until that copy
  is replaced. Test extension changes against `lexis-template/lexis-demo.html`
  in this repo; syncing someone's deck is their call, not this repo's business.
- `build.R` opens with `unlink("lexis-template")`, so everything under it is
  regenerated — nothing in there is a source file. `*.knit.md` is gitignored
  for that reason (knitr intermediates got committed by accident once).

## Presenting / navigation

Both of these are reveal.js defaults that fight how John actually presents, so
they're overridden in the format rather than per deck:

- **`fragment-in-url: true`** (`_extension.yml`). Quarto defaults it off, so the
  hash only recorded the slide — click a link, come back, and every increment on
  that slide was collapsed again. With it on the hash is `#/12/0/2` and
  `location.readURL()` restores the fragment too.
- **`lexis-nav.html` replaces reveal's mouse-wheel handler**, which throttles to
  one step per second (hard-coded `1000` in `js/controllers/pointer.js`) and
  *discards* rather than queues everything inside that second — incremental
  bullets simply won't keep up with a hand. Ours steps once per wheel click.
  The hard part is telling a click from a trackpad (dozens of events per swipe
  plus a momentum tail), and **delta size cannot do it**: macOS scroll
  acceleration makes one click of the same wheel report 4px turned slowly and
  50px spun fast. Cadence can — a click is an isolated event (≥45ms of quiet
  around it), a trackpad is a stream at ~60Hz. Don't "fix" this back into a
  magnitude threshold. `?wheelDebug=1` on any deck URL prints the live
  classification, which is how the constants were measured in the first place.
  The logic is testable headlessly: eval the script with a stubbed `Reveal` +
  `document` in node and feed it synthetic `{deltaY, deltaMode}` at real
  timings — that's how the device matrix (notched mouse, hi-res wheel, Firefox
  line mode, trackpad swipe, momentum dregs, overview open) was checked.
- **Scroll view (`r`) is covered by the same handler.** Its hang-up has a
  different cause — not reveal's throttle but `scrollSnap: 'mandatory'`, whose
  snap animation swallows wheel input that arrives while it runs. A click there
  gets `preventDefault()` plus a normal `Reveal.next()`, which routes to
  `scrollView.next()` and advances exactly one scroll trigger (one fragment, or
  one slide); since triggers *are* the snap points, no animation to fight.
  Streams are deliberately left to native scrolling — gliding through the deck
  is the point of that mode. This is why the listener is registered
  `{ passive: false }`: Chromium makes document-level wheel listeners passive
  by default, which would silently no-op the `preventDefault()`.
- **Scroll view is also flattened to one page per slide.** reveal builds it with
  one scroll trigger *per fragment*, so an incremental deck becomes a page you
  crawl through a bullet at a time with every slide starting out blank. Since
  `r` is for reading the deck back — the `o` grid's job, where a slide is one
  tile with all its content — `flattenScrollView()` strips the fragments out of
  the DOM reveal just built, then calls `Reveal.layout()` to rebuild: no
  triggers, one viewport-height page per slide. Two things make this work:
  scrollview.js stashes the slides' `innerHTML` on activation and restores it on
  exit (so presenting is unaffected, and no un-flattening is needed), and it
  dispatches no events (so activation is detected from the viewport's
  `reveal-scroll` class, which also catches `view: scroll` and the responsive
  auto-activation). **Watch out for Quarto's line-highlight plugin**: stepped
  `code-line-numbers` are implemented by *cloning the whole code block* per step
  at runtime, each clone `.fragment`, so un-fragmenting them would stack N
  copies — the clones are removed instead, keeping the original (step 1's
  highlight). None of that is visible in the rendered `.html`; it's runtime-only.
  Tested with jsdom (see the flatten tests in the session scratchpad pattern:
  fake scroll-view DOM + stubbed Reveal, assert classes/clones/layout calls).
