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
#' @param area_name Character. The name of the area to filter by. Supports both 
#'   simple names (e.g., "東區", "三民里") and full administrative names 
#'   (e.g., "新竹市東區", "新竹市東區三民里"). When using full names, the function
#'   will automatically parse and match the appropriate administrative levels.
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
#' tv_get_recall(year = 2025, level = "county", area_name = "新竹市")
#' 
#' # Get data for a specific town (both formats supported)
#' tv_get_recall(year = 2025, level = "town", area_name = "新竹市東區")
#' tv_get_recall(year = 2025, level = "town", area_name = "東區")  # Less specific
#' 
#' # Get data for a specific village (both formats supported)
#' tv_get_recall(year = 2025, level = "village", area_name = "新竹市東區三民里")
#' tv_get_recall(year = 2025, level = "village", area_name = "三民里")  # Less specific
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
      # Support both "東區" and "新竹市東區" formats
      parsed_areas <- sapply(area_name, function(area) {
        if (grepl("縣|市", area) && !grepl("^(縣|市)", area)) {
          # Contains county/city name, extract town part
          # e.g., "新竹市東區" -> "東區"
          parts <- strsplit(area, "(縣|市)", perl = TRUE)[[1]]
          if (length(parts) >= 2) {
            return(parts[2])
          }
        }
        # Return as is for simple town names like "東區"
        return(area)
      })
      
      if (any(grepl("縣|市", area_name))) {
        # If any area_name contains county/city, filter by both county and town
        county_names <- sapply(area_name, function(area) {
          if (grepl("縣|市", area)) {
            parts <- strsplit(area, "(縣|市)", perl = TRUE)[[1]]
            if (length(parts) >= 1) {
              # Reconstruct county name with 縣/市
              county_part <- parts[1]
              if (grepl("縣", area)) {
                return(paste0(county_part, "縣"))
              } else {
                return(paste0(county_part, "市"))
              }
            }
          }
          return(NA)
        })
        
        # Filter by matching county-town combinations
        valid_combinations <- data.frame(
          county = county_names[!is.na(county_names)],
          town = parsed_areas[!is.na(county_names)],
          stringsAsFactors = FALSE
        )
        
        if (nrow(valid_combinations) > 0) {
          filter_condition <- FALSE
          for (i in 1:nrow(valid_combinations)) {
            filter_condition <- filter_condition | 
              (.data$county == valid_combinations$county[i] & 
               .data$town == valid_combinations$town[i])
          }
          result <- dplyr::filter(result, !!filter_condition)
        }
      } else {
        # Simple town name filtering
        result <- dplyr::filter(result, .data$town %in% parsed_areas)
      }
    } else if (level == "village") {
      # Support both "三民里" and "新竹市東區三民里" formats
      parsed_areas <- sapply(area_name, function(area) {
        # Extract village name from full address
        if (grepl("里$", area)) {
          # Find the village part (last part ending with 里)
          parts <- strsplit(area, "(縣|市|鎮|鄉|區)", perl = TRUE)[[1]]
          village_part <- parts[length(parts)]
          if (nchar(village_part) > 0) {
            return(village_part)
          }
        }
        return(area)
      })
      
      if (any(grepl("縣|市", area_name))) {
        # Parse full address: county + town + village
        parsed_full <- lapply(area_name, function(area) {
          if (grepl("縣|市", area)) {
            # Parse "新竹市東區三民里" format
            county_match <- regexpr("^[^縣市]+[縣市]", area, perl = TRUE)
            if (county_match > 0) {
              county <- substring(area, 1, attr(county_match, "match.length"))
              remaining <- substring(area, attr(county_match, "match.length") + 1)
              
              # Extract town (everything before the village)
              village_match <- regexpr("[^鎮鄉區]+里$", remaining, perl = TRUE)
              if (village_match > 0) {
                village <- substring(remaining, village_match)
                town <- substring(remaining, 1, village_match - 1)
                if (nchar(town) > 0) {
                  return(list(county = county, town = town, village = village))
                }
              }
            }
          }
          return(NULL)
        })
        
        # Filter by matching county-town-village combinations
        valid_combinations <- do.call(rbind, lapply(parsed_full, function(x) {
          if (!is.null(x)) {
            data.frame(county = x$county, town = x$town, village = x$village, stringsAsFactors = FALSE)
          } else {
            NULL
          }
        }))
        
        if (!is.null(valid_combinations) && nrow(valid_combinations) > 0) {
          filter_condition <- FALSE
          for (i in 1:nrow(valid_combinations)) {
            filter_condition <- filter_condition | 
              (.data$county == valid_combinations$county[i] & 
               .data$town == valid_combinations$town[i] &
               .data$village == valid_combinations$village[i])
          }
          result <- dplyr::filter(result, !!filter_condition)
        }
      } else {
        # Simple village name filtering
        result <- dplyr::filter(result, .data$village %in% parsed_areas)
      }
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
