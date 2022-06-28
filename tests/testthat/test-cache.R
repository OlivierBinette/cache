glob.exists <- function(glob, dir = ".") {
  any(grepl(
    glob2rx(glob),
    list.files(dir)
  ))
}


test_that("simple caching creates a file", {
  tmp <- tempdir()
  
  cache_file <- cache(a = {
    Sys.sleep(1)
    "Hello World"
  }, .cachedir = tmp, .rerun = TRUE)
  
  expect_equal(a, "Hello World")
  
  expect_true(glob.exists("a_@_*", tmp))
  expect_true(file.exists(cache_file))
})

test_that(".rerun forces update", {
  tmp <- tempdir()
  
  cache_file <- cache(a = "Hello World", .cachedir = tmp)
  finfo <- file.info(cache_file)
  # New file
  expect_equal(finfo$ctime, finfo$mtime)
  
  cache_file <- cache(a = "Hello World", .cachedir = tmp, .rerun = TRUE)
  finfo_rerun <- file.info(cache_file)
  
  # Updated file
  expect_gt(finfo_rerun$mtime, finfo$mtime)
})

test_that("cache_load loads multiple files", {
  tmp <- tempdir()
  
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