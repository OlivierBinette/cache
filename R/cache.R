
#' Cache or Retrieve Computation Results
#' 
#' Cache or retrieve an evaluated expression. Results are always made available in the current environment.
#' 
#' @usage cache(..., .cachedir = file.path(here("."), ".cache-R"), .rerun = FALSE)
#' 
#' @param ... Named expressions to be cached or retrieved.
#' @param .cachedir Directory where cache files are stored.
#' @param .rerun Whether or not to clear the cache and re-run the provided expressions. Defaults to FALSE.
#' @examples 
#' tmp = tempdir()
#' 
#' # Takes 1 second to execute
#' cache(a = {Sys.sleep(1); "Hello World"}, .cachedir = tmp) 
#' 
#' # Executes instantly
#' cache(a = {Sys.sleep(1); 1}, .cachedir = tmp)
#' 
#' # Result is available in the current environment
#' print(a)
#' 
#' # Re-run the expression
#' cache(a = {Sys.sleep(1); 1}, .cachedir = tmp, .rerun = TRUE)
#' 
#' @importFrom here here
#' @importFrom digest digest
#' @import cli assert
#' @export 
cache <- function(..., .cachedir = file.path(here("."), ".cache-R"), .rerun = FALSE) {
    
    if (!dir.exists(.cachedir)) {
        cli::cli_alert_info("Creating cache directory {.path {.cachedir}}")
        dir.create(.cachedir, recursive=TRUE)
    }

    dots <- substitute(list(...))[-1]
    args = lapply(dots, deparse)
    assert(!is.null(names(args)),
            all(nchar(names(args)) > 0), 
            msg = "All arguments must be named.")

    args = args[names(args) != ".cachedir"]
    objnames = names(args)
    hashcodes = sapply(args, digest, algo="md5")
    cachefiles = file.path(.cachedir, paste(objnames, hashcodes, sep="_"))

    rerun = !file.exists(cachefiles)
    
    for (i in seq_along(args)) {
        if (any(rerun[[i]], .rerun)) {
            file.remove(list.files(path = .cachedir, pattern = paste0("^", objnames[[i]], "_*"), full.names=TRUE))

            saveRDS(...elt(i), file=cachefiles[[i]])
        }

        assign(objnames[[i]], readRDS(cachefiles[[i]]), envir=parent.frame())
    }
}
