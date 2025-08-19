# R/data_source.R
# Minimal data source & caching helpers

.get_release_url <- function() {
  # You can change this to use piggyback, but URL is simplest for now.
  "https://github.com/MiaoChien0204/TaiwanVote/releases/download/v0.1.0/2025_legislator_recall.csv"
}

.get_cache_dir <- function() {
  # Allow override via env var; otherwise use R_user_dir
  dir <- Sys.getenv("TV_CACHE_DIR", unset = tools::R_user_dir("TaiwanVote", "cache"))
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dir
}

.get_cached_csv_path <- function() {
  file.path(.get_cache_dir(), "2025_legislator_recall.csv")
}

tv_cache_clear <- function() {
  p <- .get_cached_csv_path()
  if (file.exists(p)) unlink(p)
  invisible(p)
}

tv_data_path <- function(refresh = FALSE) {
  p <- .get_cached_csv_path()
  if (!file.exists(p) || isTRUE(refresh)) {
    url <- .get_release_url()
    utils::download.file(url, destfile = p, mode = "wb", quiet = TRUE)
  }
  p
}

tv_read_data <- function(refresh = FALSE) {
  path <- tv_data_path(refresh = refresh)
  readr::read_csv(
    path,
    show_col_types = FALSE,
    progress = FALSE
  )
}
