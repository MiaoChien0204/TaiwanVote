#' Get Taiwan recall data
#'
#' @description
#' This function retrieves recall election data for Taiwan's legislative elections.
#' Currently supports 2025 legislator recall data.
#'
#' @param year Numeric vector. The election year(s). Currently supports: 2025.
#' @param office Character. The type of office. Currently supports: "legislator".
#' @param sub_type Character. The sub-type of election. Currently supports: "regional".
#' @param adm_level Character. Administrative level for data aggregation and winner calculation. 
#'   Options: "polling_station", "village", "town", "county". Default: "polling_station".
#' @param county_name Character vector. County or city names to filter by (e.g., "新竹市", "桃園市").
#' @param town_name Character vector. Town/district names with county included 
#'   (e.g., "新竹市東區", "桃園市桃園區").
#' @param village_name Character vector. Village names with full address 
#'   (e.g., "新竹市東區三民里", "桃園市桃園區文中里").
#' @param candidate Character vector. The name(s) of the candidate(s) to filter by.
#' @param party Character vector. The political party/parties to filter by.
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
#' # Get all 2025 recall data at polling station level (default)
#' tv_get_recall(year = 2025)
#' 
#' # Get data aggregated at village level
#' tv_get_recall(year = 2025, adm_level = "village")
#' 
#' # Get data for a specific county
#' tv_get_recall(year = 2025, county_name = "新竹市")
#' 
#' # Get data for a specific town
#' tv_get_recall(year = 2025, town_name = "新竹市東區")
#' 
#' # Get data for a specific village
#' tv_get_recall(year = 2025, village_name = "新竹市東區三民里")
#' 
#' # Get data for a specific candidate
#' tv_get_recall(year = 2025, candidate = "馬文君")
#' 
#' # Get data for a specific party
#' tv_get_recall(year = 2025, party = "中國國民黨")
#' 
#' # Combine filters with administrative level aggregation
#' tv_get_recall(year = 2025, county_name = "新竹市", party = "中國國民黨", adm_level = "town")
#' }
#'
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr filter bind_rows arrange
tv_get_recall <- function(year = NULL, 
                         office = "legislator", 
                         sub_type = "regional",
                         adm_level = "polling_station",
                         county_name = NULL,
                         town_name = NULL,
                         village_name = NULL,
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
  
  # Validate adm_level parameter
  valid_adm_levels <- c("polling_station", "village", "town", "county")
  if (!adm_level %in% valid_adm_levels) {
    stop("adm_level must be one of: ", paste(valid_adm_levels, collapse = ", "))
  }
  
  # Validate that adm_level is not higher than geographic filter level
  if (!is.null(village_name) && adm_level %in% c("county", "town")) {
    stop("When using village_name filter, adm_level must be 'village' or 'polling_station'")
  }
  
  if (!is.null(town_name) && adm_level == "county") {
    stop("When using town_name filter, adm_level must be 'town', 'village', or 'polling_station'")
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
  
  # Note: Candidate and party filtering is done AFTER is_recalled calculation 
  # to ensure recall results are determined based on complete data, not filtered data
  
  # Filter by county
  if (!is.null(county_name)) {
    result <- dplyr::filter(result, .data$county %in% county_name)
  }
  
  # Filter by town (requires full format like "新竹市東區")
  if (!is.null(town_name)) {
    town_filters <- list()
    
    for (town in town_name) {
      if (grepl("縣|市", town) && !grepl("^(縣|市)", town)) {
        # Parse "新竹市東區" format
        county_match <- regexpr("^[^縣市]+[縣市]", town, perl = TRUE)
        if (county_match > 0) {
          county_part <- regmatches(town, county_match)
          town_part <- substring(town, nchar(county_part) + 1)
          
          # Validate that town_part is not empty and contains valid administrative unit suffixes
          if (nchar(town_part) > 0 && grepl("(區|鎮|鄉|市)$", town_part)) {
            town_filters[[length(town_filters) + 1]] <- 
              list(county = county_part, town = town_part)
          } else {
            stop("Invalid town_name format: '", town, "'. Expected format: '新竹市東區' (county + district/town)")
          }
        } else {
          stop("town_name must include county/city name (e.g., '新竹市東區')")
        }
      } else {
        stop("town_name must include county/city name (e.g., '新竹市東區')")
      }
    }
    
    # Apply town filters
    if (length(town_filters) > 0) {
      if (length(town_filters) == 1) {
        tf <- town_filters[[1]]
        result <- dplyr::filter(result, .data$county == !!tf$county & .data$town == !!tf$town)
      } else {
        filtered_results <- list()
        for (tf in town_filters) {
          filtered_results[[length(filtered_results) + 1]] <- 
            dplyr::filter(result, .data$county == !!tf$county & .data$town == !!tf$town)
        }
        result <- do.call(dplyr::bind_rows, filtered_results)
      }
    }
  }
  
  # Filter by village (requires full format like "新竹市東區三民里")
  if (!is.null(village_name)) {
    village_filters <- list()
    
    for (village in village_name) {
      if (grepl("縣|市", village)) {
        # Parse "新竹市東區三民里" format
        county_match <- regexpr("^[^縣市]+[縣市]", village, perl = TRUE)
        if (county_match > 0) {
          county_part <- regmatches(village, county_match)
          remaining <- substring(village, nchar(county_part) + 1)
          
          # Simple pattern matching for common administrative divisions
          town_part <- ""
          village_part <- ""
          
          if (grepl("區.*里$", remaining)) {
            matches <- regmatches(remaining, regexec("^(.+區)(.+里)$", remaining, perl = TRUE))[[1]]
            if (length(matches) == 3) {
              town_part <- matches[2]
              village_part <- matches[3]
            }
          } else if (grepl("鎮.*里$", remaining)) {
            matches <- regmatches(remaining, regexec("^(.+鎮)(.+里)$", remaining, perl = TRUE))[[1]]
            if (length(matches) == 3) {
              town_part <- matches[2]
              village_part <- matches[3]
            }
          } else if (grepl("鄉.*里$", remaining)) {
            matches <- regmatches(remaining, regexec("^(.+鄉)(.+里)$", remaining, perl = TRUE))[[1]]
            if (length(matches) == 3) {
              town_part <- matches[2]
              village_part <- matches[3]
            }
          }
          
          if (nchar(town_part) > 0 && nchar(village_part) > 0) {
            village_filters[[length(village_filters) + 1]] <- 
              list(county = county_part, town = town_part, village = village_part)
          } else {
            stop("Failed to parse town and village from village_name: ", village)
          }
        }
      } else {
        stop("village_name must include full address (e.g., '新竹市東區三民里')")
      }
    }
    
    # Apply village filters
    if (length(village_filters) > 0) {
      if (length(village_filters) == 1) {
        vf <- village_filters[[1]]
        result <- dplyr::filter(result, 
          .data$county == !!vf$county & 
          .data$town == !!vf$town & 
          .data$village == !!vf$village)
      } else {
        filtered_results <- list()
        for (vf in village_filters) {
          filtered_results[[length(filtered_results) + 1]] <- 
            dplyr::filter(result, 
              .data$county == !!vf$county & 
              .data$town == !!vf$town & 
              .data$village == !!vf$village)
        }
        result <- do.call(dplyr::bind_rows, filtered_results)
      }
    }
  }
  
  # Arrange by county, town, village, polling_station_id for consistent ordering
  result <- dplyr::arrange(result, .data$county, .data$town, .data$village, .data$polling_station_id)
  
  # Calculate is_recalled based on the specified administrative level
  result <- tv_aggregate_and_calculate_recall_results(result, adm_level)
  
  # Apply candidate and party filters AFTER calculating is_recalled
  if (!is.null(candidate)) {
    result <- dplyr::filter(result, .data$candidate_name %in% candidate)
  }
  
  if (!is.null(party)) {
    result <- dplyr::filter(result, .data$party %in% party)
  }
  
  return(result)
}
