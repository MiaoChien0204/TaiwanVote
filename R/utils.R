#' @importFrom dplyr %>%
#' @importFrom rlang syms
NULL

utils::globalVariables(c(
  "candidate","county","town","village","precinct_id",
  "agree","disagree","invalid","total_valid","total_ballots",
  "registered","issued_ballots","unused_ballots",
  "agree_rate","disagree_rate","turnout_rate","level",
  "candidate_name","party","votes","vote_percentage","is_elected","is_recalled",
  "not_voted_but_issued","polling_station_id","year","data_type","office","sub_type"
))

#' Calculate election winners based on administrative level
#' 
#' @description
#' This function calculates is_elected based on the administrative scale
#' represented in the data. Winners are determined by highest vote count
#' at each unique combination of administrative units present in the data.
#' 
#' @param data A data frame containing election results
#' @return Data frame with is_elected column added
#' @keywords internal
#' @importFrom dplyr group_by mutate ungroup
tv_calculate_election_winners <- function(data) {
  if (nrow(data) == 0) {
    data$is_elected <- logical(0)
    return(data)
  }
  
  # Determine grouping level based on data structure
  # Group by all administrative levels present, plus polling station if available
  group_vars <- c()
  
  if ("county" %in% names(data) && length(unique(data$county)) > 1) {
    group_vars <- c(group_vars, "county")
  }
  if ("town" %in% names(data) && length(unique(data$town)) > 1) {
    group_vars <- c(group_vars, "town") 
  }
  if ("village" %in% names(data) && length(unique(data$village)) > 1) {
    group_vars <- c(group_vars, "village")
  }
  if ("polling_station_id" %in% names(data) && length(unique(data$polling_station_id)) > 1) {
    group_vars <- c(group_vars, "polling_station_id")
  }
  
  # If no grouping variables, compare across all data
  if (length(group_vars) == 0) {
    data <- dplyr::mutate(data, is_elected = votes == max(votes, na.rm = TRUE))
  } else {
    data <- data %>%
      dplyr::group_by(!!!rlang::syms(group_vars)) %>%
      dplyr::mutate(is_elected = votes == max(votes, na.rm = TRUE)) %>%
      dplyr::ungroup()
  }
  
  return(data)
}

#' Calculate recall results based on administrative level
#' 
#' @description
#' This function calculates is_recalled based on the administrative scale
#' represented in the data. Recall success is determined by comparing
#' agree votes (votes) vs disagree votes at each administrative unit.
#' 
#' @param data A data frame containing recall results
#' @return Data frame with is_recalled column added
#' @keywords internal
#' @importFrom dplyr group_by mutate ungroup
tv_calculate_recall_results <- function(data) {
  if (nrow(data) == 0) {
    data$is_recalled <- logical(0)
    return(data)
  }
  
  # For recall elections, is_recalled is simply agree > disagree at each row level
  # This represents whether recall was successful at that polling station/administrative unit
  data <- dplyr::mutate(data, is_recalled = votes > disagree)
  
  return(data)
}

#' Aggregate data and calculate winners based on administrative level
#' 
#' @description
#' This function aggregates election data to the specified administrative level
#' and calculates is_elected based on that level
#' 
#' @param data A data frame containing election results
#' @param adm_level Character. Administrative level for aggregation and winner calculation
#' @return Data frame with is_elected column calculated at specified administrative level
#' @keywords internal
#' @importFrom dplyr group_by summarise ungroup mutate
tv_aggregate_and_calculate_winners <- function(data, adm_level = "polling_station") {
  if (nrow(data) == 0) {
    data$is_elected <- logical(0)
    return(data)
  }
  
  # Define grouping variables based on administrative level
  if (adm_level == "polling_station") {
    # No aggregation needed, calculate winners at polling station level
    group_vars <- c("county", "town", "village", "polling_station_id")
  } else if (adm_level == "village") {
    # Aggregate to village level
    group_vars <- c("county", "town", "village")
  } else if (adm_level == "town") {
    # Aggregate to town level
    group_vars <- c("county", "town")
  } else if (adm_level == "county") {
    # Aggregate to county level
    group_vars <- c("county")
  } else {
    stop("Invalid adm_level: ", adm_level)
  }
  
  # Filter group_vars to only include columns that exist in data
  group_vars <- group_vars[group_vars %in% names(data)]
  
  if (adm_level == "polling_station") {
    # For polling station level, just calculate winners without aggregation
    # But we need to add vote_percentage since it's not in raw CSV files
    data <- data %>%
      dplyr::mutate(
        vote_percentage = dplyr::if_else(total_valid > 0, votes / total_valid * 100, NA_real_)
      )
    
    if (length(group_vars) == 0) {
      data <- dplyr::mutate(data, is_elected = votes == max(votes, na.rm = TRUE))
    } else {
      data <- data %>%
        dplyr::group_by(!!!rlang::syms(group_vars)) %>%
        dplyr::mutate(is_elected = votes == max(votes, na.rm = TRUE)) %>%
        dplyr::ungroup()
    }
  } else {
    # For other levels, aggregate first then calculate winners
    candidate_group_vars <- c(group_vars, "candidate_name", "party")
    
    # Aggregate vote counts
    aggregated_data <- data %>%
      dplyr::group_by(!!!rlang::syms(candidate_group_vars)) %>%
      dplyr::summarise(
        year = dplyr::first(year),
        data_type = dplyr::first(data_type),
        office = dplyr::first(office),
        sub_type = dplyr::first(sub_type),
        votes = sum(votes, na.rm = TRUE),
        invalid = sum(invalid, na.rm = TRUE),
        registered = sum(registered, na.rm = TRUE),
        .groups = "drop"
      )
    
    # Calculate total_valid for each administrative unit
    # For elections: total_valid = sum of all candidates' votes in that unit
    if (length(group_vars) > 0) {
      total_valid_by_unit <- aggregated_data %>%
        dplyr::group_by(!!!rlang::syms(group_vars)) %>%
        dplyr::summarise(total_valid = sum(votes, na.rm = TRUE), .groups = "drop")
      
      aggregated_data <- aggregated_data %>%
        dplyr::left_join(total_valid_by_unit, by = group_vars)
    } else {
      # If no grouping vars, total_valid is sum of all votes
      aggregated_data$total_valid <- sum(aggregated_data$votes, na.rm = TRUE)
    }
    
    # Calculate percentages and rates
    aggregated_data <- aggregated_data %>%
      dplyr::mutate(
        # Ensure total_ballots = total_valid + invalid for consistency
        total_ballots = total_valid + invalid,
        vote_percentage = votes / total_valid * 100,
        turnout_rate = total_ballots / registered * 100
      )
    
    # Add empty columns for lower administrative levels if aggregating
    if (adm_level == "county") {
      aggregated_data$town <- NA_character_
      aggregated_data$village <- NA_character_
      aggregated_data$polling_station_id <- NA_character_
    } else if (adm_level == "town") {
      aggregated_data$village <- NA_character_
      aggregated_data$polling_station_id <- NA_character_
    } else if (adm_level == "village") {
      aggregated_data$polling_station_id <- NA_character_
    }
    
    # Calculate winners at the specified administrative level
    if (length(group_vars) == 0) {
      aggregated_data <- dplyr::mutate(aggregated_data, is_elected = votes == max(votes, na.rm = TRUE))
    } else {
      aggregated_data <- aggregated_data %>%
        dplyr::group_by(!!!rlang::syms(group_vars)) %>%
        dplyr::mutate(is_elected = votes == max(votes, na.rm = TRUE)) %>%
        dplyr::ungroup()
    }
    
    data <- aggregated_data
  }
  
  return(data)
}

#' Aggregate data and calculate recall results based on administrative level
#' 
#' @description
#' This function aggregates recall data to the specified administrative level
#' and calculates is_recalled based on that level
#' 
#' @param data A data frame containing recall results
#' @param adm_level Character. Administrative level for aggregation and recall calculation
#' @return Data frame with is_recalled column calculated at specified administrative level
#' @keywords internal
#' @importFrom dplyr group_by summarise ungroup mutate
tv_aggregate_and_calculate_recall_results <- function(data, adm_level = "polling_station") {
  if (nrow(data) == 0) {
    data$is_recalled <- logical(0)
    return(data)
  }
  
  # Define grouping variables based on administrative level
  if (adm_level == "polling_station") {
    # No aggregation needed, calculate recall results at polling station level
    group_vars <- c("county", "town", "village", "polling_station_id")
  } else if (adm_level == "village") {
    # Aggregate to village level
    group_vars <- c("county", "town", "village")
  } else if (adm_level == "town") {
    # Aggregate to town level
    group_vars <- c("county", "town")
  } else if (adm_level == "county") {
    # Aggregate to county level
    group_vars <- c("county")
  } else {
    stop("Invalid adm_level: ", adm_level)
  }
  
  # Filter group_vars to only include columns that exist in data
  group_vars <- group_vars[group_vars %in% names(data)]
  
  if (adm_level == "polling_station") {
    # For polling station level, just calculate recall results without aggregation
    # But we need to add vote_percentage since it's not in raw CSV files
    data <- data %>%
      dplyr::mutate(
        vote_percentage = dplyr::if_else(total_valid > 0, votes / total_valid * 100, NA_real_),
        is_recalled = votes > disagree
      )
  } else {
    # For other levels, aggregate first then calculate recall results
    candidate_group_vars <- c(group_vars, "candidate_name", "party")
    
    # Aggregate vote counts
    aggregated_data <- data %>%
      dplyr::group_by(!!!rlang::syms(candidate_group_vars)) %>%
      dplyr::summarise(
        year = dplyr::first(year),
        data_type = dplyr::first(data_type),
        office = dplyr::first(office),
        sub_type = dplyr::first(sub_type),
        votes = sum(votes, na.rm = TRUE),  # agree votes
        disagree = sum(disagree, na.rm = TRUE),
        invalid = sum(invalid, na.rm = TRUE),
        not_voted_but_issued = sum(not_voted_but_issued, na.rm = TRUE),
        issued_ballots = sum(issued_ballots, na.rm = TRUE),
        unused_ballots = sum(unused_ballots, na.rm = TRUE),
        registered = sum(registered, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::mutate(
        # For recall: total_valid = agree votes + disagree votes (NOT including invalid)
        total_valid = votes + disagree,
        # Ensure total_ballots = total_valid + invalid for consistency  
        total_ballots = total_valid + invalid,
        vote_percentage = votes / total_valid * 100,
        turnout_rate = total_ballots / registered * 100,
        is_recalled = votes > disagree  # recall successful if agree > disagree
      )
    
    # Add empty columns for lower administrative levels if aggregating
    if (adm_level == "county") {
      aggregated_data$town <- NA_character_
      aggregated_data$village <- NA_character_
      aggregated_data$polling_station_id <- NA_character_
    } else if (adm_level == "town") {
      aggregated_data$village <- NA_character_
      aggregated_data$polling_station_id <- NA_character_
    } else if (adm_level == "village") {
      aggregated_data$polling_station_id <- NA_character_
    }
    
    data <- aggregated_data
  }
  
  return(data)
}

