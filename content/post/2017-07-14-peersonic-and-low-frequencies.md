---
author: Thierry Onkelinx
banner: post/2017-07-14-peersonic-and-low-frequencies_files/figure-html/rec-spec-detail-1.png
categories:
- bats
- tool-review
coverImage: images/peersonic/peersonic_headphones.jpg
date: 2017-07-14
output:
  md_document:
    preserve_yaml: true
    variant: gfm
slug: peersonic-and-low-frequencies
tags:
- peersonic
- bat-detector
- review
thumbnailImagePosition: right
title: Peersonic RPA2 bat detector and low frequencies
---

Recently René Janssen from [Bionet
Natuuronderzoek](http://www.bionetnatuur.eu/) was looking for an
automatic bat-detector which could record sounds starting from 4 kHz.
That was an incentive to put the Peersonic RPA2 to the test.

## Generating a test sound

For this test I needed a file with known frequencies over a given range.
It turns out that creating such a test file is relatively easy with
[R](https://www.r-project.org).

``` r
library(tuneR)
# sample rate of the sound in Hz
# must be at least twice the highest frequency
sample.rate <- 50e3
# duration of the sound in seconds
duration <- 5
# lowest and highest frequency in the sound
sound.freq.range <- c(1e3, 21e3)
# number of steps between the lowest and higest frequency
sound.freq.steps <- 40
# time
t <- seq(0, duration - 1 / sample.rate, by = 1 / sample.rate)
# vector of frequencies
sound.freq <- seq(
  sound.freq.range[1], 
  sound.freq.range[2],
  length = sound.freq.steps
)
# stretch the frequency vector to 1 second
sound.freq <- rep(
  sound.freq,
  each = sample.rate / sound.freq.steps
)
# amplitude of the sound
u <- (2^15 - 1) * sin(2 * pi * sound.freq * t)
# create Wave object
w <- Wave(u, samp.rate = sample.rate, bit = 16)
# save Wave object to wav file
writeWave(w, "test.wav")
```

## Play and record the test sound

![Test setup with RPA2
detector.](/images/peersonic/peersonic_headphones.jpg) Now I have a file
[test.wav](/post/test.wav) which has sounds ranging from 1kHz up to
21kHz. I played this file using [Audacity](http://www.audacityteam.org/)
on a [Ubuntu](https://www.ubuntu.com) laptop. The laptop speakers failed
to play sounds above 15 kHz, so I tried my [Philips SHB9850NC
headphones](http://www.philips.co.uk/c-p/SHB9850NC_00/wireless-noise-cancelling-headphones).
Some testing revealable that I was able to hear sounds up to 22,5 kHz.
I’m not sure whether the headphones, my ears or both failed at higher
frequencies ;-) So I placed the headphones over the Peersonic RPA2 as
show in the photo. Then the Peersonic was set in `auto record` mode with
a threshold of `-30dB` and a maximum file length of `20` seconds. The
volume on the laptop was set about half way. Then I played the test file
several times.

## Comparison of the original test file and the recording

Let’s first look at the spectrogram of the [test file](/post/test.wav).
Again, something which it not that hard with
[R](https://www.r-project.org)

``` r
truth <- readWave("test.wav")@left
library(signal)
window.n <- 1024
truth_spec <- specgram(
  x = truth,
  n = window.n,
  Fs = sample.rate,
  overlap = ceiling(0.9 * window.n)
)
plot(truth_spec, col = rainbow(10))
```

<img src="../../../post/2017-07-14-peersonic-and-low-frequencies_files/figure-gfm/truth-spec-1.png" title="Spectrogram of the generated test file" alt="Spectrogram of the generated test file" width="672" style="display: block; margin: auto;" />

Then do the same thing with the file
[A013_AMS.WAV](/data/test_peersonic/A013_AMS.WAV) as recorded by the
Peersonic RPA2. The Peersonic RPA2 records multiple of 5 seconds, hence
the silence a the end. Note that the test file did not contain
frenquencies above 21kHz. The noise around 32kHz is probably due to the
fan of my laptop.

``` r
recording <- readWave(
  "../../static/data/test_peersonic/A013_AMS.WAV", to = 5 * 384e3
)
window.n <- 1024
record_spec <- specgram(
  x = recording@left,
  n = window.n,
  Fs = recording@samp.rate,
  overlap = ceiling(0.9 * window.n)
)
plot(record_spec, col = rainbow(10))
```

<img src="../../../post/2017-07-14-peersonic-and-low-frequencies_files/figure-gfm/rec-spec-full-1.png" title="Complete spectrogram of the recorded test file" alt="Complete spectrogram of the recorded test file" width="672" style="display: block; margin: auto;" />

I’ve zoomed into to the revelant section of the recording: the first 5
seconds and from 0kHz up to 30kHz. The Peersonic RPA2 seems to record
sounds as low as 21kHz. The sensitivy of the microphone seems to be a
bit lower under 5kHz.

``` r
plot(record_spec, col = rainbow(10), xlim = c(0, 5), ylim = c(0, 30e3))
```

<img src="../../../post/2017-07-14-peersonic-and-low-frequencies_files/figure-gfm/rec-spec-detail-1.png" title="Detail of the spectrogram of the recorded test file" alt="Detail of the spectrogram of the recorded test file" width="672" style="display: block; margin: auto;" />

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
#>  cli           3.0.1   2021-07-17 [1] CRAN (R 4.1.1)
#>  codetools     0.2-18  2020-11-04 [1] CRAN (R 4.1.0)
#>  digest        0.6.27  2020-10-24 [1] CRAN (R 4.1.0)
#>  evaluate      0.14    2019-05-28 [1] CRAN (R 4.1.0)
#>  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.1.0)
#>  here        * 1.0.1   2020-12-13 [1] CRAN (R 4.1.0)
#>  highr         0.9     2021-04-16 [1] CRAN (R 4.1.0)
#>  htmltools     0.5.2   2021-08-25 [1] CRAN (R 4.1.1)
#>  knitr       * 1.33    2021-04-24 [1] CRAN (R 4.1.0)
#>  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.1.0)
#>  MASS          7.3-54  2021-05-03 [1] CRAN (R 4.1.0)
#>  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.1.0)
#>  rmarkdown     2.10    2021-08-06 [1] CRAN (R 4.1.1)
#>  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.1.0)
#>  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.1.0)
#>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.1.0)
#>  signal      * 0.7-7   2021-05-25 [1] CRAN (R 4.1.0)
#>  stringi       1.7.4   2021-08-25 [1] CRAN (R 4.1.1)
#>  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.1.0)
#>  tuneR       * 1.3.3.1 2021-08-04 [1] CRAN (R 4.1.1)
#>  withr         2.4.2   2021-04-18 [1] CRAN (R 4.1.0)
#>  xfun          0.25    2021-08-06 [1] CRAN (R 4.1.1)
#>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.1.0)
#> 
#> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
#> [2] /usr/local/lib/R/site-library
#> [3] /usr/lib/R/site-library
#> [4] /usr/lib/R/library
```
