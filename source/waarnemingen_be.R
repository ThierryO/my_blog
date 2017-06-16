library(dplyr)
library(lubridate)

read_observation <- function(id){
  lapply(
    id,
    function(i){
      paste0("https://waarnemingen.be/export/daylists_export.php?id=", i) %>%
      read.delim(fileEncoding = "UTF-16", stringsAsFactors = FALSE)
    }
  ) %>%
    bind_rows() %>%
    transmute(
      route_id = Streeplijst,
      observation_id = Waarneming,
      time = paste(Datum, Tijd) %>%
        as.POSIXct(tz = "CEST"),
      starttime = paste(Datum, Starttijd.bezoek) %>%
        as.POSIXct(tz = "CEST"),
      endtime = paste(Datum, Eindtijd) %>%
        as.POSIXct(tz = "CEST"),
      starttime = starttime + ifelse(time < starttime, -24 * 3600, 0),
      endtime = endtime + ifelse(endtime < time, 24 * 3600, 0),
      species = factor(Wetenschappelijke.naam),
      count = Aantal
    )
}
