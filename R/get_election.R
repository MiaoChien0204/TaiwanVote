#' Get Taiwan election data
#'
#' @description
#' This function retrieves election data for Taiwan's presidential and legislative elections.
#' Currently supports 2024 presidential election data.
#'
#' @param year Numeric vector. The election year(s). Currently supports: 2024.
#' @param office Character. The type of office. Currently supports: "president".
#' @param sub_type Character. The sub-type of election. For president, this should be NULL.
#' @param county_name Character vector. County or city names to filter by (e.g., "新竹市", "桃園市").
#' @param town_name Character vector. Town/district names with county included 
#'   (e.g., "新竹市東區", "桃園市桃園區").
#' @param village_name Character vector. Village names with full address 
#'   (e.g., "新竹市東區三民里", "桃園市桃園區文中里").
#' @param candidate Character vector. The name(s) of the candidate(s) to filter by.
#' @param party Character vector. The political party/parties to filter by.
#'
#' @return A tibble containing election results with the following columns:
#' \describe{
#'   \item{year}{Election year}
#'   \item{data_type}{Type of data (always "election")}
#'   \item{office}{Office type (e.g., "president")}
#'   \item{sub_type}{Sub-type (NA for president)}
#'   \item{county}{County name}
#'   \item{town}{Town/District name}
#'   \item{village}{Village name}
#'   \item{polling_station_id}{Polling station ID}
#'   \item{candidate_name}{Candidate name}
#'   \item{party}{Political party}
#'   \item{votes}{Number of votes received}
#'   \item{vote_percentage}{Percentage of votes}
#'   \item{is_elected}{Logical indicating if candidate was elected}
#'   \item{invalid}{Number of invalid votes}
#'   \item{total_valid}{Total valid votes}
#'   \item{total_ballots}{Total ballots cast}
#'   \item{registered}{Registered voters}
#'   \item{turnout_rate}{Voter turnout rate}
#' }
#'
#' @examples
#' \dontrun{
#' # Get all 2024 presidential election data
#' tv_get_election(year = 2024, office = "president")
#' 
#' # Get data for a specific county
#' tv_get_election(year = 2024, office = "president", county_name = "新竹市")
#' 
#' # Get data for a specific town
#' tv_get_election(year = 2024, office = "president", town_name = "新竹市東區")
#' 
#' # Get data for a specific village
#' tv_get_election(year = 2024, office = "president", village_name = "新竹市東區三民里")
#' 
#' # Get data for a specific candidate
#' tv_get_election(year = 2024, office = "president", candidate = "賴清德")
#' 
#' # Get data for a specific party
#' tv_get_election(year = 2024, office = "president", party = "民主進步黨")
#' 
#' # Combine filters
#' tv_get_election(year = 2024, office = "president", county_name = "新竹市", party = "民主進步黨")
#' }
#'
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr filter bind_rows arrange
tv_get_election <- function(year = NULL, 
                           office = NULL, 
                           sub_type = NULL,
                           county_name = NULL,
                           town_name = NULL,
                           village_name = NULL,
                           candidate = NULL,
                           party = NULL) {
  
  # Validate parameters
  if (is.null(year)) {
    stop("Year parameter is required. Currently supported: 2024")
  }
  
  if (is.null(office)) {
    stop("Office parameter is required. Currently supported: 'president'")
  }
  
  if (!all(year %in% 2024)) {
    stop("Currently only 2024 election data is available")
  }
  
  if (!office %in% "president") {
    stop("Currently only 'president' office type is supported")
  }
  
  if (office == "president" && !is.null(sub_type)) {
    warning("sub_type is ignored for presidential elections")
    sub_type <- NULL
  }
  
  # Load data for each year
  all_data <- NULL
  
  for (y in year) {
    if (office == "president") {
      file_name <- paste0(y, "_president_election.csv")
    } else {
      # Future support for other office types
      file_name <- paste0(y, "_", office, "_election.csv")
    }
    
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
          if (nchar(town_part) > 0) {
            town_filters[[length(town_filters) + 1]] <- 
              list(county = county_part, town = town_part)
          }
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
  
  return(result)
}
