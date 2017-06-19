library(dplyr)
library(lubridate)
library(curl)
library(XML)
library(sp)

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

read_kml <- function(observation) {
  dataset <- observation %>%
    mutate(date = round_date(time, unit = "day")) %>%
    distinct(route_id, date, starttime, endtime)
  rownames(dataset) <- dataset$route_id
  kml <- sapply(
    dataset$route_id,
    function(i){
      paste0("https://waarnemingen.be/user/daylists_to_kml/40052?id=", i) %>%
        curl_download(destfile = tempfile(fileext = ".kml"))
    }
  )
  xml <- lapply(
    seq_len(nrow(dataset)),
    function(i){
    xml <- xmlParse(kml[i]) %>%
      xmlToList() %>%
      unlist(recursive = FALSE)
    list_names <- lapply(xml, names)
    list(
      line = xml[
        sapply(
          list_names,
          function(x){
            "LineString" %in% x
          }
        )
      ] %>%
        unlist() %>%
        "["("Document.Placemark.LineString.coordinates") %>%
        strsplit(" ") %>%
        unlist() %>%
        strsplit(",") %>%
        do.call(what = rbind) %>%
        as.data.frame(stringsAsFactors = FALSE) %>%
        mutate_all(funs(as.numeric)) %>%
        Line() %>%
        list() %>%
        Lines(ID = dataset$route_id[i]),
      point = xml[
        sapply(
          list_names,
          function(x){
            "Point" %in% x
          }
        )
      ] %>%
        lapply(
          function(x){
            data.frame(
              species = gsub(".* - ", "", x$name),
              x = gsub("(.*),(.*)", "\\1", x$Point$coordinates),
              y = gsub("(.*),(.*)", "\\2", x$Point$coordinates),
              time = gsub("Tijd : (.*) Aantal : (.*)", "\\1", x$description),
              count = gsub("Tijd : (.*) Aantal : (.*)", "\\2", x$description),
              stringsAsFactors = FALSE
            )
          }
        ) %>%
        bind_rows() %>%
        mutate(
          route_id = dataset$route_id[i],
          date = dataset$date[i],
          starttime = dataset$starttime[i],
          endtime = dataset$endtime[i]
        )
    )
  })
  route <- lapply(
    xml,
    function(x){
      x$line
    }
  ) %>%
    SpatialLines(CRS("+proj=longlat +datum=WGS84")) %>%
    SpatialLinesDataFrame(data = dataset)
  observation <- lapply(
    xml,
    function(x){
      x$point
    }
  ) %>%
    bind_rows() %>%
    mutate(
      species = factor(species),
      x = as.numeric(x),
      y = as.numeric(y),
      count = as.integer(count),
      time = paste(date, time) %>%
        as.POSIXct(tz = "CEST"),
      time = time - ifelse(time > endtime, 24 * 3600, 0)
    )
  list(
    route = route,
    point = SpatialPointsDataFrame(
      coords = observation[, c("x", "y")],
      data = observation,
      proj4string = CRS("+proj=longlat +datum=WGS84")
    )
  )
}
