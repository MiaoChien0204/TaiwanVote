# R/normalize.R
# Very small normalization helpers for Chinese names

tv_norm_zh <- function(x) {
  x <- as.character(x)
  x <- gsub("台", "臺", x, fixed = TRUE)
  x <- trimws(x)
  x
}

# Safe equals after normalization (case-insensitive not needed for zh)
tv_equal_zh <- function(x, y) {
  tv_norm_zh(x) == tv_norm_zh(y)
}
