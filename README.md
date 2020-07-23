# chez-string-metrics
[![Build Status](https://travis-ci.com/macdavid313/chez-string-metrics.svg?token=XxU4s79HyxyMEs7ogNps&branch=master)](https://travis-ci.com/macdavid313/chez-string-metrics)

Calculate various string metrics efficiently in Chez Scheme, e.g. Levenshtein

Currently these metrics are supported:

* [Hamming distance](http://en.wikipedia.org/wiki/Hamming_distance)
* [Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance)
* [Normalized Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance)
* [Damerau-Levenshtein distance](http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)
* [Normalized Damerau-Levenshtein distance](http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)
* [Jaccard similarity coefficient](http://en.wikipedia.org/wiki/Jaccard_index)
* [Overlap coefficient](http://en.wikipedia.org/wiki/Overlap_coefficient)
* [Jaro distance](http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)
* [Jaro-Winkler distance](http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)

This is actually a project for showing a simple usage of Chez's [C library routines](https://cisco.github.io/ChezScheme/csug9.5/foreign.html#./foreign:h8). Except `jaccard` and `overlap`, all the other APIs were implemented by Chez's C library. For example:

```c
#include <scheme.h>

ptr Shamming(ptr str1, ptr str2)
{
    iptr distance = 0;
    iptr len = Sstring_length(str1);

    if (len != Sstring_length(str2))
    {
        return Sfixnum(distance);
    }

    for (iptr i = 0; i < len; i++)
    {
        if (Sstring_ref(str1, i) != Sstring_ref(str2, i))
        {
            distance += (iptr)1;
        }
    }

    return Sfixnum(distance);
}
```

JFYI, the performace is quite pleasant and general no `consing`.

## Install

Download from `release` (currently only provided for Linux 64bit) and put it somewhere that your `chez` can search for.

## Build from source

```shell
CC=gcc CHEZ_KERNEL=/path/to/your/chez/scheme.h/and/kernel.o scheme --script ./build.ss
```