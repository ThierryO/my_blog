---
author: Thierry Onkelinx
categories:
- reproducible research
- maps
coverImage: images/osmplotr/osmplotr-1.png
date: 2017-07-17
output:
  md_document:
    preserve_yaml: true
    variant: gfm
params:
  cellsize: 20
  scale: 2
slug: creating-maps-with-osmplotr
tags:
- maps
- osm
- openstreetmap
thumbnailImagePosition: left
title: Creating continuous coloured maps with osmplotr
---

During [useR!2017](https://user2017.brussels/) I attended a talk by Mark
Padgham titled [Maps are data, so why no plot data on a
map](https://channel9.msdn.com/Events/useR-international-R-User-conferences/useR-International-R-User-2017-Conference/Maps-are-data-so-why-plot-data-on-a-map).
In this blog post I will recreate the map from an earlier blogpost on
[estimating densities from a point
pattern](../../06/estimating-densities-from-a-point-pattern).

Let’s start by loading all required packages.

``` r
library(sp)
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
library(ggmap)
#> Loading required package: ggplot2
#> Google's Terms of Service: https://cloud.google.com/maps-platform/terms/.
#> Please cite ggmap if you use it! See citation("ggmap") for details.
library(osmplotr)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright
```

I rearranged the code from the previous blog post in two chunks. The
first chunk calculate the density and is required for both the `ggmap`
and the `osmplotr` solution. See the [earlier blog
post](../../06/estimating-densities-from-a-point-pattern) for the
details on what the code does.

``` r
points <- read.delim("../../data/20170628/points.txt", sep = " ")
crs_wgs84 <- CRS("+init=epsg:4326")
crs_lambert <- CRS("+init=epsg:31370")
#> Warning in showSRID(uprojargs, format = "PROJ", multiline = "NO", prefer_proj =
#> prefer_proj): Discarded datum Reseau_National_Belge_1972 in Proj4 definition
coordinates(points) <- ~lon + lat
points@proj4string <- crs_wgs84
points_lambert <- spTransform(points, crs_lambert)
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
dens <- expand.grid(
  lon = dens$x,
  lat = dens$y
) %>%
  mutate(
    lon = mean(lon) + params$scale * (lon - mean(lon)),
    lat = mean(lat) + params$scale * (lat - mean(lat))
  ) %>%
  mutate(
    density = as.vector(dens$z) * length(points_lambert),
    id = seq_along(density)
  )
```

The second chunk converts the density to a `SpatialPolygonsDataFrame` so
we can plot it with `ggmap`.

``` r
dx <- diff(dens$lon[1:2])
dy <- diff(unique(dens$lat)[1:2])
dens_gg <- dens %>%
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
coordinates(dens_gg) <- ~lon + lat
dens_gg@proj4string <- crs_lambert
dens_wgs <- spTransform(dens_gg, crs_wgs84) %>%
  as.data.frame()
summary(dens_wgs)
#>     density                id               x             y      
#>  Min.   :0.0000000   Min.   :   1.0   Min.   :-20   Min.   :-20  
#>  1st Qu.:0.0000000   1st Qu.: 324.8   1st Qu.:-20   1st Qu.:-20  
#>  Median :0.0000000   Median : 648.5   Median :-20   Median :-20  
#>  Mean   :0.0201582   Mean   : 648.5   Mean   : -4   Mean   : -4  
#>  3rd Qu.:0.0001973   3rd Qu.: 972.2   3rd Qu.: 20   3rd Qu.: 20  
#>  Max.   :0.4877629   Max.   :1296.0   Max.   : 20   Max.   : 20  
#>       lon             lat       
#>  Min.   :4.324   Min.   :50.84  
#>  1st Qu.:4.329   1st Qu.:50.84  
#>  Median :4.334   Median :50.84  
#>  Mean   :4.334   Mean   :50.84  
#>  3rd Qu.:4.339   3rd Qu.:50.84  
#>  Max.   :4.344   Max.   :50.85
```

The next chunk gets the satelite image and overlays is with the density
map. The density layer needs to be somewhat transparant in order to see
the background image.

``` r
ggmap(
  get_map(
    location = c(lon = mean(points$lon), lat = mean(points$lat)),
    zoom = 17,
    maptype = "satellite",
    source = "google"
  )
) +
  geom_polygon(
    data = dens_wgs, 
    aes(group = id, fill = density), 
    alpha = 0.5
  ) +
  scale_fill_gradientn(
    colours = rev(rainbow(100, start = 0, end = .7)),
    limits = c(0, NA)
  )
```

![](/images/osmplotr/ggmap-1.png)

The `osmplotr` package uses a set of points to create the colours. `x`
and `y` hold the longitude an latitude, `z` the variable for the colour
value.

``` r
coordinates(dens) <- ~lon + lat
dens@proj4string <- crs_lambert
dens_oms <- spTransform(dens, crs_wgs84)
dataset <- as.data.frame(dens_oms) %>%
  transmute(x = lon, y = lat, z = density)
```

The next step is to download the required [OpenStreetMap
(OSM)](https://www.openstreetmap.org) data. Here I selected all roads
and paths (“highway” is OSM terminology) and all the buildings.

``` r
bb <- bbox(dens_oms)
roads <- extract_osm_objects(key = 'highway', bbox = bb)
buildings <- extract_osm_objects(key = 'building', bbox = bb)
saveRDS(buildings, file = "buildings.rds")
```

Finaly, the map is created. `osm_basemap()` defines the extent and the
background colour. `add_osm_surface()` adds the coloured layers of roads
and buildings. I used `adjust_colours(-0.2)` to make the colours of
roads a bit darker.

``` r
osm_basemap(bbox = bb, bg = "gray95") %>%
  add_osm_surface(
    buildings,
    dat = dataset,
    cols = rainbow(100, end = 0.7),
    bg = "gray85"
  ) %>%
  add_osm_surface(
    roads,
    dat = dataset,
    cols = rainbow(100, end = 0.7) %>%
      adjust_colours(-0.2),
    bg = "gray85"
  ) %>%
  add_colourbar(
    cols = rainbow(100, end = 0.7),
    zlims = range(dataset$z)
  ) %>%
  add_axes()
```

![](/images/osmplotr/osmplotr-1.png)

## Pro and contra of `osmplotr` for continuous coloured maps

Note that `osmplotr` can create maps with discrete colours too. This was
outside the scope of this blog post. See the `osmplotr` vignettes on
plotting [basic
maps](https://cran.r-project.org/web/packages/osmplotr/vignettes/basic-maps.html)
and [data
maps](https://cran.r-project.org/web/packages/osmplotr/vignettes/data-maps.html)
(both categorical and continuous).

Much depends on the kind of data you want to display and the required
accuracy. `osmplotr` uses the objects from OSM. Each OSM feature will
get a uniform colour depending on the location of the centroid. Unless
you data matched with the OSM data, it is not possible to use the
accurate location of the data points.

Another point is scale and resolution of the OSM data. In case of an
urban area were all individual buildings are available and the size of
the individual buildings is small compared to the size of the map, then
the `osmplotr` map works quite well.
