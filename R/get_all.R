# R/get_all.R
# tv_get_recall_2025_all(): get all recall data

#' Get all 2025 legislator recall results
#'
#' @param level "village" (default) or "town" (aggregated).
#' @return A tibble with all recall data at the specified level.
#' @export
tv_get_recall_2025_all <- function(level = c("village", "town")) {
  level <- match.arg(level)
  
  dat <- tv_read_data(refresh = FALSE)
  
  if (level == "town") {
    dat <- tv_aggregate_to_town(dat)
  }
  
  tibble::as_tibble(dat)
}