--[[
inverse-bg.lua — ergonomics for the Lexis reveal.js theme.

Lets a slide be marked dark with just `{.inverse}` instead of the repetitive
`{.inverse background-color="#121212"}`. Reveal.js slide backgrounds live in a
separate DOM layer that's painted from a header *attribute*, so they can't be
set from SCSS. This filter injects that attribute onto any slide-level header
carrying the `inverse` class.

Runs at `pre-quarto` so Quarto's own reveal background machinery consumes the
attribute exactly as if it had been typed by hand. An explicit
`background-color` written on the header still wins (we only fill it in when
absent), so per-slide overrides remain possible.
--]]

local INVERSE_BG = "#121212"

function Header(h)
  if h.classes:includes("inverse") and not h.attributes["background-color"] then
    h.attributes["background-color"] = INVERSE_BG
  end
  return h
end
