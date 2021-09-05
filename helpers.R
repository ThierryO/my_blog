library(knitr)
library(here)
library(katex)
knit_hooks$set(optipng = hook_optipng)
opts_knit$set(base.dir = ".", base.url = "../../../post/")
opts_chunk$set(
  echo = TRUE, eval = TRUE, collapse = TRUE, cache = TRUE, comment = "#>",
  fig.align = "center", fig.asp = 0.7, fig.witdth = 500 / 72, fig.retina = 2,
  optipng = "-o1 -quiet",
  dev.args = list(png = list(type = "cairo-png")), dev = "svg"
)

save_widget <- function(ll, file, ratio = 0.5) {
  sourcefile <- gsub("_cache$", "", dirname(opts_current$get("cache.path")))
  newfile <- sprintf("%s-%s-%s", sourcefile, file, opts_current$get("label"))
  dir.create(here("static", "widgets"), showWarnings = FALSE, recursive = TRUE)
  htmlwidgets::setWidgetIdSeed(20170615)
  htmlwidgets::saveWidget(
    ll, here("static", "widgets", paste0(newfile, ".html")),
    selfcontained = FALSE, libdir = "libs"
  )
  cat(sprintf("{{< htmlwidget \"%s\" %f >}}", newfile, 100 * ratio))
}

math_display <- function(tex) {
  x <- vapply(tex, katex_mathml, character(1), displayMode = TRUE)
  x <- gsub("<annotation(.*?)\\/annotation>", "", x)
  cat(x)
}

math_inline <- function(tex) {
  x <- katex_mathml(tex = tex, displayMode = FALSE)
  x <- gsub("<annotation(.*?)\\/annotation>", "", x)
  cat(x)
}
