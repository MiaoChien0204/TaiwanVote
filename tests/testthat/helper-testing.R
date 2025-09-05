# Helper functions for testing

#' Skip test if offline
#' 
#' This function skips tests when there's no internet connection
skip_if_offline <- function() {
  if (!has_internet()) {
    testthat::skip("No internet connection")
  }
}

#' Check internet connection
#' 
#' @return TRUE if internet is available, FALSE otherwise
has_internet <- function() {
  tryCatch({
    # Try to connect to a reliable server
    con <- url("http://httpbin.org/status/200", open = "rb")
    close(con)
    return(TRUE)
  }, error = function(e) {
    return(FALSE)
  })
}

#' Create sample election data for testing
#' 
#' @param n_stations Number of polling stations
#' @param n_candidates Number of candidates
#' @return A data frame with sample election data
create_sample_election_data <- function(n_stations = 2, n_candidates = 3) {
  stations <- paste0("00", 1:n_stations)
  candidates <- paste0("候選人", LETTERS[1:n_candidates])
  parties <- paste0("政黨", 1:n_candidates)
  
  data <- expand.grid(
    polling_station_id = stations,
    candidate_name = candidates,
    stringsAsFactors = FALSE
  )
  
  data$year <- 2024
  data$data_type <- "election"
  data$office <- "president"
  data$sub_type <- NA_character_
  data$county <- "測試縣"
  data$town <- "測試鎮"
  data$village <- "測試里"
  data$party <- rep(parties, times = n_stations)
  data$votes <- sample(50:200, nrow(data), replace = TRUE)
  data$invalid <- 5
  data$total_valid <- 500
  data$total_ballots <- 505
  data$registered <- 600
  data$vote_percentage <- round(data$votes / data$total_valid * 100, 2)
  data$turnout_rate <- round(data$total_ballots / data$registered * 100, 2)
  
  return(data)
}

#' Create sample recall data for testing
#' 
#' @param n_stations Number of polling stations
#' @return A data frame with sample recall data
create_sample_recall_data <- function(n_stations = 2) {
  stations <- paste0("00", 1:n_stations)
  
  data <- data.frame(
    year = 2025,
    data_type = "recall",
    office = "legislator",
    sub_type = "regional",
    county = "測試縣",
    town = "測試鎮",
    village = "測試里",
    polling_station_id = stations,
    candidate_name = "測試候選人",
    party = "測試政黨",
    votes = sample(80:150, n_stations, replace = TRUE),  # agree votes
    disagree = sample(60:120, n_stations, replace = TRUE),
    invalid = 5,
    total_valid = 300,
    total_ballots = 305,
    not_voted_but_issued = 10,
    issued_ballots = 315,
    unused_ballots = 10,
    registered = 400,
    stringsAsFactors = FALSE
  )
  
  data$vote_percentage <- round(data$votes / data$total_valid * 100, 2)
  data$turnout_rate <- round(data$total_ballots / data$registered * 100, 2)
  
  return(data)
}

#' Check if data frame has expected structure
#' 
#' @param df Data frame to check
#' @param required_cols Vector of required column names
#' @param data_type Expected data type ("election" or "recall")
#' @return TRUE if structure is correct, error otherwise
check_data_structure <- function(df, required_cols, data_type = NULL) {
  # Check that it's a data frame
  if (!is.data.frame(df)) {
    stop("Input is not a data frame")
  }
  
  # Check required columns
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop("Missing columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Check data type if specified
  if (!is.null(data_type) && nrow(df) > 0) {
    if (!all(df$data_type == data_type)) {
      stop("Incorrect data_type. Expected: ", data_type)
    }
  }
  
  return(TRUE)
}
