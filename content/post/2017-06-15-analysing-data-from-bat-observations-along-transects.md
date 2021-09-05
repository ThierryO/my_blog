---
author: Thierry Onkelinx
categories:
- bats
- analysis
coverImage: images/2017-06-15-analysing-data-from-bat-observations-along-transects_thumb.png
date: 2017-06-15
output:
  md_document:
    preserve_yaml: true
    variant: gfm
params:
  crs: "+init=epsg:31370"
  range: 20
  resolution: 100
slug: analysing-data-from-bat-observations-along-transects
tags:
- spatial point process
- kml
thumbnailImagePosition: right
title: Analysing data from bat observations along transects
---

This post will handle observations of bats along a set of transects. It
is a work in progress simply because I’m still collecting more data. So
come back once and awhile to see potential updates.

# The survey

The principle of the survey is quite simple: walk around with a bat
detector and note the route you took and were you encounter bats. Repeat
this several times. I choose to take a different route each time so I
can cover the same area at different times of night.

I use
[ObsMapp](https://play.google.com/store/apps/details?id=org.obsmapp&hl=en)
to trace the route and the observations. The bat detector is a
[Peersonic RPA2](../peersonic/) with [Philips SHB9850NC
headphones](http://www.philips.co.uk/c-p/SHB9850NC_00/wireless-noise-cancelling-headphones).
This set-up is quite handy. At the start of the route you start
listening to the bat detector and tell ObsMapp to start tracking the
route. Each time you encounter a bat you a) make a sound recording of
the bat and b) mark the observation in ObsMapp[1]. At home you upload
the observations to [waarnemingen.be](https://www.waarnemingen.be),
[waarneming.nl](https://www.waarneming.nl) or
[observation.org](https://www.observation.org/). Then you check the
observations based on the recorded sounds and update the observations on
the website. Each survey is downloadable from the website under several
formats. Here we will use both the [KML
format](https://developers.google.com/kml/documentation/) and the csv
format. The KML is required because it contains both the track of each
route and the observations. The csv is needed for the date, the start
time and end time of the track.

# Survey effort

First we have to download the surveys manually. We need some ugly code
to get everything in a usable format. The code is available on
[GitHub](https://github.com/ThierryO/my_blog/blob/master/source/waarnemingen_be.R).
The result is the set of all tracks and observations.

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-raw-data-raw-data" 50.000000 >}}

We determine the survey effort as the cumulative proportion on the area
of grid cells that a covered by a survey. So we start by defining a grid
with 100x100m resolution. Then we create of buffer on 20m around the
tracks because assume that we can here most bats up to this distance on
the bat detector. The result is a ribbon marking the area where we could
have detected bats. The total area of ribbon per grid cell is an
indicator of the total survey effort per grid cell.

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-effort-survey-effort" 50.000000 >}}

# Presence of bats

The number of observations per species is quite different. Only the
common pipistrelle (*Pipistrellus pipistrellus*) has currently enough
observations for the analysis (table @ref(tab:observation-species)).
Note that the table also contains other mammal species because I note
all mammal species that I encounter.

| species                    | 2017-06-05 | 2017-06-11 | 2017-06-20 | 2017-06-30 | 2017-08-06 |
|:---------------------------|-----------:|-----------:|-----------:|-----------:|-----------:|
| Pipistrellus pipistrellus  |         51 |         39 |         14 |         28 |         31 |
| Erinaceus europaeus        |          0 |          2 |          0 |          0 |          0 |
| Martes foina               |          0 |          0 |          1 |          1 |          0 |
| Myotis mystacinus/brandtii |          2 |          0 |          0 |          0 |          0 |
| Oryctolagus cuniculus      |          1 |          0 |          0 |          0 |          0 |
| Pipistrellus spec.         |          0 |          0 |          1 |          0 |          0 |
| Vulpes vulpes              |          1 |          0 |          0 |          0 |          0 |

Number of observations per species and per track

Next we check for each combination of track and grid cell whether we
detected pipistrelles or not. The figure below displays the average
presence over all tracks.

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-presence-presence" 50.000000 >}}

The next figure shows the distance from the centre of each grid cell to
the centre of the nearest other grid cell were we detected common
pipistrelle during the entire study. This can given an indication of
clustering or repulsion.

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-nndist-nearest-neighbour" 50.000000 >}}

# Exploratory data analysis

The current analysis used only very basic variables: survey effort and
nearest neighbour distance.

<img src="../../../post/2017-06-15-analysing-data-from-bat-observations-along-transects_files/figure-gfm/eda-effort-1.svg" title="Dection of common pipistrelle in terms of survey effort." alt="Dection of common pipistrelle in terms of survey effort." width="672" style="display: block; margin: auto;" />

<img src="../../../post/2017-06-15-analysing-data-from-bat-observations-along-transects_files/figure-gfm/eda-nn-1.svg" title="Dection of common pipistrelle in terms of distance to nearest neighbouring grid cell were common pipistrelle was observed. A small jitter was added due to heavy overlap between points." alt="Dection of common pipistrelle in terms of distance to nearest neighbouring grid cell were common pipistrelle was observed. A small jitter was added due to heavy overlap between points." width="672" style="display: block; margin: auto;" />

# Modelling

The figure below shows the median predicted probability for common
pipistrelle. This is an estimation of the change to encounter common
pipistrelles in each grid cell. The lower credible limit of these
prediction are useful to detect the important locations. The higher the
lower credible limit, the more certain the model is about the presence
of common pipistrelles. Likewise, the upper credible limit is useful to
detect locations where the model is more certain about the absence of
common pipistrelle.

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-pred-mean-prediction-mean" 50.000000 >}}

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-pred-lcl-prediction-lcl" 50.000000 >}}

    {{< htmlwidget "2017-06-15-analysing-data-from-bat-observations-along-transects-pred-ucl-prediction-ucl" 50.000000 >}}

The [receiver operating
characteristic](https://en.wikipedia.org/wiki/Receiver_operating_characteristic)
(ROC) gives an indication of the quality of the model. It can be
summarised by the [area under the
curve](https://en.wikipedia.org/wiki/Receiver_operating_characteristic#Area_under_the_curve)
(AUC). The closer the AUC value get to 1, the better the model.

<img src="../../../post/2017-06-15-analysing-data-from-bat-observations-along-transects_files/figure-gfm/roc-1.svg" title="Receiver operating curve." alt="Receiver operating curve." width="672" style="display: block; margin: auto;" />

## Session info

These R packages were used to create this post.

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value                       
    #>  version  R version 4.1.1 (2021-08-10)
    #>  os       Ubuntu 18.04.5 LTS          
    #>  system   x86_64, linux-gnu           
    #>  ui       X11                         
    #>  language nl_BE:nl                    
    #>  collate  nl_BE.UTF-8                 
    #>  ctype    nl_BE.UTF-8                 
    #>  tz       Europe/Brussels             
    #>  date     2021-09-05                  
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  package      * version  date       lib source        
    #>  assertthat     0.2.1    2019-03-21 [1] CRAN (R 4.1.0)
    #>  base64enc      0.1-3    2015-07-28 [1] CRAN (R 4.1.0)
    #>  callr          3.7.0    2021-04-20 [1] CRAN (R 4.1.0)
    #>  class          7.3-19   2021-05-03 [1] CRAN (R 4.1.0)
    #>  classInt       0.4-3    2020-04-07 [1] CRAN (R 4.1.0)
    #>  cli            3.0.1    2021-07-17 [1] CRAN (R 4.1.1)
    #>  codetools      0.2-18   2020-11-04 [1] CRAN (R 4.1.0)
    #>  colorspace     2.0-2    2021-06-24 [1] CRAN (R 4.1.0)
    #>  crayon         1.4.1    2021-02-08 [1] CRAN (R 4.1.0)
    #>  crosstalk      1.1.1    2021-01-12 [1] CRAN (R 4.1.0)
    #>  curl         * 4.3.2    2021-06-23 [1] CRAN (R 4.1.0)
    #>  DBI            1.1.1    2021-01-15 [1] CRAN (R 4.1.0)
    #>  digest         0.6.27   2020-10-24 [1] CRAN (R 4.1.0)
    #>  dplyr        * 1.0.7    2021-06-18 [1] CRAN (R 4.1.0)
    #>  e1071          1.7-8    2021-07-28 [1] CRAN (R 4.1.1)
    #>  ellipsis       0.3.2    2021-04-29 [1] CRAN (R 4.1.0)
    #>  evaluate       0.14     2019-05-28 [1] CRAN (R 4.1.0)
    #>  fansi          0.5.0    2021-05-25 [1] CRAN (R 4.1.0)
    #>  farver         2.1.0    2021-02-28 [1] CRAN (R 4.1.0)
    #>  fastmap        1.1.0    2021-01-25 [1] CRAN (R 4.1.0)
    #>  foreach      * 1.5.1    2020-10-15 [1] CRAN (R 4.1.0)
    #>  generics       0.1.0    2020-10-31 [1] CRAN (R 4.1.0)
    #>  ggplot2      * 3.3.5    2021-06-25 [1] CRAN (R 4.1.0)
    #>  git2r          0.28.0   2021-01-10 [1] CRAN (R 4.1.0)
    #>  git2rdata    * 0.3.1    2021-01-21 [1] CRAN (R 4.1.0)
    #>  glue           1.4.2    2020-08-27 [1] CRAN (R 4.1.0)
    #>  gtable         0.3.0    2019-03-25 [1] CRAN (R 4.1.0)
    #>  here         * 1.0.1    2020-12-13 [1] CRAN (R 4.1.0)
    #>  highr          0.9      2021-04-16 [1] CRAN (R 4.1.0)
    #>  htmltools      0.5.2    2021-08-25 [1] CRAN (R 4.1.1)
    #>  htmlwidgets    1.5.3    2020-12-10 [1] CRAN (R 4.1.0)
    #>  INLA         * 21.02.23 2021-05-29 [1] local         
    #>  iterators      1.0.13   2020-10-15 [1] CRAN (R 4.1.0)
    #>  jsonlite       1.7.2    2020-12-09 [1] CRAN (R 4.1.0)
    #>  KernSmooth     2.23-20  2021-05-03 [1] CRAN (R 4.1.0)
    #>  knitr        * 1.33     2021-04-24 [1] CRAN (R 4.1.0)
    #>  labeling       0.4.2    2020-10-20 [1] CRAN (R 4.1.0)
    #>  lattice        0.20-44  2021-05-02 [1] CRAN (R 4.1.0)
    #>  leafem         0.1.6    2021-05-24 [1] CRAN (R 4.1.0)
    #>  leaflet      * 2.0.4.1  2021-01-07 [1] CRAN (R 4.1.0)
    #>  lifecycle      1.0.0    2021-02-15 [1] CRAN (R 4.1.0)
    #>  lubridate    * 1.7.10   2021-02-26 [1] CRAN (R 4.1.0)
    #>  magrittr       2.0.1    2020-11-17 [1] CRAN (R 4.1.0)
    #>  mapview      * 2.10.0   2021-06-05 [1] CRAN (R 4.1.0)
    #>  Matrix       * 1.3-4    2021-06-01 [1] CRAN (R 4.1.0)
    #>  MatrixModels   0.5-0    2021-03-02 [1] CRAN (R 4.1.0)
    #>  mgcv           1.8-36   2021-06-01 [1] CRAN (R 4.1.0)
    #>  munsell        0.5.0    2018-06-12 [1] CRAN (R 4.1.0)
    #>  nlme           3.1-152  2021-02-04 [1] CRAN (R 4.1.0)
    #>  pillar         1.6.2    2021-07-29 [1] CRAN (R 4.1.1)
    #>  pkgconfig      2.0.3    2019-09-22 [1] CRAN (R 4.1.0)
    #>  plotROC      * 2.2.1    2018-06-23 [1] CRAN (R 4.1.0)
    #>  plyr           1.8.6    2020-03-03 [1] CRAN (R 4.1.0)
    #>  png            0.1-7    2013-12-03 [1] CRAN (R 4.1.0)
    #>  processx       3.5.2    2021-04-30 [1] CRAN (R 4.1.0)
    #>  proxy          0.4-26   2021-06-07 [1] CRAN (R 4.1.0)
    #>  ps             1.6.0    2021-02-28 [1] CRAN (R 4.1.0)
    #>  purrr          0.3.4    2020-04-17 [1] CRAN (R 4.1.0)
    #>  R6             2.5.1    2021-08-19 [1] CRAN (R 4.1.1)
    #>  raster         3.4-13   2021-06-18 [1] CRAN (R 4.1.0)
    #>  RColorBrewer   1.1-2    2014-12-07 [1] CRAN (R 4.1.0)
    #>  Rcpp           1.0.7    2021-07-07 [1] CRAN (R 4.1.0)
    #>  rgdal          1.5-23   2021-02-03 [1] CRAN (R 4.1.0)
    #>  rgeos        * 0.5-5    2020-09-07 [1] CRAN (R 4.1.0)
    #>  rlang          0.4.11   2021-04-30 [1] CRAN (R 4.1.0)
    #>  rmarkdown      2.10     2021-08-06 [1] CRAN (R 4.1.1)
    #>  rprojroot      2.0.2    2020-11-15 [1] CRAN (R 4.1.0)
    #>  rstudioapi     0.13     2020-11-12 [1] CRAN (R 4.1.0)
    #>  s2             1.0.6    2021-06-17 [1] CRAN (R 4.1.0)
    #>  satellite      1.0.2    2019-12-09 [1] CRAN (R 4.1.0)
    #>  scales       * 1.1.1    2020-05-11 [1] CRAN (R 4.1.0)
    #>  sessioninfo    1.1.1    2018-11-05 [1] CRAN (R 4.1.0)
    #>  sf           * 1.0-2    2021-07-26 [1] CRAN (R 4.1.1)
    #>  sp           * 1.4-5    2021-01-10 [1] CRAN (R 4.1.0)
    #>  stringi        1.7.4    2021-08-25 [1] CRAN (R 4.1.1)
    #>  stringr        1.4.0    2019-02-10 [1] CRAN (R 4.1.0)
    #>  tibble         3.1.4    2021-08-25 [1] CRAN (R 4.1.1)
    #>  tidyr        * 1.1.3    2021-03-03 [1] CRAN (R 4.1.0)
    #>  tidyselect     1.1.1    2021-04-30 [1] CRAN (R 4.1.0)
    #>  units          0.7-2    2021-06-08 [1] CRAN (R 4.1.0)
    #>  utf8           1.2.2    2021-07-24 [1] CRAN (R 4.1.1)
    #>  vctrs          0.3.8    2021-04-29 [1] CRAN (R 4.1.0)
    #>  webshot        0.5.2    2019-11-22 [1] CRAN (R 4.1.0)
    #>  withr          2.4.2    2021-04-18 [1] CRAN (R 4.1.0)
    #>  wk             0.5.0    2021-07-13 [1] CRAN (R 4.1.0)
    #>  xfun           0.25     2021-08-06 [1] CRAN (R 4.1.1)
    #>  XML          * 3.99-0.7 2021-08-17 [1] CRAN (R 4.1.1)
    #>  yaml           2.2.1    2020-02-01 [1] CRAN (R 4.1.0)
    #> 
    #> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
    #> [2] /usr/local/lib/R/site-library
    #> [3] /usr/lib/R/site-library
    #> [4] /usr/lib/R/library

[1] can be done in as little as three taps.
