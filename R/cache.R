
#' Cache or Retrieve Computation Results
#'
#' Cache or retrieve an evaluated expression. Results are always made available in the current environment.
#'
#' @usage cache(..., .cachedir = here(".cache-R"), .rerun = FALSE)
#'
#' @param ... Named expressions to be cached or retrieved.
#' @param .cachedir Directory where cache files are stored. Default is a directory called `.cache-R` located at the project root.
#' @param .rerun Whether or not to clear the cache and re-run the provided expressions. Defaults to FALSE.
#' @examples
#' tmp <- tempdir()
#'
#' # Takes 1 second to execute
#' cache(a = {
#'   Sys.sleep(1)
#'   "Hello World"
#' }, .cachedir = tmp)
#'
#' # Executes instantly
#' cache(a = {
#'   Sys.sleep(1)
#'   "Hello World"
#' }, .cachedir = tmp)
#'
#' # Result is available in the current environment
#' print(a)
#'
#' # Re-run the expression
#' cache(a = {
#'   Sys.sleep(1)
#'   "Hello World"
#' }, .cachedir = tmp, .rerun = TRUE)
#' @importFrom here here
#' @import cli assert digest
#' @export
cache <- function(..., .cachedir = here(".cache-R"), .rerun = FALSE) {
  if (!dir.exists(.cachedir)) {
    cli::cli_alert_info("Creating cache directory {.path {.cachedir}}")
    dir.create(.cachedir, recursive = TRUE)
  }

  dots <- substitute(list(...))[-1]
  args <- lapply(dots, deparse)
  assert(!is.null(names(args)),
    all(nchar(names(args)) > 0),
    msg = "All arguments must be named."
  )

  args <- args[names(args) != ".cachedir"]
  objnames <- names(args)
  hashcodes <- sapply(args, digest, algo = "md5")
  cachefiles <- file.path(.cachedir, paste0(objnames, "_@_", hashcodes, ".rds"))

  rerun <- !file.exists(cachefiles)

  for (i in seq_along(args)) {
    if (any(rerun[[i]], .rerun)) {
      file.remove(list.files(path = .cachedir, pattern = paste0("^", objnames[[i]], "_@_[[:alnum:]]+.rds"), full.names = TRUE))

      saveRDS(...elt(i), file = cachefiles[[i]])
    }

    assign(objnames[[i]], readRDS(cachefiles[[i]]), envir = parent.frame())
  }
}


#' Load cached objects from cache directory
#'
#' @usage cache_load(objnames = "*", .cachedir = here(".cache-R"))
#'
#' @param objnames character list of object names to load.
#' @param .cachedir path to cache directory. Defaults to the directory named `.cache-R` at the project root.
#'
#' @importFrom here here
#' @import cli assert
#' @export
cache_load <- function(objnames = "*", .cachedir = here(".cache-R")) {
  assert(dir.exists(.cachedir))

  files <- sapply(objnames, function(name) {
    list.files(path = .cachedir, pattern = paste0(name, "_@_[[:alnum:]]+.rds"), full.names = TRUE)
  })

  found <- sapply(files, function(f) !identical(f, character(0)))
  foundnames <- tools::file_path_sans_ext(basename(as.character(files[found])))
  foundnames <- sub("_@_.*", "", foundnames)

  if (any(found)) {
    cli::cli_alert_info(paste(c("Reading the following objects from cache: ", foundnames), collapse = " "))
  }
  if (any(!found)) {
    cli::cli_alert_warning(paste(c("The following objects were not found: ", objnames[!found]), collapse = " "))
  }

  for (i in seq_along(objnames)) {
    if (found[[i]]) {
      assign(objnames[[i]], readRDS(files[[i]]), envir = parent.frame())
    }
  }
}
