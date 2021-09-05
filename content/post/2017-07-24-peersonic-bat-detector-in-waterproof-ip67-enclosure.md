---
author: Thierry Onkelinx
categories:
- bats
- tool review
coverImage: images/peersonic/peersonic_ip67_setup.jpg
date: 2017-07-29
output:
  md_document:
    preserve_yaml: true
    variant: gfm
slug: peersonic-ip67
tags:
- bat-detector
- peersonic
- review
thumbnailImagePosition: left
title: Peersonic bat-detector in waterproof IP67 enclosure
---

I’ve reviewed the [standard version](http://peersonic.co.uk) the
Peersonic RPA2 bat-detector in an [earlier blog
post](../../06/peersonic). Today I will take about the RPA2 in a
[waterproof IP67 enclosure](http://peersonic.co.uk/advanced/) and my
experiences on using it as on autonomous bat-detector.

## The differences

The most obvious difference between both versions is their enclosure.
[IP 67](https://en.wikipedia.org/wiki/IP_Code) stands for dust tight and
water tight under immersion up to 1 m depth. As you can see on the
figure, the display and all controls are inside the enclosure. Hence
this version is only relevant in automatic mode.

The enclosure is much larger than the standard version: 180 mm long, 125
mm wide and 90 mm thick (standard version: 145 mm long, 79 mm wide and
37 mm thick). The enclosure holds 3 D cell batteries compared to 3 AA
batteries in the standard version. I had the set-up running for 5
consecutive nights on a single set of alkaline batteries and the
detector was still running.

![Open RPA2 detector in IP67
version.](/images/peersonic/peersonic_ip67_open.jpg)

One essential part of the electronics must be outside of the enclosure:
the microphone. A standard 3.5 mm audio jack cable protrudes from the
enclosure. Mine has 3 m cable but you can order them with different
lengths of cable. Note that about 20 cm of the cable is inside the
enclosure. The jack cable is plugged into the external microphone. This
is also waterproof. The microphone itself is protected by a membrane.
Several replacement membranes were supplied with the detector. So far
I’m still using the original membrane. The microphone has a tripod
thread for easy mounting on a tripod.

![](/images/peersonic/peersonic_ip67_mic.jpg)

The IP67 enclosure has 2 LED’s that blink when batteries are mounted in
the detector. One amber LED is situated inside the enclosure. A green
LED is located on the outside near the exit of the audio cable. The LED
makes visible that the batteries still have enough power without having
to open the enclosure. The downside is that it make the enclosure more
visible and potentially draws unwanted attention. Therefore the external
LED can be switched off by flipping a switch on the print plate.

![](/images/peersonic/peersonic_ip67_closed.jpg)

## The similarities

The electronics hardware and software in both versions are identical.
The controls are at the same location so switching to the other version
is easy. [Peersonic](http://peersonic.co.uk) suggested to switch off the
audio output. Audio output it not needed in automatic mode. Removing the
audio output saves (a little bit of) power. Another option is the leave
the audio output intake and place a Bluetooth audio transmitter in the
enclosure so you can listen to the detector with a pair of Bluetooth
headphones. This would however increase the power consumption. So I
choose to have the audio output removed. Note that it can be replaced if
I wanted so.

## Recording in automatic mode

The user has to specify two settings in automatic mode: 1) the threshold
and 2) the maximal length of a recording. Sounds exceeding the threshold
level triggers the start of a recording. Each recording will last at
least 5 seconds. The recording will continue as long as the sound level
exceeds the threshold and the maximal length isn’t reached. The maximal
length can be set from 5 seconds to 4 minutes in steps of 5 seconds.
Setting the threshold is a bit trial and error. Set it too high and
you’ll missing a lot of bats. Set it too low and you are more likely to
record non-relevant sounds. I estimate that equivalent threshold of
manual recording is about -50 or -60 dB. That is me distinguishing a bat
from the background noise and recording it. Setting the automatic
threshold at -50 or -60 dB would generate much more recordings with only
noise as the detector doesn’t discriminates between bat sounds and other
sounds.

The next figure gives an indication of the length of the recordings at
the forest setting were the pictures were taken. The detector was
operational from 20:30 until 23:33. The maximal length of the recordings
was set at 20 seconds, the sound level threshold to -40 dB. I had only 3
recordings without bats. All of these relate to me checking the status
of the detector. 84% of the recordings were the minimal 5 seconds. None
of the recordings was longer than 10 seconds. The following figure shows
the distribution of the time between two consecutive recordings.

<img src="../../../post/2017-07-24-peersonic-bat-detector-in-waterproof-ip67-enclosure_files/figure-gfm/length-1.svg" title="Distribution of the number of recordings per 2 minutes" alt="Distribution of the number of recordings per 2 minutes" width="672" style="display: block; margin: auto;" />

<img src="../../../post/2017-07-24-peersonic-bat-detector-in-waterproof-ip67-enclosure_files/figure-gfm/interval-1.svg" title="Distribution of the time between two consecutive recordings." alt="Distribution of the time between two consecutive recordings." width="672" style="display: block; margin: auto;" />

## Sleep mode

The Peersonic RPA2 has the ability to go once a day into sleep mode. The
sleep mode has two benefits. First, the detectors stops making
recordings, so you won’t have to deal with daytime recordings
(e.g. birds). Second, the power consumption is reduced to the bare
minimum. Hence the batteries will last longer.

The sleep mode requires the extra time stamp module, which I highly
recommend because it is useful to know when a recording was made. The
user can enter the time at which the detector goes into sleep mode and
the time it has to wake up. The times can be set in 15 min intervals.
The manual warns that the detector will wake up within a 15 min window
of the specified wake up time. So set the time 15 min earlier than the
time you had in mind.

The sleep mode settings are stored, even when the detector is turned off
or the batteries are removed. Placing the detector in the field,
mounting the batteries and turning it on should be sufficient. Hence the
person in the field needs only a limited knowledge on the detector.

## Reading the WAV files

The default way of reading the WAV files is to connect the RPA2 with an
USB cable to a computer and copy the files to the hard disk. This can be
cumbersome when using the detector in a remote location. Simply swapping
the SD cards would be much easier.

Swapping the SD cards yields two problems. First of all, the SD cards
are not in a standard FAT16 or FAT32 format, but in a BATFAT format.
This is due to the limited code space on the processor. The result is
that a computer can’t read the SD cards. A second problem is access to
the SD card. In case of the standard enclosure, replacing the SD card
would require to dismantle and reassemble the enclosure. The IP67 has
somewhat better access: the SD card is visible when you open the
enclosure. However, it still is somewhat hidden underneath the display.
I can’t reach it with my fingers.

The BATFAT format has another limit: it can store a maximum of 3000 wav
files. Therefore a 32 GB SD card is sufficient when recordings a not
longer than 10 sec. 3000 recordings of 10 sec is 8h20 in total, which
should cover several nights.

Recently, Peersonic announced on their Facebook page that they made
software available to read the SD cards from a (Windows?) computer. I
will try it and write another blog post about it.

## Room for improvement

> The biggest room in the world is the room for improvement.

-   Optional resting mode after a recording. As soon as the recording is
    stored on the SD card, the RPA is ready to create a new recording.
    When a bat hunts for some time around the microphone, it will lead
    to several recording. Placing the detector at a location with lost
    of activity/noise will fill the SD card on a single night. It would
    be useful to have a setting that disables the trigger for some time
    (5, 10, 30, … seconds) after the last recording.
-   GPS module. Such module would do ideally two things 1) add
    timestamps, location and estimate of location precision to each
    recording and 2) store the transect along which the detector moves.
    A GPS module is less relevant for the IP67 enclosure as that would
    be used stationary.
-   The audio cable is mounted near the edge of the enclosure. Closing
    it requires some care as the connector sometimes hits the bottom
    halve of the enclosure. The trick is to gently push the connector
    slightly inwards when closing. An L-shaped connector instead of a
    straight connector would probably solve this.
-   Try to move the SD card more to the side so that it is more
    accessible and easier to replace.

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
    #>  package     * version date       lib source        
    #>  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.1.0)
    #>  bit           4.0.4   2020-08-04 [1] CRAN (R 4.1.0)
    #>  bit64         4.0.5   2020-08-30 [1] CRAN (R 4.1.0)
    #>  cli           3.0.1   2021-07-17 [1] CRAN (R 4.1.1)
    #>  codetools     0.2-18  2020-11-04 [1] CRAN (R 4.1.0)
    #>  colorspace    2.0-2   2021-06-24 [1] CRAN (R 4.1.0)
    #>  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.1.0)
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
    #>  hms           1.1.0   2021-05-17 [1] CRAN (R 4.1.0)
    #>  htmltools     0.5.2   2021-08-25 [1] CRAN (R 4.1.1)
    #>  knitr       * 1.33    2021-04-24 [1] CRAN (R 4.1.0)
    #>  labeling      0.4.2   2020-10-20 [1] CRAN (R 4.1.0)
    #>  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.1.0)
    #>  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.1.0)
    #>  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.1.0)
    #>  pillar        1.6.2   2021-07-29 [1] CRAN (R 4.1.1)
    #>  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.1.0)
    #>  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.1.0)
    #>  R6            2.5.1   2021-08-19 [1] CRAN (R 4.1.1)
    #>  readr       * 2.0.1   2021-08-10 [1] CRAN (R 4.1.1)
    #>  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.1.0)
    #>  rmarkdown     2.10    2021-08-06 [1] CRAN (R 4.1.1)
    #>  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.1.0)
    #>  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.1.0)
    #>  scales        1.1.1   2020-05-11 [1] CRAN (R 4.1.0)
    #>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.1.0)
    #>  stringi       1.7.4   2021-08-25 [1] CRAN (R 4.1.1)
    #>  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.1.0)
    #>  tibble        3.1.4   2021-08-25 [1] CRAN (R 4.1.1)
    #>  tidyselect    1.1.1   2021-04-30 [1] CRAN (R 4.1.0)
    #>  tzdb          0.1.2   2021-07-20 [1] CRAN (R 4.1.1)
    #>  utf8          1.2.2   2021-07-24 [1] CRAN (R 4.1.1)
    #>  vctrs         0.3.8   2021-04-29 [1] CRAN (R 4.1.0)
    #>  vroom         1.5.4   2021-08-05 [1] CRAN (R 4.1.1)
    #>  withr         2.4.2   2021-04-18 [1] CRAN (R 4.1.0)
    #>  xfun          0.25    2021-08-06 [1] CRAN (R 4.1.1)
    #>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.1.0)
    #> 
    #> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
    #> [2] /usr/local/lib/R/site-library
    #> [3] /usr/lib/R/site-library
    #> [4] /usr/lib/R/library
