library(here)
rmd_posts <- list.files(
  here("content", "post"), pattern = "\\.Rmd$", full.names = TRUE
)
md_posts <- list.files(
  here("content", "post"), pattern = "\\.md$", full.names = TRUE
)
rmd_base <- gsub("\\.Rmd$", "", basename(rmd_posts))
md_base <- gsub("\\.md$", "", basename(md_posts))
rmd_posts <- rmd_posts[!rmd_base %in% md_base]
junk <- lapply(
  rmd_posts,
  function(post) {
    output_file <- tempfile(fileext = ".txt")
    callr::r(
      function(input) {
        rmarkdown::render(input, envir = new.env())
      },
      args = list(input = post),
      stdout = output_file, stderr = "2>&1"
    )
    cat(readLines(output_file), sep = "\n")
    unlink(output_file)
  }
)
