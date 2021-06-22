<!-- README.md is generated from README.Rmd. Please edit that file -->



# :recycle: **cache**: easily cache and retrieve computation results

<!-- badges: start -->
[![Lifecycle: stable](https://lifecycle.r-lib.org/articles/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN status](https://www.r-pkg.org/badges/version/cache)](https://CRAN.R-project.org/package=cache)
[![R-CMD-check](https://github.com/OlivierBinette/cache/workflows/R-CMD-check/badge.svg)](https://github.com/OlivierBinette/cache/actions)
<!-- badges: end -->

The **cache** package provides a simple interface to caching which works across interactive R sessions, R scripts and Rmarkdown documents. Simply wrap your R expressions with the `cache()` function to cache or retrieve the results.

## Installation

You can install the released version of **cache** from CRAN with:


```r
install.packages("cache")
```

and the development version from [GitHub](https://github.com/) with:


```r
if (!require(devtools)) install.packages("devtools")
devtools::install_github("OlivierBinette/cache")
```

## Examples

Wrap any R expression using the `cache()` function to cache the result:


```r
library(cache)

cache(myComputation = {Sys.sleep(3); "Hello World"})
```

The variable named `myComputation` contains the result of the computation and is available in your environment:


```r
print(myComputation)
#> [1] "Hello World"
```

While it takes 3 seconds to evaluate the expression `{Sys.sleep(3); "Hello World"}`, the previously cached result can be instantly retrieved using the same function call:


```r
system.time(
  cache(myComputation = {Sys.sleep(3); "Hello World"})
)
#>    user  system elapsed 
#>   0.002   0.001   0.002

print(myComputation)
#> [1] "Hello World"
```

This is especially useful as part of a reproducible analysis workflow or as part of an Rmarkdown document. However, in constrast with the cache functionality of the `rmarkdown` package, the **cache** package can be used seamlessly across interactive sessions, reproducible analyses and Rmarkdown knitting.

## Notes

By default, the cache directory is located under a `./cache-R` folder created at the root of your project directory. This folder is located using the `here::here()` function to ensure that all project files and documents can locate it as needed.

To clear the cache and rerun all expressions, either delete the `.cache-R` folder or supply the argument `.rerun = FALSE` to the `cache()` function calls.
