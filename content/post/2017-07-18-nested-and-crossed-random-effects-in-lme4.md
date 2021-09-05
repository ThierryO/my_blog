---
author: Thierry Onkelinx
categories:
- statistics
- mixed models
coverImage: post/2017-07-18-nested-and-crossed-random-effects-in-lme4_files/figure-gfm/school-design-1.svg
date: 2017-07-18
output:
  md_document:
    preserve_yaml: true
    variant: gfm
slug: lme4-random-effects
tags:
- lme4
- random effect
thumbnailImagePosition: right
title: Nested and crossed random effects in “lme4”
---

People often get confused on how to code nested and crossed random
effects in the [`lme4`](https://cran.rstudio.com/web/packages/lme4/)
package. I will try to make this more clear using some artificial data
sets.

## Nested random effects

Nested random effects assume that there is some kind of hierarchy in the
grouping of the observations. E.g. schools and classes. A class groups a
number of students and a school groups a number of classes. There is a
one-to-many relationship between the random effects. E.g. a school can
contain multiple classes but a class can only be part of one school.
Lets start by creating a simple example with fake data to explain the
design. The figure shows the contingency matrix for the dataset.

``` r
library(DT)
library(lme4)
#> Loading required package: Matrix
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
#> ✓ tibble  3.1.4     ✓ dplyr   1.0.7
#> ✓ tidyr   1.1.3     ✓ stringr 1.4.0
#> ✓ readr   2.0.1     ✓ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> x tidyr::expand() masks Matrix::expand()
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
#> x tidyr::pack()   masks Matrix::pack()
#> x tidyr::unpack() masks Matrix::unpack()
```

``` r
set.seed(123)
n_school <- 10
mean_n_class <- 7
mean_n_student <- 5

n_class <- rpois(n_school, mean_n_class)
schools <- map2_df(
  seq_len(n_school), 
  n_class, 
  ~data_frame(
    school = .x, 
    class = seq_len(.y),
    students = rpois(.y, mean_n_student)
  )
) %>%
  group_by(school, class) %>%
  do(
    student = data_frame(student = seq_len(.$students))
  ) %>%
  unnest(student) %>%
  mutate(
    class2 = interaction(class, school, drop = TRUE),
    student2 = interaction(class2, student, drop = TRUE)
  )
#> Warning: `data_frame()` was deprecated in tibble 1.1.0.
#> Please use `tibble()` instead.
```

`schools` contains 3 design variables: `school`, `class` and `student`.
Each numbering restarts at 1 when the higher level number changes. Hence
the id of class and student are not unique. Therefore I added two new
variables `class2` and `student2` which are unique id’s for each class
and student. The next step is adding the expected and observed values.

    {{< htmlwidget "2017-07-18-nested-and-crossed-random-effects-in-lme4-nested-unnamed-chunk-1" 50.000000 >}}

``` r
with(schools, table(class2, school)) %>%
  image(
    col = grey.colors(10, start = 1, end = 0), 
    axes = FALSE, 
    xlab = "Class", 
    ylab = "School"
  )
```

<img src="../../../post/2017-07-18-nested-and-crossed-random-effects-in-lme4_files/figure-gfm/school-design-1.svg" title="Contingency matrix for the `schools`data set" alt="Contingency matrix for the `schools`data set" width="672" style="display: block; margin: auto;" />

``` r
school_sd <- 2
class_sd <- 2
noise_sd <- 1
intercept <- 50

school_effect <- rnorm(n_school, mean = 0, sd = school_sd)
class_effect <- rnorm(length(levels(schools$class2)), mean = 0, sd = class_sd)
schools <- schools %>%
  mutate(
    mu = intercept + school_effect[school] + class_effect[class2],
    y = mu + rnorm(n(), mean = 0, sd = noise_sd)
  )
```

### Explicit nesting

The first option is to use explicit nesting. Here we add a random effect
for each hierarchical level and use the `:` notation to add all higher
levels. This can be expanded to more than two levels. E.g.
`(1|A) + (1|A:B) + (1|A:B:C) + (1|A:B:C:D)`. The nice thing about this
notation is twofold: a) the nesting is explicit and clear for all
readers; b) it is insensitive for the order: e.g. `(1|A) + (1|A:B)` is
identical to `(1|B:A) + (1|A)`.

``` r
lmer(y ~ (1|school) + (1|school:class), data = schools)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | school) + (1 | school:class)
#>    Data: schools
#> REML criterion at convergence: 1290.668
#> Random effects:
#>  Groups       Name        Std.Dev.
#>  school:class (Intercept) 1.631   
#>  school       (Intercept) 1.806   
#>  Residual                 1.073   
#> Number of obs: 366, groups:  school:class, 74; school, 10
#> Fixed Effects:
#> (Intercept)  
#>       50.27
lmer(y ~ (1|class:school) + (1|school), data = schools)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | class:school) + (1 | school)
#>    Data: schools
#> REML criterion at convergence: 1290.668
#> Random effects:
#>  Groups       Name        Std.Dev.
#>  class:school (Intercept) 1.631   
#>  school       (Intercept) 1.806   
#>  Residual                 1.073   
#> Number of obs: 366, groups:  class:school, 74; school, 10
#> Fixed Effects:
#> (Intercept)  
#>       50.27
```

### Shorthand nesting

`(1|A) + (1|A:B)` can be abbreviated into `(1|A/B)`. However, I
recommend against it because here the order is important as seen in the
example below. `(1|B/A)` expands to `(1|B) + (1|B:A)`, which is clearly
a different model than `(1|A) + (1|A:B)`. I’ve seen many people being
confused about the order, therefore I recommend to be explicit instead
of using shorthand.

``` r
lmer(y ~ (1|school/class), data = schools)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | school/class)
#>    Data: schools
#> REML criterion at convergence: 1290.668
#> Random effects:
#>  Groups       Name        Std.Dev.
#>  class:school (Intercept) 1.631   
#>  school       (Intercept) 1.806   
#>  Residual                 1.073   
#> Number of obs: 366, groups:  class:school, 74; school, 10
#> Fixed Effects:
#> (Intercept)  
#>       50.27
lmer(y ~ (1|class/school), data = schools)
#> boundary (singular) fit: see ?isSingular
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | class/school)
#>    Data: schools
#> REML criterion at convergence: 1320.039
#> Random effects:
#>  Groups       Name        Std.Dev.
#>  school:class (Intercept) 2.330   
#>  class        (Intercept) 0.000   
#>  Residual                 1.073   
#> Number of obs: 366, groups:  school:class, 74; class, 11
#> Fixed Effects:
#> (Intercept)  
#>       50.42  
#> optimizer (nloptwrap) convergence code: 0 (OK) ; 0 optimizer warnings; 1 lme4 warnings
```

### Implicit nesting

With implicit nesting, the nesting is ‘defined’ in the data. That is
each level of a random effect has a one-to-many relation with the levels
of the lower random effect. E.g. each class id is unique for a given
class in a given school and cannot refer to a class in any other school.
This is how we constructed the `class2` variable in our data. With
implicit nesting the code can be abbreviated to `(1|A) + (1|B)`. Note
that the `(1|A) + (1|A:B)` and `(1|A/B)` notations remain valid.

``` r
lmer(y ~ (1|school) + (1|class2), data = schools)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | school) + (1 | class2)
#>    Data: schools
#> REML criterion at convergence: 1290.668
#> Random effects:
#>  Groups   Name        Std.Dev.
#>  class2   (Intercept) 1.631   
#>  school   (Intercept) 1.806   
#>  Residual             1.073   
#> Number of obs: 366, groups:  class2, 74; school, 10
#> Fixed Effects:
#> (Intercept)  
#>       50.27
lmer(y ~ (1|school) + (1|school:class2), data = schools)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | school) + (1 | school:class2)
#>    Data: schools
#> REML criterion at convergence: 1290.668
#> Random effects:
#>  Groups        Name        Std.Dev.
#>  school:class2 (Intercept) 1.631   
#>  school        (Intercept) 1.806   
#>  Residual                  1.073   
#> Number of obs: 366, groups:  school:class2, 74; school, 10
#> Fixed Effects:
#> (Intercept)  
#>       50.27
lmer(y ~ (1|school/class2), data = schools)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | school/class2)
#>    Data: schools
#> REML criterion at convergence: 1290.668
#> Random effects:
#>  Groups        Name        Std.Dev.
#>  class2:school (Intercept) 1.631   
#>  school        (Intercept) 1.806   
#>  Residual                  1.073   
#> Number of obs: 366, groups:  class2:school, 74; school, 10
#> Fixed Effects:
#> (Intercept)  
#>       50.27
```

## Crossed random effects

Crossed random effects appear when two (or more) variables can be used
to create distinct groupings. Think about factories and products where a
factory can produce a range of products, and a product can be
manufactured in different factories. The contigency matrix of such a
design is shown in the next figure.

``` r
n_factory <- 10
n_product <- 10
mean_n_sample <- 5

factories <- expand.grid(
  factory = seq_len(n_factory),
  product = seq_len(n_product)
) %>%
  mutate(
    samples = rpois(n(), mean_n_sample)
  ) %>%
  group_by(factory, product) %>%
  do(
    sample = data_frame(sample = seq_len(.$samples))
  ) %>%
  unnest(sample) %>%
  mutate(
    sample2 = interaction(factory, product, sample, drop = TRUE)
  )
```

`factories` contains 3 design variables: `factory`, `product` and
`sample`. Most of the `factory` and `product` combinations are present
in the data and they are meaningfull. Product 1 in factory 1 is the same
product as product 1 in factory 2.

    {{< htmlwidget "2017-07-18-nested-and-crossed-random-effects-in-lme4-crossed-unnamed-chunk-5" 50.000000 >}}

``` r
with(factories, table(product, factory)) %>%
  image(
    col = grey.colors(10, start = 1, end = 0), 
    axes = FALSE, 
    xlab = "Product", 
    ylab = "Factory"
  )
```

<img src="../../../post/2017-07-18-nested-and-crossed-random-effects-in-lme4_files/figure-gfm/factory-design-1.svg" title="Contingency matrix for the `factories`data set" alt="Contingency matrix for the `factories`data set" width="672" style="display: block; margin: auto;" />

``` r
factory_sd <- 3
product_sd <- 2
noise_sd <- 1
intercept <- 50

factory_effect <- rnorm(n_factory, mean = 0, sd = factory_sd)
product_effect <- rnorm(n_product, mean = 0, sd = product_sd)
factories <- factories %>%
  mutate(
    mu = intercept + factory_effect[factory] + product_effect[product],
    y = mu + rnorm(n(), mean = 0, sd = noise_sd)
  )
```

### Coding

The coding for crossed random effects is easy: `(1|A) + (1|B) + (1|C)`.

``` r
lmer(y ~ (1|factory) + (1|product), data = factories)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: y ~ (1 | factory) + (1 | product)
#>    Data: factories
#> REML criterion at convergence: 1461.96
#> Random effects:
#>  Groups   Name        Std.Dev.
#>  factory  (Intercept) 2.8210  
#>  product  (Intercept) 1.6837  
#>  Residual             0.9957  
#> Number of obs: 481, groups:  factory, 10; product, 10
#> Fixed Effects:
#> (Intercept)  
#>       49.36
```

## Recommendations

-   each level of a random effect should be defined by a single
    variable: e.g. `class2` and `student2` in `schools`; `factory`,
    `product` and `sample2` in `factories`
-   use explict nesting even when the data set would allow implicit
    nesting
-   don’t use the shorthand nesting

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
#>  package     * version  date       lib source        
#>  assertthat    0.2.1    2019-03-21 [1] CRAN (R 4.1.0)
#>  backports     1.2.1    2020-12-09 [1] CRAN (R 4.1.0)
#>  boot          1.3-28   2021-05-03 [1] CRAN (R 4.1.0)
#>  broom         0.7.9    2021-07-27 [1] CRAN (R 4.1.1)
#>  cellranger    1.1.0    2016-07-27 [1] CRAN (R 4.1.0)
#>  cli           3.0.1    2021-07-17 [1] CRAN (R 4.1.1)
#>  colorspace    2.0-2    2021-06-24 [1] CRAN (R 4.1.0)
#>  crayon        1.4.1    2021-02-08 [1] CRAN (R 4.1.0)
#>  DBI           1.1.1    2021-01-15 [1] CRAN (R 4.1.0)
#>  dbplyr        2.1.1    2021-04-06 [1] CRAN (R 4.1.0)
#>  digest        0.6.27   2020-10-24 [1] CRAN (R 4.1.0)
#>  dplyr       * 1.0.7    2021-06-18 [1] CRAN (R 4.1.0)
#>  DT          * 0.18     2021-04-14 [1] CRAN (R 4.1.0)
#>  ellipsis      0.3.2    2021-04-29 [1] CRAN (R 4.1.0)
#>  evaluate      0.14     2019-05-28 [1] CRAN (R 4.1.0)
#>  fansi         0.5.0    2021-05-25 [1] CRAN (R 4.1.0)
#>  fastmap       1.1.0    2021-01-25 [1] CRAN (R 4.1.0)
#>  forcats     * 0.5.1    2021-01-27 [1] CRAN (R 4.1.0)
#>  fs            1.5.0    2020-07-31 [1] CRAN (R 4.1.0)
#>  generics      0.1.0    2020-10-31 [1] CRAN (R 4.1.0)
#>  ggplot2     * 3.3.5    2021-06-25 [1] CRAN (R 4.1.0)
#>  glue          1.4.2    2020-08-27 [1] CRAN (R 4.1.0)
#>  gtable        0.3.0    2019-03-25 [1] CRAN (R 4.1.0)
#>  haven         2.4.3    2021-08-04 [1] CRAN (R 4.1.1)
#>  here        * 1.0.1    2020-12-13 [1] CRAN (R 4.1.0)
#>  hms           1.1.0    2021-05-17 [1] CRAN (R 4.1.0)
#>  htmltools     0.5.2    2021-08-25 [1] CRAN (R 4.1.1)
#>  htmlwidgets   1.5.3    2020-12-10 [1] CRAN (R 4.1.0)
#>  httr          1.4.2    2020-07-20 [1] CRAN (R 4.1.0)
#>  jsonlite      1.7.2    2020-12-09 [1] CRAN (R 4.1.0)
#>  knitr       * 1.33     2021-04-24 [1] CRAN (R 4.1.0)
#>  lattice       0.20-44  2021-05-02 [1] CRAN (R 4.1.0)
#>  lifecycle     1.0.0    2021-02-15 [1] CRAN (R 4.1.0)
#>  lme4        * 1.1-27.1 2021-06-22 [1] CRAN (R 4.1.0)
#>  lubridate     1.7.10   2021-02-26 [1] CRAN (R 4.1.0)
#>  magrittr      2.0.1    2020-11-17 [1] CRAN (R 4.1.0)
#>  MASS          7.3-54   2021-05-03 [1] CRAN (R 4.1.0)
#>  Matrix      * 1.3-4    2021-06-01 [1] CRAN (R 4.1.0)
#>  minqa         1.2.4    2014-10-09 [1] CRAN (R 4.1.0)
#>  modelr        0.1.8    2020-05-19 [1] CRAN (R 4.1.0)
#>  munsell       0.5.0    2018-06-12 [1] CRAN (R 4.1.0)
#>  nlme          3.1-152  2021-02-04 [1] CRAN (R 4.1.0)
#>  nloptr        1.2.2.2  2020-07-02 [1] CRAN (R 4.1.0)
#>  pillar        1.6.2    2021-07-29 [1] CRAN (R 4.1.1)
#>  pkgconfig     2.0.3    2019-09-22 [1] CRAN (R 4.1.0)
#>  purrr       * 0.3.4    2020-04-17 [1] CRAN (R 4.1.0)
#>  R6            2.5.1    2021-08-19 [1] CRAN (R 4.1.1)
#>  Rcpp          1.0.7    2021-07-07 [1] CRAN (R 4.1.0)
#>  readr       * 2.0.1    2021-08-10 [1] CRAN (R 4.1.1)
#>  readxl        1.3.1    2019-03-13 [1] CRAN (R 4.1.0)
#>  reprex        2.0.1    2021-08-05 [1] CRAN (R 4.1.1)
#>  rlang         0.4.11   2021-04-30 [1] CRAN (R 4.1.0)
#>  rmarkdown     2.10     2021-08-06 [1] CRAN (R 4.1.1)
#>  rprojroot     2.0.2    2020-11-15 [1] CRAN (R 4.1.0)
#>  rstudioapi    0.13     2020-11-12 [1] CRAN (R 4.1.0)
#>  rvest         1.0.1    2021-07-26 [1] CRAN (R 4.1.1)
#>  scales        1.1.1    2020-05-11 [1] CRAN (R 4.1.0)
#>  sessioninfo   1.1.1    2018-11-05 [1] CRAN (R 4.1.0)
#>  stringi       1.7.4    2021-08-25 [1] CRAN (R 4.1.1)
#>  stringr     * 1.4.0    2019-02-10 [1] CRAN (R 4.1.0)
#>  tibble      * 3.1.4    2021-08-25 [1] CRAN (R 4.1.1)
#>  tidyr       * 1.1.3    2021-03-03 [1] CRAN (R 4.1.0)
#>  tidyselect    1.1.1    2021-04-30 [1] CRAN (R 4.1.0)
#>  tidyverse   * 1.3.1    2021-04-15 [1] CRAN (R 4.1.0)
#>  tzdb          0.1.2    2021-07-20 [1] CRAN (R 4.1.1)
#>  utf8          1.2.2    2021-07-24 [1] CRAN (R 4.1.1)
#>  vctrs         0.3.8    2021-04-29 [1] CRAN (R 4.1.0)
#>  withr         2.4.2    2021-04-18 [1] CRAN (R 4.1.0)
#>  xfun          0.25     2021-08-06 [1] CRAN (R 4.1.1)
#>  xml2          1.3.2    2020-04-23 [1] CRAN (R 4.1.0)
#>  yaml          2.2.1    2020-02-01 [1] CRAN (R 4.1.0)
#> 
#> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
#> [2] /usr/local/lib/R/site-library
#> [3] /usr/lib/R/site-library
#> [4] /usr/lib/R/library
```
