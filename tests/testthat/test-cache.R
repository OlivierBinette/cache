#' return a clean test dir without cache files
test_dir <- function() {
  tmp <- tempdir()
  # rm tmp/*.rds
  file.remove(list.files(tmp, "*.rds", full.names = T))
  tmp  
}

fn_with_side_effect <- function(message = "Side effect") {
  cat(message)
  "Hello, World!"
}

test_that("simple caching creates a file", {
  tmp <- test_dir()
  
  expect_output(
    cache_file <- cache(a = fn_with_side_effect(), .cachedir = tmp),
    "Side effect")
  
  expect_equal(a, "Hello, World!")
  
  expect_true(file.exists(cache_file))
  
  # make sure cache file name is based on the variable
  expect_match(cache_file, "a_@_")
})

test_that(".rerun forces update", {
  tmp <- test_dir()

  # Expect side effect the first time
  expect_output(
    cache(a = fn_with_side_effect(), .cachedir = tmp),
    "Side effect")
  
  # Running again without .rerun produces no side-effect, since the code is not evaluated
  expect_silent(
    cache(a = fn_with_side_effect(), .cachedir = tmp))

  # With rerun, the code is evaluated, so we see a side effect
  expect_output(
    cache(a = fn_with_side_effect(), .cachedir = tmp, .rerun = TRUE),
    "Side effect")
})

test_that("cache_load loads multiple files", {
  tmp <- test_dir()

  cache_files <- cache(
    a = "Hello World", 
    b = "Greetings, Planet!",
    .cachedir = tmp)
  rm(a, b)
  
  expect_message(
    cache_load(.cachedir = tmp),
    "i Reading the following objects from cache:  a b")
  
  expect_equal(a, "Hello World")
  expect_equal(b, "Greetings, Planet!")
})