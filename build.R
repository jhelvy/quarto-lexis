# Builds everything that gets published to GitHub Pages.
#
# `template.qmd` + `_extensions/lexis` + `images/` at the repo root are the
# single source of truth: they are what `quarto use template jhelvy/quarto-lexis`
# copies. This script stages a copy of those three into `lexis-template/` as
# `lexis-demo.qmd`, renders it, zips the folder for people who'd rather download
# than install, and then renders the README and the landing page.

render_quarto <- function(input, ...) {
  status <- system2("quarto", c("render", shQuote(input), ...))
  if (status != 0) stop("quarto render failed for ", input, call. = FALSE)
}

out <- "lexis-template"
unlink(out, recursive = TRUE)
dir.create(out)

# Stage the template as the demo deck
file.copy("template.qmd", file.path(out, "lexis-demo.qmd"))
file.copy("_extensions", out, recursive = TRUE)
file.copy("images", out, recursive = TRUE)
unlink(list.files(out, ".DS_Store", recursive = TRUE, all.files = TRUE, full.names = TRUE))

# Render the demo deck in place
render_quarto(file.path(out, "lexis-demo.qmd"))

# Zip it up for the "download the files" route
zip::zip(
  zipfile = "lexis-template.zip",
  files = c(
    "_extensions",
    "images",
    "lexis-demo.qmd",
    "lexis-demo.html",
    "lexis-demo_files"
  ),
  root = out
)

# Landing page (GitHub Pages) and README
render_quarto("index.qmd")
render_quarto("README.qmd")
