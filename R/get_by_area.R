# R/get_by_area.R
# tv_get_recall_2025_by_area(): query by Chinese area name

#' Get 2025 legislator recall results by Chinese area name
#'
#' @param area Chinese area. Examples:
#'   - Village: "新竹市東區育賢里" (full recommended)
#'   - Town:    "新竹市東區"
#' @param level "village" (default) or "town" (aggregated). If you pass a town
#'   name and level="village", you'll get all villages under that town.
#' @param candidate Optional Chinese candidate name to filter.
#' @param refresh Force re-download the dataset (default FALSE).
#' @return A tibble with standardized columns.
#' @export
tv_get_recall_2025_by_area <- function(area,
                                       level = c("village","town"),
                                       candidate = NULL,
                                       refresh = FALSE) {
  level <- match.arg(level)
  stopifnot(is.character(area), length(area) == 1L)

  dat <- tv_read_data(refresh = refresh)

  # Optional candidate filter first (if provided)
  if (!is.null(candidate)) {
    dat <- dat[tv_equal_zh(dat$candidate, candidate), , drop = FALSE]
  }

  # Normalize user's area and split it into county/town/village if possible
  area_norm <- tv_norm_zh(area)

  # Simple heuristics: try longest full matches first
  # Exact village full name: "縣市行政區村里"
  v_full <- paste0(dat$county, dat$town, dat$village)
  k_v <- tv_norm_zh(v_full) == area_norm

  # Exact town full name: "縣市行政區"
  t_full <- paste0(dat$county, dat$town)
  k_t <- tv_norm_zh(t_full) == area_norm

  if (any(k_v)) {
    out <- dat[k_v, , drop = FALSE]
  } else if (any(k_t)) {
    out <- dat[k_t, , drop = FALSE]
  } else {
    # Fallback: try partial contains (strict but helpful)
    k_contains <- grepl(area_norm, tv_norm_zh(v_full), fixed = TRUE) |
      grepl(area_norm, tv_norm_zh(t_full), fixed = TRUE)
    out <- dat[k_contains, , drop = FALSE]
  }

  if (nrow(out) == 0L) {
    stop(sprintf("No rows found for area '%s'%s.",
                 area,
                 if (!is.null(candidate)) paste0(" (candidate=", candidate, ")") else ""))
  }

  if (level == "town") {
    out <- tv_aggregate_to_town(out)
  }

  tibble::as_tibble(out)
}
