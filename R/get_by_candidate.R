# R/get_by_candidate.R
# tv_get_recall_2025_by_candidate(): query by Chinese candidate name

#' Get 2025 legislator recall results by candidate (Chinese name)
#'
#' @param candidate Chinese full name, e.g. "鄭正鈐"
#' @param level "village" (default) or "town" (aggregated)
#' @param refresh Force re-download the dataset (default FALSE)
#' @return A tibble with standardized columns
#' @export
tv_get_recall_2025_by_candidate <- function(candidate,
                                            level = c("village","town"),
                                            refresh = FALSE) {
  level <- match.arg(level)
  stopifnot(is.character(candidate), length(candidate) == 1L)

  dat <- tv_read_data(refresh = refresh)

  # normalize and filter
  keep <- tv_equal_zh(dat$candidate, candidate)
  out <- dat[keep, , drop = FALSE]

  if (nrow(out) == 0L) {
    stop(sprintf("No rows found for candidate '%s'.", candidate))
  }

  if (level == "town") {
    out <- tv_aggregate_to_town(out)
  }

  tibble::as_tibble(out)
}
