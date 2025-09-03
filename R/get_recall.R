#' Get Taiwan recall data
#'
#' @description
#' This function retrieves recall election data for Taiwan's legislative elections.
#' Currently supports 2025 legislator recall data.
#'
#' @param year Numeric vector. The election year(s). Currently supports: 2025.
#' @param office Character. The type of office. Currently supports: "legislator".
#' @param sub_type Character. The sub-type of election. Currently supports: "regional".
#' @param level Character. The administrative level for filtering. Options: 
#'   "all" (default), "county", "town", "village", "polling_station".
#'   When "all" is used with area_name, it will search across all administrative levels.
#' @param area_name Character. The name of the area to filter by. When level="all",
#'   this will match against county, town, or village names.
#' @param candidate Character. The name of the candidate to filter by.
#' @param party Character. The political party to filter by.
#'
#' @return A tibble containing recall election results with the following columns:
#' \describe{
#'   \item{year}{Election year}
#'   \item{data_type}{Type of data (always "recall")}
#'   \item{office}{Office type (e.g., "legislator")}
#'   \item{sub_type}{Sub-type (e.g., "regional")}
#'   \item{county}{County name}
#'   \item{town}{Town/District name}
#'   \item{village}{Village name}
#'   \item{polling_station_id}{Polling station ID}
#'   \item{candidate_name}{Candidate name}
#'   \item{party}{Political party}
#'   \item{votes}{Number of recall votes}
#'   \item{vote_percentage}{Percentage of recall votes}
#'   \item{is_recalled}{Logical indicating if recall was successful}
#'   \item{disagree}{Number of votes against recall}
#'   \item{invalid}{Number of invalid votes}
#'   \item{total_valid}{Total valid votes}
#'   \item{total_ballots}{Total ballots cast}
#'   \item{not_voted_but_issued}{Ballots issued but not voted}
#'   \item{issued_ballots}{Total ballots issued}
#'   \item{unused_ballots}{Unused ballots}
#'   \item{registered}{Registered voters}
#'   \item{turnout_rate}{Voter turnout rate}
#' }
#'
#' @examples
#' \dontrun{
#' # Get all 2025 recall data
#' tv_get_recall(year = 2025)
#' 
#' # Get data for a specific candidate
#' tv_get_recall(year = 2025, candidate = "馬文君")
#' 
#' # Get data for a specific party
#' tv_get_recall(year = 2025, party = "中國國民黨")
#' 
#' # Get data for a specific county
#' tv_get_recall(year = 2025, level = "county", area_name = "南投縣")
#' 
#' # Get data for a specific town
#' tv_get_recall(year = 2025, level = "town", area_name = "草屯鎮")
#' }
#'
#' @export
tv_get_recall <- function(year = NULL, 
                         office = "legislator", 
                         sub_type = "regional",
                         level = "all",
                         area_name = NULL,
                         candidate = NULL,
                         party = NULL) {
  
  # Validate parameters
  if (is.null(year)) {
    stop("Year parameter is required. Currently supported: 2025")
  }
  
  if (!all(year %in% 2025)) {
    stop("Currently only 2025 recall data is available")
  }
  
  if (office != "legislator") {
    stop("Currently only 'legislator' office type is supported")
  }
  
  if (sub_type != "regional") {
    stop("Currently only 'regional' sub_type is supported")
  }
  
  valid_levels <- c("all", "county", "town", "village", "polling_station")
  if (!level %in% valid_levels) {
    stop("level must be one of: ", paste(valid_levels, collapse = ", "))
  }
  
  # Load data for each year
  all_data <- NULL
  
  for (y in year) {
    file_name <- paste0(y, "_", office, "_recall.csv")
    data <- tv_read_data(file_name)
    
    if (is.null(all_data)) {
      all_data <- data
    } else {
      all_data <- dplyr::bind_rows(all_data, data)
    }
  }
  
  # Apply filters
  result <- all_data
  
  # Filter by candidate
  if (!is.null(candidate)) {
    result <- dplyr::filter(result, .data$candidate_name %in% candidate)
  }
  
  # Filter by party
  if (!is.null(party)) {
    result <- dplyr::filter(result, .data$party %in% party)
  }
  
  # Filter by area based on level
  if (!is.null(area_name)) {
    if (level == "county") {
      result <- dplyr::filter(result, .data$county %in% area_name)
    } else if (level == "town") {
      result <- dplyr::filter(result, .data$town %in% area_name)
    } else if (level == "village") {
      result <- dplyr::filter(result, .data$village %in% area_name)
    } else if (level == "polling_station") {
      result <- dplyr::filter(result, .data$polling_station_id %in% area_name)
    } else if (level == "all") {
      # When level is "all", try to match area_name against county, town, or village
      result <- dplyr::filter(result, 
        .data$county %in% area_name | 
        .data$town %in% area_name | 
        .data$village %in% area_name
      )
    }
  }
  
  # Arrange by county, town, village, polling_station_id for consistent ordering
  result <- dplyr::arrange(result, .data$county, .data$town, .data$village, .data$polling_station_id)
  
  return(result)
}
