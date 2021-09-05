---
author: Thierry Onkelinx
categories:
- statistics
- mixed-models
date: 2017-08-23
output:
  md_document:
    preserve_yaml: true
    variant: gfm
slug: fixed-and-random
tags:
- lme4
- INLA
title: Using a variable both as fixed and random effect
---

One of the questions to answer when using mixed models is whether to use
a variable as a fixed effect or as a random effect. Sometimes it makes
sense to use a variable both as fixed and random effect. In this post I
will try to make clear in which cases it can make sense and what are the
benefits of doing so. I will also handle cases in which it doesn’t make
sense. Much will depend on the nature of the variable. Therefore this
post is split into three sections: categorical, discrete and continuous.
I will only display the most relevant parts of the code. The full code
is available on [GitHub](https:/github.com/thierryo/my_blog).

# Categorical variable

To make this clear, we start by creating a dummy dataset with 3
categorical covariates. `B` is nested within `A`. The resulting dataset
is displayed in [fig 1](#cat-dummy).

``` r
library(tidyverse)
library(lme4)
library(INLA)
```

``` r
n_a <- 6
n_b <- 2
n_sample <- 3
sd_A <- 2
sd_B <- 1
sd_noise <- 1
dataset <- expand.grid(
  B = paste0("b", seq_len(n_a * n_b)),
  sample = seq_len(n_sample)
) %>%
  mutate(
    A = paste0("a", as.integer(B) %% n_a) %>%
      factor(),
    mu = rnorm(n_a, sd = sd_A)[A] + 
         rnorm(n_a * n_b, sd = sd_B)[B],
    Y = mu + rnorm(n(), sd = sd_noise)
  )
```

<a id="cat-dummy"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/cat-dummy-1.svg" title="Fig 1. Dummy dataset with categorical variables." alt="Fig 1. Dummy dataset with categorical variables." width="672" style="display: block; margin: auto;" />

The first model is one that doesn’t make sense. Using a categorical
variable both as random and a fixed effect. In this case both effects
are competing for the same information. Below is the resulting fit from
`lme4` and `INLA`. Note the warning in the `lme4` output, the model
failed to converge. Nevertheless, both `lme4` and `INLA` yield the same
parameter estimate ([fig. 2](#cat-fixed)), albeit the much wider
confidence intervals for `lme4`. The estimates for the random effects in
both packages are equivalent to zero ([fig. 3](#cat-random)). Again the
`lme4` estimate has more uncertainty.

``` r
model.1 <- lmer(Y ~ 0 + A + (1|A), data = dataset)
#> Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
#> unable to evaluate scaled gradient
#> Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
#> Hessian is numerically singular: parameters are not uniquely determined
summary(model.1)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: Y ~ 0 + A + (1 | A)
#>    Data: dataset
#> 
#> REML criterion at convergence: 119.5
#> 
#> Scaled residuals: 
#>      Min       1Q   Median       3Q      Max 
#> -2.32120 -0.46302 -0.08792  0.59406  2.33634 
#> 
#> Random effects:
#>  Groups   Name        Variance Std.Dev.
#>  A        (Intercept) 0.8865   0.9416  
#>  Residual             2.1955   1.4817  
#> Number of obs: 36, groups:  A, 6
#> 
#> Fixed effects:
#>     Estimate Std. Error t value
#> Aa0  -0.7877     1.1191  -0.704
#> Aa1   1.8225     1.1191   1.629
#> Aa2   0.3631     1.1191   0.324
#> Aa3   0.5065     1.1191   0.453
#> Aa4   1.0964     1.1191   0.980
#> Aa5  -0.3170     1.1191  -0.283
#> 
#> Correlation of Fixed Effects:
#>     Aa0   Aa1   Aa2   Aa3   Aa4  
#> Aa1 0.000                        
#> Aa2 0.000 0.000                  
#> Aa3 0.000 0.000 0.000            
#> Aa4 0.000 0.000 0.000 0.000      
#> Aa5 0.000 0.000 0.000 0.000 0.000
#> optimizer (nloptwrap) convergence code: 0 (OK)
#> unable to evaluate scaled gradient
#>  Hessian is numerically singular: parameters are not uniquely determined
model.2 <- inla(Y ~ 0 + A + f(A, model = "iid"), data = dataset)
summary(model.2)
#> 
#> Call:
#>    "inla(formula = Y ~ 0 + A + f(A, model = \"iid\"), data = dataset)" 
#> Time used:
#>     Pre = 2.24, Running = 0.132, Post = 0.0925, Total = 2.47 
#> Fixed effects:
#>       mean    sd 0.025quant 0.5quant 0.975quant   mode kld
#> Aa0 -0.787 0.605     -1.983   -0.787      0.407 -0.787   0
#> Aa1  1.822 0.605      0.626    1.822      3.016  1.822   0
#> Aa2  0.363 0.605     -0.833    0.363      1.557  0.363   0
#> Aa3  0.506 0.605     -0.689    0.506      1.700  0.506   0
#> Aa4  1.096 0.605     -0.100    1.096      2.290  1.096   0
#> Aa5 -0.317 0.605     -1.512   -0.317      0.877 -0.317   0
#> 
#> Random effects:
#>   Name     Model
#>     A IID model
#> 
#> Model hyperparameters:
#>                                             mean       sd 0.025quant 0.5quant
#> Precision for the Gaussian observations 4.85e-01 1.21e-01      0.283 4.73e-01
#> Precision for A                         1.80e+04 1.76e+04   1205.915 1.28e+04
#>                                         0.975quant     mode
#> Precision for the Gaussian observations   7.56e-01    0.452
#> Precision for A                           6.49e+04 3297.308
#> 
#> Expected number of effective parameters(stdev): 6.00(0.001)
#> Number of equivalent replicates : 6.00 
#> 
#> Marginal log-Likelihood:  -97.13
```

<a id="cat-fixed"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/cat-fixed-1.svg" title="Fig 2. Comparison of fixed effects parameters for model `A + (1|A)`" alt="Fig 2. Comparison of fixed effects parameters for model `A + (1|A)`" width="672" style="display: block; margin: auto;" />

<a id="cat-random"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/cat-random-1.svg" title="Fig 3. Comparison of random effects parameters for model `A + (1|A)`" alt="Fig 3. Comparison of random effects parameters for model `A + (1|A)`" width="672" style="display: block; margin: auto;" />

What if we want to add variable `B` as a nested random effect? We
already know that adding `A` to both the fixed and the random effects is
nonsense. The correct way of doing this is to use `A` as a fixed effect
and `B` as an [implicit
nested](../../07/lme4-random-effects/#implicit-nesting) random effect.

``` r
model.1 <- lmer(Y ~ 0 + A + (1|A/B), data = dataset)
summary(model.1)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: Y ~ 0 + A + (1 | A/B)
#>    Data: dataset
#> 
#> REML criterion at convergence: 112.1
#> 
#> Scaled residuals: 
#>      Min       1Q   Median       3Q      Max 
#> -2.21547 -0.53865  0.02101  0.54988  1.62903 
#> 
#> Random effects:
#>  Groups   Name        Variance Std.Dev.
#>  B:A      (Intercept) 1.560    1.249   
#>  A        (Intercept) 9.355    3.059   
#>  Residual             1.259    1.122   
#> Number of obs: 36, groups:  B:A, 12; A, 6
#> 
#> Fixed effects:
#>     Estimate Std. Error t value
#> Aa0  -0.7877     3.2163  -0.245
#> Aa1   1.8225     3.2163   0.567
#> Aa2   0.3631     3.2163   0.113
#> Aa3   0.5065     3.2163   0.157
#> Aa4   1.0964     3.2163   0.341
#> Aa5  -0.3170     3.2163  -0.099
#> 
#> Correlation of Fixed Effects:
#>     Aa0   Aa1   Aa2   Aa3   Aa4  
#> Aa1 0.000                        
#> Aa2 0.000 0.000                  
#> Aa3 0.000 0.000 0.000            
#> Aa4 0.000 0.000 0.000 0.000      
#> Aa5 0.000 0.000 0.000 0.000 0.000
model.1b <- lmer(Y ~ 0 + A + (1|B), data = dataset)
summary(model.1b)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: Y ~ 0 + A + (1 | B)
#>    Data: dataset
#> 
#> REML criterion at convergence: 112.1
#> 
#> Scaled residuals: 
#>      Min       1Q   Median       3Q      Max 
#> -2.21548 -0.53865  0.02101  0.54988  1.62904 
#> 
#> Random effects:
#>  Groups   Name        Variance Std.Dev.
#>  B        (Intercept) 1.560    1.249   
#>  Residual             1.259    1.122   
#> Number of obs: 36, groups:  B, 12
#> 
#> Fixed effects:
#>     Estimate Std. Error t value
#> Aa0  -0.7877     0.9950  -0.792
#> Aa1   1.8225     0.9950   1.832
#> Aa2   0.3631     0.9950   0.365
#> Aa3   0.5065     0.9950   0.509
#> Aa4   1.0964     0.9950   1.102
#> Aa5  -0.3170     0.9950  -0.319
#> 
#> Correlation of Fixed Effects:
#>     Aa0   Aa1   Aa2   Aa3   Aa4  
#> Aa1 0.000                        
#> Aa2 0.000 0.000                  
#> Aa3 0.000 0.000 0.000            
#> Aa4 0.000 0.000 0.000 0.000      
#> Aa5 0.000 0.000 0.000 0.000 0.000
model.2 <- inla(
  Y ~ 0 + A + f(A, model = "iid") + f(B, model = "iid"), 
  data = dataset
)
summary(model.2)
#> 
#> Call:
#>    c("inla(formula = Y ~ 0 + A + f(A, model = \"iid\") + f(B, model = 
#>    \"iid\"), ", " data = dataset)") 
#> Time used:
#>     Pre = 2.76, Running = 0.116, Post = 0.089, Total = 2.97 
#> Fixed effects:
#>       mean    sd 0.025quant 0.5quant 0.975quant   mode kld
#> Aa0 -0.787 0.887     -2.575   -0.787      1.002 -0.787   0
#> Aa1  1.821 0.887      0.032    1.821      3.609  1.822   0
#> Aa2  0.363 0.887     -1.426    0.363      2.152  0.363   0
#> Aa3  0.506 0.887     -1.282    0.506      2.295  0.506   0
#> Aa4  1.095 0.887     -0.693    1.096      2.884  1.096   0
#> Aa5 -0.317 0.887     -2.105   -0.317      1.472 -0.317   0
#> 
#> Random effects:
#>   Name     Model
#>     A IID model
#>    B IID model
#> 
#> Model hyperparameters:
#>                                             mean       sd 0.025quant 0.5quant
#> Precision for the Gaussian observations 8.34e-01 2.43e-01      0.439 8.07e-01
#> Precision for A                         1.86e+04 1.81e+04   1238.589 1.33e+04
#> Precision for B                         2.12e+00 2.75e+00      0.275 1.30e+00
#>                                         0.975quant     mode
#> Precision for the Gaussian observations       1.39    0.756
#> Precision for A                           66970.04 3376.729
#> Precision for B                               8.98    0.630
#> 
#> Expected number of effective parameters(stdev): 9.75(1.35)
#> Number of equivalent replicates : 3.69 
#> 
#> Marginal log-Likelihood:  -102.32
model.2b <- inla(Y ~ 0 + A + f(B, model = "iid"), data = dataset)
summary(model.2b)
#> 
#> Call:
#>    "inla(formula = Y ~ 0 + A + f(B, model = \"iid\"), data = dataset)" 
#> Time used:
#>     Pre = 1.89, Running = 0.243, Post = 0.0813, Total = 2.22 
#> Fixed effects:
#>       mean    sd 0.025quant 0.5quant 0.975quant   mode kld
#> Aa0 -0.787 0.644     -2.056   -0.787      0.480 -0.787   0
#> Aa1  1.822 0.644      0.553    1.822      3.089  1.822   0
#> Aa2  0.363 0.644     -0.905    0.363      1.631  0.363   0
#> Aa3  0.506 0.644     -0.762    0.506      1.774  0.506   0
#> Aa4  1.096 0.644     -0.172    1.096      2.363  1.096   0
#> Aa5 -0.317 0.644     -1.585   -0.317      0.951 -0.317   0
#> 
#> Random effects:
#>   Name     Model
#>     B IID model
#> 
#> Model hyperparameters:
#>                                          mean    sd 0.025quant 0.5quant
#> Precision for the Gaussian observations 0.831 0.243      0.439    0.804
#> Precision for B                         2.182 2.891      0.273    1.321
#>                                         0.975quant  mode
#> Precision for the Gaussian observations       1.39 0.752
#> Precision for B                               9.36 0.631
#> 
#> Expected number of effective parameters(stdev): 6.04(0.403)
#> Number of equivalent replicates : 5.96 
#> 
#> Marginal log-Likelihood:  -102.22
```

# Discrete variable

## Intro

A discrete variable is a numerical variable but each interval between
two values is an integer multiple of a fixed step size. Typical examples
are related to time, e.g. the year in steps of 1 year, months expressed
in terms of years (step size 1/12), …

We create a new dummy dataset with a discrete variable. The response
variable is a third order polynomial of the discrete variable. The `X`
variable is rescaled to -1 and 1.

``` r
n_x <- 25
n_sample <- 10
sd_noise <- 10
dataset <- expand.grid(
  X = seq_len(n_x),
  sample = seq_len(n_sample)
) %>%
  mutate(
    mu =  0.045 * X ^ 3 - X ^ 2 + 10,
    Y = mu + rnorm(n(), sd = sd_noise),
    X = (X - ceiling(n_x / 2)) / floor(n_x / 2)
  )
```

<a id="discrete-dummy"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/discrete-dummy-1.svg" title="Fig 4. Dummy dataset with a discrete variable. The line represents the true model." alt="Fig 4. Dummy dataset with a discrete variable. The line represents the true model." width="672" style="display: block; margin: auto;" />

## Fit with `lme4`

Suppose we fit a simple linear model to the data. We know that this is
not accurate because the real pattern is a third order polynomial. And
let’s add the variable also as a random effect. We use first `lme4` to
illustrate the principle. [Fig 5](#discrete-fit) illustrate how the fit
of the fixed part is poor but the random effect of X compensates the
fit.

``` r
model.1 <- lmer(Y ~ X + (1|X), data = dataset)
summary(model.1)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: Y ~ X + (1 | X)
#>    Data: dataset
#> 
#> REML criterion at convergence: 1991
#> 
#> Scaled residuals: 
#>      Min       1Q   Median       3Q      Max 
#> -2.88813 -0.63759  0.01828  0.64130  2.57447 
#> 
#> Random effects:
#>  Groups   Name        Variance Std.Dev.
#>  X        (Intercept) 1583.7   39.80   
#>  Residual              108.6   10.42   
#> Number of obs: 250, groups:  X, 25
#> 
#> Fixed effects:
#>             Estimate Std. Error t value
#> (Intercept)  -20.928      7.986  -2.620
#> X             12.944     13.290   0.974
#> 
#> Correlation of Fixed Effects:
#>   (Intr)
#> X 0.000
```

<a id="discrete-fit"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/discrete-fit-1.svg" title="Fig 5. Fitted values (line) and observed values (points) from the lme4 model." alt="Fig 5. Fitted values (line) and observed values (points) from the lme4 model." width="672" style="display: block; margin: auto;" />

The overall model fit improves when we add a second and third polynomial
term. And the variance of the random effect decreases. It reduces even
to zero once the third polynomial is in the model. [Fig
6](#discrete-fit2) illustrates how the fit of the fixed effect improves
when adding the higher order terms. The effect on the fitted values with
the random effect is marginal.

``` r
model.1b <- lmer(Y ~ X + I(X ^ 2) + (1|X), data = dataset)
model.1c <- lmer(Y ~ X + I(X ^ 2) + I(X ^ 3) + (1|X), data = dataset)
anova(model.1, model.1b, model.1c)
#> Data: dataset
#> Models:
#> model.1: Y ~ X + (1 | X)
#> model.1b: Y ~ X + I(X^2) + (1 | X)
#> model.1c: Y ~ X + I(X^2) + I(X^3) + (1 | X)
#>          npar    AIC    BIC   logLik deviance  Chisq Df Pr(>Chisq)    
#> model.1     4 2012.0 2026.0 -1001.98   2004.0                         
#> model.1b    5 1962.3 1979.9  -976.15   1952.3 51.652  1  6.627e-13 ***
#> model.1c    6 1895.3 1916.4  -941.63   1883.3 69.031  1  < 2.2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
summary(model.1b)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: Y ~ X + I(X^2) + (1 | X)
#>    Data: dataset
#> 
#> REML criterion at convergence: 1937.3
#> 
#> Scaled residuals: 
#>      Min       1Q   Median       3Q      Max 
#> -2.82263 -0.62115  0.01319  0.67726  2.57349 
#> 
#> Random effects:
#>  Groups   Name        Variance Std.Dev.
#>  X        (Intercept) 200.3    14.15   
#>  Residual             108.6    10.42   
#> Number of obs: 250, groups:  X, 25
#> 
#> Fixed effects:
#>             Estimate Std. Error t value
#> (Intercept)  -61.042      4.365 -13.983
#> X             12.944      4.837   2.676
#> I(X^2)       111.085      9.020  12.315
#> 
#> Correlation of Fixed Effects:
#>        (Intr) X     
#> X       0.000       
#> I(X^2) -0.746  0.000
summary(model.1c)
#> Linear mixed model fit by REML ['lmerMod']
#> Formula: Y ~ X + I(X^2) + I(X^3) + (1 | X)
#>    Data: dataset
#> 
#> REML criterion at convergence: 1871.8
#> 
#> Scaled residuals: 
#>     Min      1Q  Median      3Q     Max 
#> -3.0403 -0.6288  0.1281  0.6298  2.5672 
#> 
#> Random effects:
#>  Groups   Name        Variance Std.Dev.
#>  X        (Intercept)   3.129   1.769  
#>  Residual             108.561  10.419  
#> Number of obs: 250, groups:  X, 25
#> 
#> Fixed effects:
#>             Estimate Std. Error t value
#> (Intercept)  -61.042      1.123  -54.34
#> X            -37.704      3.129  -12.05
#> I(X^2)       111.085      2.321   47.86
#> I(X^3)        78.088      4.426   17.64
#> 
#> Correlation of Fixed Effects:
#>        (Intr) X      I(X^2)
#> X       0.000              
#> I(X^2) -0.746  0.000       
#> I(X^3)  0.000 -0.917  0.000
```

<a id="discrete-fit2"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/discrete-fit2-1.svg" title="Fig 6. Fitted values from the fixed and random part of the `lme4` models. Points represent the true model." alt="Fig 6. Fitted values from the fixed and random part of the `lme4` models. Points represent the true model." width="672" style="display: block; margin: auto;" />

## Fit with `INLA`

`INLA` requires that we alter the data to get the same output. First we
copy `X` into `X.copy` because `inla` allows the variable to be used
only once in the formula. For some reason this wasn’t needed with the
categorical variables. The `lme4` syntax `X + (1|X)` translates into the
following `INLA` syntax: `X + f(X.copy, model = "iid")`. Then next thing
is that `INLA` does the model fitting and prediction in a single step.
Getting predictions for new data requires to add the new data to the
original data while setting the response to `NA`. If we want predictions
for the fixed effect only, then we need to add rows were all random
effect covariates are set to `NA`. Hence `X.copy` must be `NA` while `X`
must be non `NA`. Note that this would be impossible without creating
`X.copy`.

Let’s fit the three same models with `INLA`. The predictions are given
in [fig 7](#discrete-fit3). The results are very similar to the `lme4`
results.

``` r
dataset2 <- dataset %>%
  mutate(X.copy = X) %>%
  bind_rows(
    dataset %>%
      distinct(X, mu)
  )
```

``` r
model.2 <- inla(
  Y ~ X + f(X.copy, model = "iid"), 
  data = dataset2, 
  control.compute = list(waic = TRUE)
)
model.2b <- inla(
  Y ~ X + I(X ^ 2) + f(X.copy, model = "iid"), 
  data = dataset2, 
  control.compute = list(waic = TRUE)
)
model.2c <- inla(
  Y ~ X + I(X ^ 2) + I(X ^ 3) + f(X.copy, model = "iid"), 
  data = dataset2, 
  control.compute = list(waic = TRUE)
)
```

<a id="discrete-fit3"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/discrete-fit3-1.svg" title="Fig 7. Fitted values from the fixed and random part of the `INLA` models. Points represent the true model." alt="Fig 7. Fitted values from the fixed and random part of the `INLA` models. Points represent the true model." width="672" style="display: block; margin: auto;" />

# Continuous variable

A continuous variable is a numeric variable where there is not fixed
step size between two values. In practice the step size will be several
magnitudes smaller than the measured values. Again let’s clarify this
with an example dataset. For the sake of simplicity we’ll reuse the true
model from the example with the discrete variable. Compare [fig
8](#continuous-dummy) with [fig 4](#discrete-dummy) and you’ll see that
[fig 8](#continuous-dummy) has no step size while [fig
4](#discrete-dummy) does.

``` r
n_x <- 25
n_sample <- 10
sd_noise <- 10
dataset <- data.frame(
  X = runif(n_x * n_sample, min = 1, max = n_x)
) %>%
  mutate(
    mu =  0.045 * X ^ 3 - X ^ 2 + 10,
    Y = mu + rnorm(n(), sd = sd_noise),
    X = (X - ceiling(n_x / 2)) / floor(n_x / 2),
    X.copy = X
  )
```

<a id="continuous-dummy"></a>
<img src="../../../post/2017-08-22-using-a-variable-both-as-fixed-and-random-effect_files/figure-gfm/continuous-dummy-1.svg" title="Fig 8. Dummy dataset with a continuous variable. The line represents the true model." alt="Fig 8. Dummy dataset with a continuous variable. The line represents the true model." width="672" style="display: block; margin: auto;" />

The `lmer` model fails because the random effect has as many unique
values as observations.

``` r
tryCatch(
  lmer(Y ~ X + (1|X), data = dataset),
  error = function(e){e}
)
#> <simpleError: number of levels of each grouping factor must be < number of observations (problems: X)>
```

The `INLA` model yields output but the variance of the random effect is
very high. A good indicator that there is something wrong.

``` r
model.2 <- inla(
  Y ~ X + f(X.copy, model = "iid"), 
  data = dataset, 
  control.compute = list(waic = TRUE)
)
inla.tmarginal(
  function(x){x^-1}, 
  model.2$marginals.hyperpar$`Precision for X.copy`
) %>%
  inla.zmarginal()
#> Mean            1394.7 
#> Stdev           124.306 
#> Quantile  0.025 1165.73 
#> Quantile  0.25  1307.76 
#> Quantile  0.5   1389.25 
#> Quantile  0.75  1475.47 
#> Quantile  0.975 1653.44
```

## Conclusion

-   Using a variable both in the fixed and random part of the model
    makes only sense in case of a discrete variable.

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
#>  package      * version    date       lib source        
#>  assertthat     0.2.1      2019-03-21 [1] CRAN (R 4.1.0)
#>  backports      1.2.1      2020-12-09 [1] CRAN (R 4.1.0)
#>  boot           1.3-28     2021-05-03 [1] CRAN (R 4.1.0)
#>  broom          0.7.9      2021-07-27 [1] CRAN (R 4.1.1)
#>  cellranger     1.1.0      2016-07-27 [1] CRAN (R 4.1.0)
#>  cli            3.0.1      2021-07-17 [1] CRAN (R 4.1.1)
#>  codetools      0.2-18     2020-11-04 [1] CRAN (R 4.1.0)
#>  colorspace     2.0-2      2021-06-24 [1] CRAN (R 4.1.0)
#>  crayon         1.4.1      2021-02-08 [1] CRAN (R 4.1.0)
#>  DBI            1.1.1      2021-01-15 [1] CRAN (R 4.1.0)
#>  dbplyr         2.1.1      2021-04-06 [1] CRAN (R 4.1.0)
#>  digest         0.6.27     2020-10-24 [1] CRAN (R 4.1.0)
#>  dplyr        * 1.0.7      2021-06-18 [1] CRAN (R 4.1.0)
#>  ellipsis       0.3.2      2021-04-29 [1] CRAN (R 4.1.0)
#>  evaluate       0.14       2019-05-28 [1] CRAN (R 4.1.0)
#>  fansi          0.5.0      2021-05-25 [1] CRAN (R 4.1.0)
#>  farver         2.1.0      2021-02-28 [1] CRAN (R 4.1.0)
#>  fastmap        1.1.0      2021-01-25 [1] CRAN (R 4.1.0)
#>  forcats      * 0.5.1      2021-01-27 [1] CRAN (R 4.1.0)
#>  foreach      * 1.5.1      2020-10-15 [1] CRAN (R 4.1.0)
#>  fs             1.5.0      2020-07-31 [1] CRAN (R 4.1.0)
#>  generics       0.1.0      2020-10-31 [1] CRAN (R 4.1.0)
#>  ggplot2      * 3.3.5      2021-06-25 [1] CRAN (R 4.1.0)
#>  glue           1.4.2      2020-08-27 [1] CRAN (R 4.1.0)
#>  gtable         0.3.0      2019-03-25 [1] CRAN (R 4.1.0)
#>  haven          2.4.3      2021-08-04 [1] CRAN (R 4.1.1)
#>  here         * 1.0.1      2020-12-13 [1] CRAN (R 4.1.0)
#>  highr          0.9        2021-04-16 [1] CRAN (R 4.1.0)
#>  hms            1.1.0      2021-05-17 [1] CRAN (R 4.1.0)
#>  htmltools      0.5.2      2021-08-25 [1] CRAN (R 4.1.1)
#>  httr           1.4.2      2020-07-20 [1] CRAN (R 4.1.0)
#>  INLA         * 21.02.23   2021-05-29 [1] local         
#>  iterators      1.0.13     2020-10-15 [1] CRAN (R 4.1.0)
#>  jsonlite       1.7.2      2020-12-09 [1] CRAN (R 4.1.0)
#>  knitr        * 1.33       2021-04-24 [1] CRAN (R 4.1.0)
#>  labeling       0.4.2      2020-10-20 [1] CRAN (R 4.1.0)
#>  lattice        0.20-44    2021-05-02 [1] CRAN (R 4.1.0)
#>  lifecycle      1.0.0      2021-02-15 [1] CRAN (R 4.1.0)
#>  lme4         * 1.1-27.1   2021-06-22 [1] CRAN (R 4.1.0)
#>  lubridate      1.7.10     2021-02-26 [1] CRAN (R 4.1.0)
#>  magrittr       2.0.1      2020-11-17 [1] CRAN (R 4.1.0)
#>  MASS           7.3-54     2021-05-03 [1] CRAN (R 4.1.0)
#>  Matrix       * 1.3-4      2021-06-01 [1] CRAN (R 4.1.0)
#>  MatrixModels   0.5-0      2021-03-02 [1] CRAN (R 4.1.0)
#>  minqa          1.2.4      2014-10-09 [1] CRAN (R 4.1.0)
#>  modelr         0.1.8      2020-05-19 [1] CRAN (R 4.1.0)
#>  munsell        0.5.0      2018-06-12 [1] CRAN (R 4.1.0)
#>  nlme           3.1-152    2021-02-04 [1] CRAN (R 4.1.0)
#>  nloptr         1.2.2.2    2020-07-02 [1] CRAN (R 4.1.0)
#>  numDeriv       2016.8-1.1 2019-06-06 [1] CRAN (R 4.1.0)
#>  pillar         1.6.2      2021-07-29 [1] CRAN (R 4.1.1)
#>  pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.1.0)
#>  purrr        * 0.3.4      2020-04-17 [1] CRAN (R 4.1.0)
#>  R6             2.5.1      2021-08-19 [1] CRAN (R 4.1.1)
#>  Rcpp           1.0.7      2021-07-07 [1] CRAN (R 4.1.0)
#>  readr        * 2.0.1      2021-08-10 [1] CRAN (R 4.1.1)
#>  readxl         1.3.1      2019-03-13 [1] CRAN (R 4.1.0)
#>  reprex         2.0.1      2021-08-05 [1] CRAN (R 4.1.1)
#>  rlang          0.4.11     2021-04-30 [1] CRAN (R 4.1.0)
#>  rmarkdown      2.10       2021-08-06 [1] CRAN (R 4.1.1)
#>  rprojroot      2.0.2      2020-11-15 [1] CRAN (R 4.1.0)
#>  rstudioapi     0.13       2020-11-12 [1] CRAN (R 4.1.0)
#>  rvest          1.0.1      2021-07-26 [1] CRAN (R 4.1.1)
#>  scales         1.1.1      2020-05-11 [1] CRAN (R 4.1.0)
#>  sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 4.1.0)
#>  sp           * 1.4-5      2021-01-10 [1] CRAN (R 4.1.0)
#>  stringi        1.7.4      2021-08-25 [1] CRAN (R 4.1.1)
#>  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 4.1.0)
#>  tibble       * 3.1.4      2021-08-25 [1] CRAN (R 4.1.1)
#>  tidyr        * 1.1.3      2021-03-03 [1] CRAN (R 4.1.0)
#>  tidyselect     1.1.1      2021-04-30 [1] CRAN (R 4.1.0)
#>  tidyverse    * 1.3.1      2021-04-15 [1] CRAN (R 4.1.0)
#>  tzdb           0.1.2      2021-07-20 [1] CRAN (R 4.1.1)
#>  utf8           1.2.2      2021-07-24 [1] CRAN (R 4.1.1)
#>  vctrs          0.3.8      2021-04-29 [1] CRAN (R 4.1.0)
#>  withr          2.4.2      2021-04-18 [1] CRAN (R 4.1.0)
#>  xfun           0.25       2021-08-06 [1] CRAN (R 4.1.1)
#>  xml2           1.3.2      2020-04-23 [1] CRAN (R 4.1.0)
#>  yaml           2.2.1      2020-02-01 [1] CRAN (R 4.1.0)
#> 
#> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
#> [2] /usr/local/lib/R/site-library
#> [3] /usr/lib/R/site-library
#> [4] /usr/lib/R/library
```
