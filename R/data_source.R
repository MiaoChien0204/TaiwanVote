# R/data_source.R
# Minimal data source & caching helpers

.get_release_url <- function(file_name) {
  # Generate URL for specific file from GitHub releases
  base_url <- "https://github.com/MiaoChien0204/TaiwanVote/releases/latest/download/"
  paste0(base_url, file_name)
}

.get_cache_dir <- function() {
  # Allow override via env var; otherwise use R_user_dir
  dir <- Sys.getenv("TV_CACHE_DIR", unset = tools::R_user_dir("TaiwanVote", "cache"))
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dir
}

.get_cached_csv_path <- function(file_name) {
  file.path(.get_cache_dir(), file_name)
}

#' Clear cached data
#' 
#' Remove cached data files. If no file_name is specified, removes all cached files.
#' 
#' @param file_name Character. Specific file name to remove. If NULL, removes all cached files.
#' @export
tv_cache_clear <- function(file_name = NULL) {
  cache_dir <- .get_cache_dir()
  
  if (is.null(file_name)) {
    # Remove all cached files
    files <- list.files(cache_dir, pattern = "\\.csv$", full.names = TRUE)
    if (length(files) > 0) {
      unlink(files)
    }
    invisible(files)
  } else {
    # Remove specific file
    p <- .get_cached_csv_path(file_name)
    if (file.exists(p)) unlink(p)
    invisible(p)
  }
}

tv_data_path <- function(file_name, refresh = FALSE) {
  p <- .get_cached_csv_path(file_name)
  if (!file.exists(p) || isTRUE(refresh)) {
    url <- .get_release_url(file_name)
    tryCatch({
      utils::download.file(url, destfile = p, mode = "wb", quiet = TRUE)
    }, error = function(e) {
      stop("Failed to download file '", file_name, "' from: ", url, "\nError: ", e$message)
    })
  }
  p
}

tv_read_data <- function(file_name, refresh = FALSE) {
  path <- tv_data_path(file_name, refresh = refresh)
  readr::read_csv(
    path,
    show_col_types = FALSE,
    progress = FALSE
  )
}
