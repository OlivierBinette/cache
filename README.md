<!-- README.md is generated from README.Rmd. Please edit that file -->



# :recycle: **cache**: easily cache and retrieve computation results

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN status](https://www.r-pkg.org/badges/version/cache)](https://CRAN.R-project.org/package=cache)
[![R-CMD-check](https://github.com/OlivierBinette/cache/workflows/R-CMD-check/badge.svg)](https://github.com/OlivierBinette/cache/actions)
<!-- badges: end -->

The **cache** package provides a simple interface to caching which works across interactive R sessions, R scripts and Rmarkdown documents. Simply wrap your R expressions with the `cache()` function to cache or retrieve the results:


```r
library(cache)

cache(myComputation = {Sys.sleep(3); "Hello World"})

print(myComputation)
#> [1] "Hello World"
```

It takes 3 seconds to evaluate the expression `{Sys.sleep(3); "Hello World"}`. However, the previously cached result can be instantly retrieved using the same function call:


```r
system.time(
  cache(myComputation = {Sys.sleep(3); "Hello World"})
)
#>    user  system elapsed 
#>   0.021   0.001   0.025

print(myComputation)
#> [1] "Hello World"
```

In contrast with the built-in cache functionality of knitr and Rmarkdown documents, the **cache** package can be used seamlessly across your interactive session and Rmarkdown knitting.

By default, the cache directory is located under a `./cache-R` folder created at the root of your project directory. This folder is located using the `here::here()` function to ensure that all project files and documents can locate it as needed.


## Installation

You can install the the development version from [GitHub](https://github.com/) with:

``` r
if (!require(devtools)) install.packages("devtools")
devtools::install_github("OlivierBinette/cache")
```
