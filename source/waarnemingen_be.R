library(dplyr)

read_observation <- function(id){
  lapply(
    id,
    function(i){
      paste0("https://waarnemingen.be/export/daylists_export.php?id=", i) %>%
      read.delim(fileEncoding = "UTF-16", stringsAsFactors = FALSE)
    }
  ) %>%
    bind_rows()
}

