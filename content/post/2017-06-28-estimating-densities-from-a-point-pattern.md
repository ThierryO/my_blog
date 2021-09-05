---
author: Thierry Onkelinx
categories:
- statistics
- point pattern
coverImage: post/2017-06-28-estimating-densities-from-a-point-pattern_files/figure-gfm/density-1.svg
date: 2017-06-28
output:
  md_document:
    preserve_yaml: true
    variant: gfm
params:
  cellsize: 20
slug: estimating-densities-from-a-point-pattern
tags:
- point pattern
- density
- leaflet
- projection
thumbnailImagePosition: left
title: Estimating densities from a point pattern
---

In this example we focus on a set of 10450 coordinates in a small area.
The goal is to estimate the local density of points, expressed as the
number of point per unit area. The raw coordinates are given in [WGS84
(EPSG:4326)](https://epsg.io/4326), which is a geodetic coordinate
system. That is not suited for calculating distances, so we need to
re-project the points into a local projected coordinate system. In this
case we use [Lambert72 (EPSG:3170)](https://epsg.io/31370). Next we
calculate the density. To visualise the density, we have to transform
the results back in to WGS84.

The data used in this example is real data by centred to a different
location for privacy reasons. The dataset is available on
[GitHub](https://github.com/ThierryO/my_blog/tree/master/data/20170628).

First we must read the data into R. Plotting the raw data helps to check
errors in the data.

``` r
points <- read.delim("../../data/20170628/points.txt", sep = " ")
library(ggplot2)
ggplot(points, aes(x = lon, y = lat)) + 
  geom_point(data = points, alpha = 0.1, colour = "blue", shape = 4) +
  coord_map()
```

<img src="../../../post/2017-06-28-estimating-densities-from-a-point-pattern_files/figure-gfm/read-data-1.png" title="A plot with the blue x placed at the coordinates of every point." alt="A plot with the blue x placed at the coordinates of every point." width="672" style="display: block; margin: auto;" />

The next step is to convert the dataset in to a `SpatialPoints` object
with WGS84 project and re-project it into Lambert72. `sp::CRS()` defines
the coordinate systems. `sp::coordinates()<-` is an easy way to convert
a `data.frame` into a `SpatialPointsDataFrame`, but without specifying a
coordinate system. Therefore we need to override the `proj4string` slot
with the correct coordinate system. `sp::spTransform()` converts the
spatial object from the current coordinate system to another coordinate
system.

``` r
library(sp)
crs_wgs84 <- CRS("+init=epsg:4326")
crs_lambert <- CRS("+init=epsg:31370")
#> Warning in showSRID(uprojargs, format = "PROJ", multiline = "NO", prefer_proj =
#> prefer_proj): Discarded datum Reseau_National_Belge_1972 in Proj4 definition
coordinates(points) <- ~lon + lat
points@proj4string <- crs_wgs84
points_lambert <- spTransform(points, crs_lambert)
```

Once we have the points into a projected coordinate system, we can
calculate the densities. We start by defining a grid. `cellsize` is the
dimension of the square grid cell in the units of the projected
coordinate system. Meters in case of Lambert72. The boundaries of the
grid are defined using `pretty()`, which turns a vector of numbers into
a “pretty” vector with rounded numbers. The combination of the
boundaries and the cell size determine the number of grid cells `n` in
each dimension. `diff()` calculates the difference between to adjacent
numbers of a vector. The density is calculated with `MASS::kde2d()`
based on the vectors with the longitude and latitude, the number of grid
cells in each dimension and the boundaries of the grid. This returns the
grid as a list with elements `x` (a vector of longitude coordinates of
the centroids), `y` (a vector of latitude coordinates of the centroids)
and `z` (a matrix with densities). The values in `z` are densities for
the ‘average’ point per unit area. When we multiply the value `z` with
the area of the grid cell and sum all of them we get 1. So if we
multiple `z` with the number of points we get the density of the points
per unit area.

We use [`dplyr::mutate()`](http://dplyr.tidyverse.org/) to convert it
into a `data.frame`. The last two steps convert the centroids into a set
of coordinates for square polygons.

``` r
library(MASS)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following object is masked from 'package:MASS':
#> 
#>     select
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
xlim <- range(pretty(points_lambert$lon)) + c(-100, 100)
ylim <- range(pretty(points_lambert$lat)) + c(-100, 100)
n <- c(
  diff(xlim),
  diff(ylim)
) / params$cellsize + 1
dens <- kde2d(
  x = points_lambert$lon,
  y = points_lambert$lat,
  n = n,
  lims = c(xlim, ylim)
)
dx <- diff(dens$x[1:2])
dy <- diff(dens$y[1:2])
sum(dens$z * dx * dy)
#> [1] 1
dens <- expand.grid(
  lon = dens$x,
  lat = dens$y
) %>%
  mutate(
    density = as.vector(dens$z) * length(points_lambert),
    id = seq_along(density)
  ) %>%
  merge(
    data.frame(
      x = dx * (c(0, 0, 1, 1, 0) - 0.5),
      y = dy * (c(0, 1, 1, 0, 0) - 0.5)
    )
  ) %>%
  mutate(
    lon = lon + x,
    lat = lat + y
  )
```

In order to visualise the result, we have to re-project the coordinates
back to WGS84. Then we can display the raster with a web based
background image.

``` r
dens %>%
  as.data.frame() %>%
  group_by(id) %>%
  slice(1) %>%
  ggplot(aes(x = lon, y = lat)) +
  geom_tile(aes(fill = density), alpha = 0.5) +
  coord_equal() +
  scale_fill_gradientn(
    "density\n(#/m²)",
    colours = rev(rainbow(100, start = 0, end = .7)),
    limits = c(0, NA)
  )
```

<img src="../../../post/2017-06-28-estimating-densities-from-a-point-pattern_files/figure-gfm/density-1.svg" title="Static image of density" alt="Static image of density" width="672" style="display: block; margin: auto;" />

Using `leaflet` to generate a map was a bit more laborious. Using the
`data.frame dens_wgs`directly failed. So we converted the `data.frame`
in a `SpatialPolygonsDataframe`, which is a combination of a
`SpatialPolygons` and a `data.frame`. The `SpatialPolygons` consists of
a list of `Polygons`, one for each row of the `data.frame`. A `Polygons`
object consist of a list of one or more `Polygon` object. In this
example a single polygon which represents the grid cell.

``` r
coordinates(dens) <- ~lon + lat
dens@proj4string <- crs_lambert
dens_wgs <- spTransform(dens, crs_wgs84) %>%
  as.data.frame()
dens_sp <- lapply(
  unique(dens_wgs$id),
  function(i){
    filter(dens_wgs, id == i) %>%
      select(lon, lat) %>%
      Polygon() %>%
      list() %>%
      Polygons(ID = i)
  }
) %>%
  SpatialPolygons() %>%
  SpatialPolygonsDataFrame(
    data = dens_wgs %>%
      distinct(id, density),
    match.ID = FALSE
  )
```

`leaflet` requires a predefined function with a colour pallet. We use
`leaflet::colorNumeric()` to get a continuous pallet. Setting
`stroke = FALSE` removes the borders of the polygon. `fillOpacity` sets
the transparency of the polygons.

``` r
library(leaflet)
pal <- colorNumeric(
  palette = rev(rainbow(100, start = 0, end = .7)),
  domain = c(0, dens_sp$density)
)
leaflet(dens_sp) %>%
  addTiles() %>%
  addPolygons(color = ~pal(density), stroke = FALSE, fillOpacity = 0.5) %>%
  addLegend(pal = pal, values = ~density)
```

    {{< htmlwidget "2017-06-28-estimating-densities-from-a-point-pattern-density-leaflet-0" 50.000000 >}}

## Session info

These R packages were used to create this post.

``` r
sessioninfo::session_info()
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
#>  package     * version date       lib source        
#>  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.1.0)
#>  cli           3.0.1   2021-07-17 [1] CRAN (R 4.1.1)
#>  codetools     0.2-18  2020-11-04 [1] CRAN (R 4.1.0)
#>  colorspace    2.0-2   2021-06-24 [1] CRAN (R 4.1.0)
#>  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.1.0)
#>  crosstalk     1.1.1   2021-01-12 [1] CRAN (R 4.1.0)
#>  DBI           1.1.1   2021-01-15 [1] CRAN (R 4.1.0)
#>  digest        0.6.27  2020-10-24 [1] CRAN (R 4.1.0)
#>  dplyr       * 1.0.7   2021-06-18 [1] CRAN (R 4.1.0)
#>  ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.1.0)
#>  evaluate      0.14    2019-05-28 [1] CRAN (R 4.1.0)
#>  fansi         0.5.0   2021-05-25 [1] CRAN (R 4.1.0)
#>  farver        2.1.0   2021-02-28 [1] CRAN (R 4.1.0)
#>  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.1.0)
#>  generics      0.1.0   2020-10-31 [1] CRAN (R 4.1.0)
#>  ggplot2     * 3.3.5   2021-06-25 [1] CRAN (R 4.1.0)
#>  glue          1.4.2   2020-08-27 [1] CRAN (R 4.1.0)
#>  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.1.0)
#>  here        * 1.0.1   2020-12-13 [1] CRAN (R 4.1.0)
#>  highr         0.9     2021-04-16 [1] CRAN (R 4.1.0)
#>  htmltools     0.5.2   2021-08-25 [1] CRAN (R 4.1.1)
#>  htmlwidgets   1.5.3   2020-12-10 [1] CRAN (R 4.1.0)
#>  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.1.0)
#>  knitr       * 1.33    2021-04-24 [1] CRAN (R 4.1.0)
#>  labeling      0.4.2   2020-10-20 [1] CRAN (R 4.1.0)
#>  lattice       0.20-44 2021-05-02 [1] CRAN (R 4.1.0)
#>  leaflet     * 2.0.4.1 2021-01-07 [1] CRAN (R 4.1.0)
#>  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.1.0)
#>  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.1.0)
#>  mapproj       1.2.7   2020-02-03 [1] CRAN (R 4.1.0)
#>  maps          3.3.0   2018-04-03 [1] CRAN (R 4.1.0)
#>  MASS        * 7.3-54  2021-05-03 [1] CRAN (R 4.1.0)
#>  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.1.0)
#>  pillar        1.6.2   2021-07-29 [1] CRAN (R 4.1.1)
#>  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.1.0)
#>  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.1.0)
#>  R6            2.5.1   2021-08-19 [1] CRAN (R 4.1.1)
#>  rgdal         1.5-23  2021-02-03 [1] CRAN (R 4.1.0)
#>  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.1.0)
#>  rmarkdown     2.10    2021-08-06 [1] CRAN (R 4.1.1)
#>  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.1.0)
#>  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.1.0)
#>  scales        1.1.1   2020-05-11 [1] CRAN (R 4.1.0)
#>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.1.0)
#>  sp          * 1.4-5   2021-01-10 [1] CRAN (R 4.1.0)
#>  stringi       1.7.4   2021-08-25 [1] CRAN (R 4.1.1)
#>  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.1.0)
#>  tibble        3.1.4   2021-08-25 [1] CRAN (R 4.1.1)
#>  tidyselect    1.1.1   2021-04-30 [1] CRAN (R 4.1.0)
#>  utf8          1.2.2   2021-07-24 [1] CRAN (R 4.1.1)
#>  vctrs         0.3.8   2021-04-29 [1] CRAN (R 4.1.0)
#>  withr         2.4.2   2021-04-18 [1] CRAN (R 4.1.0)
#>  xfun          0.25    2021-08-06 [1] CRAN (R 4.1.1)
#>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.1.0)
#> 
#> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
#> [2] /usr/local/lib/R/site-library
#> [3] /usr/lib/R/site-library
#> [4] /usr/lib/R/library
```
