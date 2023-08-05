library(fs)
library(sf)
library(XML)

source_dir <- "~/Downloads"
target_dir <- "bats/analysis/transect"

dir_ls(source_dir, regexp = "transect") |>
  map(readLines) -> kmls
kmls |>
  map(xmlParse) |>
  map(xmlToList) |>
  map(unlist, recursive = FALSE) |>
  map(tail, 1) |>
  map_dfr(unlist) |>
  `colnames<-`(c("transect", "coordinates")) |>
  mutate(
    transect = str_remove(transect, ".*transect ") |>
      as.Date(),
    coordinates = str_split(coordinates, " ")
  ) |>
  unnest(coordinates) |>
  separate_wider_delim(coordinates, ",", names = c("x", "y")) |>
  mutate(across(c("x", "y"), as.numeric)) |>
  write_delim(path(target_dir, "transect.txt"), delim = "\t")
kmls |>
  map(str_subset, "CDATA.*Soort") |>
  unlist(use.names = FALSE) |>
  tibble() |>
  `colnames<-`("raw") |>
  separate_wider_regex(
    raw,
    patterns = c(
      ".*observation/", observation = "[0-9]+", ".*?>",
      timestamp = "[0-9\\- :]{16}", ".*Soort: .* - ", species = "\\w+ \\w+",
      ".*"
    )
  ) |>
  bind_cols(
    kmls |>
      map(str_subset, "coordinates>[0-9\\.,]+<") |>
      unlist(use.names = FALSE) |>
      tibble() |>
      `colnames<-`("raw") |>
      separate_wider_regex(
        raw,
        patterns = c(
          ".*<.*>", x = "[0-9\\.]+", ",", y = "[0-9\\.]+", "<.*"
        )
      )
  ) |>
  write_delim(path(target_dir, "observation.txt"), delim = "\t")
