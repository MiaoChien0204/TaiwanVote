#' List available Taiwan elections
#'
#' @description
#' Lists all available elections in the TaiwanVote package.
#'
#' @return A tibble with information about available elections including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{sub_type}{Sub-type of election}
#'   \item{description}{Description of the election}
#' }
#'
#' @examples
#' \dontrun{
#' # List all available elections
#' tv_list_available_elections()
#' }
#'
#' @export
tv_list_available_elections <- function() {
  
  # Currently available elections
  elections <- tibble::tibble(
    year = c(2024),
    office = c("president"),
    sub_type = c(NA_character_),
    description = c("2024 總統副總統選舉")
  )
  
  return(elections)
}

#' List available candidates in elections
#'
#' @description
#' Lists all candidates who participated in elections by year and office type.
#'
#' @param year Numeric. The election year. If NULL, returns all years.
#' @param office Character. The office type. If NULL, returns all office types.
#'
#' @return A tibble with candidate information including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{candidate_name}{Candidate name}
#'   \item{party}{Political party}
#'   \item{is_elected}{Whether the candidate was elected}
#' }
#'
#' @examples
#' \dontrun{
#' # List all candidates in elections
#' tv_list_available_election_candidates()
#' 
#' # List candidates for 2024
#' tv_list_available_election_candidates(year = 2024)
#' }
#'
#' @export
tv_list_available_election_candidates <- function(year = NULL, office = NULL) {
  
  # Get all available election data
  all_elections <- tv_list_available_elections()
  
  # Filter by year if specified
  if (!is.null(year)) {
    all_elections <- dplyr::filter(all_elections, .data$year %in% !!year)
  }
  
  # Filter by office if specified  
  if (!is.null(office)) {
    all_elections <- dplyr::filter(all_elections, .data$office %in% !!office)
  }
  
  # Get candidate data for each election
  candidates_list <- list()
  
  for (i in seq_len(nrow(all_elections))) {
    election_info <- all_elections[i, ]
    
    # Load the data
    if (election_info$office == "president") {
      file_name <- paste0(election_info$year, "_president_election.csv")
    } else {
      file_name <- paste0(election_info$year, "_", election_info$office, "_election.csv")
    }
    
    data <- tv_read_data(file_name)
    
    # Apply aggregation to ensure is_elected is calculated
    data <- tv_aggregate_and_calculate_winners(data, "polling_station")
    
    # Extract unique candidates with their info
    candidates <- data %>%
      dplyr::select("year", "office", "candidate_name", "party") %>%
      dplyr::distinct() %>%
      dplyr::left_join(
        data %>%
          dplyr::group_by(.data$candidate_name) %>%
          dplyr::summarise(is_elected = any(.data$is_elected, na.rm = TRUE), .groups = "drop"),
        by = "candidate_name"
      )
    
    candidates_list[[i]] <- candidates
  }
  
  # Combine all candidates
  if (length(candidates_list) > 0) {
    result <- dplyr::bind_rows(candidates_list)
    result <- dplyr::arrange(result, .data$year, .data$candidate_name)
  } else {
    result <- tibble::tibble(
      year = numeric(0),
      office = character(0),
      candidate_name = character(0),
      party = character(0),
      is_elected = logical(0)
    )
  }
  
  return(result)
}

#' List available parties in elections
#'
#' @description
#' Lists all political parties that had candidates in elections.
#'
#' @param year Numeric. The election year. If NULL, returns all years.
#' @param office Character. The office type. If NULL, returns all office types.
#'
#' @return A tibble with party information including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{party}{Political party name}
#'   \item{candidate_count}{Number of candidates from this party}
#'   \item{elected_count}{Number of elected candidates from this party}
#' }
#'
#' @examples
#' \dontrun{
#' # List all parties in elections
#' tv_list_available_election_parties()
#' 
#' # List parties for 2024
#' tv_list_available_election_parties(year = 2024)
#' }
#'
#' @export
tv_list_available_election_parties <- function(year = NULL, office = NULL) {
  
  # Get candidate data
  candidates <- tv_list_available_election_candidates(year = year, office = office)
  
  # Summarize by party
  result <- candidates %>%
    dplyr::group_by(.data$year, .data$office, .data$party) %>%
    dplyr::summarise(
      candidate_count = dplyr::n(),
      elected_count = sum(.data$is_elected, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::arrange(.data$year, .data$party)
  
  return(result)
}

#' List Available Recall Elections
#'
#' @description
#' Lists all available recall elections in the TaiwanVote package.
#'
#' @return A tibble with information about available recall elections including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{sub_type}{Sub-type of election}
#'   \item{description}{Description of the recall election}
#' }
#'
#' @examples
#' \dontrun{
#' # List all available recall elections
#' tv_list_available_recalls()
#' }
#'
#' @export
tv_list_available_recalls <- function() {
  
    # Currently available recall elections
  recalls <- tibble::tibble(
    year = c(2025),
    office = c("legislator"),
    sub_type = c("regional"),
    description = c("2025 立法委員罷免案 (區域立委)")
  )
  
  return(recalls)
}

#' List available candidates in recall elections
#'
#' @description
#' Lists all candidates who faced recall elections by year and office type.
#'
#' @param year Numeric. The election year. If NULL, returns all years.
#' @param office Character. The office type. If NULL, returns all office types.
#'
#' @return A tibble with candidate information including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{candidate_name}{Candidate name}
#'   \item{party}{Political party}
#'   \item{county}{County where recall took place}
#'   \item{electoral_district}{Electoral district description}
#' }
#'
#' @examples
#' \dontrun{
#' # List all candidates in recall elections
#' tv_list_available_candidates()
#' 
#' # List candidates for 2025
#' tv_list_available_candidates(year = 2025)
#' }
#'
#' @export
tv_list_available_candidates <- function(year = NULL, office = NULL) {
  
  # Get all available recall data
  all_recalls <- tv_list_available_recalls()
  
  # Filter by year if specified
  if (!is.null(year)) {
    all_recalls <- dplyr::filter(all_recalls, .data$year %in% !!year)
  }
  
  # Filter by office if specified  
  if (!is.null(office)) {
    all_recalls <- dplyr::filter(all_recalls, .data$office %in% !!office)
  }
  
  # Get candidate data for each recall election
  candidates_list <- list()
  
  for (i in seq_len(nrow(all_recalls))) {
    recall_info <- all_recalls[i, ]
    
    # Load the data
    file_name <- paste0(recall_info$year, "_", recall_info$office, "_recall.csv")
    data <- tv_read_data(file_name)
    
    # Extract unique candidates with their info
    candidates <- data %>%
      dplyr::select("year", "office", "candidate_name", "party", "county") %>%
      dplyr::distinct() %>%
      dplyr::mutate(
        electoral_district = paste0(.data$county, "選舉區")
      )
    
    candidates_list[[i]] <- candidates
  }
  
  # Combine all candidates
  if (length(candidates_list) > 0) {
    result <- dplyr::bind_rows(candidates_list)
    result <- dplyr::arrange(result, .data$year, .data$county, .data$candidate_name)
  } else {
    result <- tibble::tibble(
      year = numeric(0),
      office = character(0),
      candidate_name = character(0),
      party = character(0),
      county = character(0),
      electoral_district = character(0)
    )
  }
  
  return(result)
}

#' List available parties in recall elections
#'
#' @description
#' Lists all political parties that had candidates in recall elections.
#'
#' @param year Numeric. The election year. If NULL, returns all years.
#' @param office Character. The office type. If NULL, returns all office types.
#'
#' @return A tibble with party information including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{party}{Political party name}
#'   \item{candidate_count}{Number of candidates from this party}
#' }
#'
#' @examples
#' \dontrun{
#' # List all parties in recall elections
#' tv_list_available_parties()
#' 
#' # List parties for 2025
#' tv_list_available_parties(year = 2025)
#' }
#'
#' @export
tv_list_available_parties <- function(year = NULL, office = NULL) {
  
  # Get candidate data
  candidates <- tv_list_available_candidates(year = year, office = office)
  
  # Summarize by party
  result <- candidates %>%
    dplyr::group_by(.data$year, .data$office, .data$party) %>%
    dplyr::summarise(
      candidate_count = dplyr::n(),
      .groups = "drop"
    ) %>%
    dplyr::arrange(.data$year, .data$party)
  
  return(result)
}

#' List available areas in recall elections
#'
#' @description
#' Lists all administrative areas (counties, towns, villages) that had recall elections.
#'
#' @param year Numeric. The election year. If NULL, returns all years.
#' @param office Character. The office type. If NULL, returns all office types.
#' @param adm_level Character. The administrative level. Options: "county", "town", "village".
#'
#' @return A tibble with area information including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{area_name}{Area name}
#'   \item{adm_level}{Administrative level}
#'   \item{parent_area}{Parent administrative area (for towns and villages)}
#' }
#'
#' @examples
#' \dontrun{
#' # List all counties with recall elections
#' tv_list_available_areas(adm_level = "county")
#' 
#' # List all towns in 2025 recall elections
#' tv_list_available_areas(year = 2025, adm_level = "town")
#' }
#'
#' @export
tv_list_available_areas <- function(year = NULL, office = NULL, adm_level = "county") {
  
  valid_adm_levels <- c("county", "town", "village")
  if (!adm_level %in% valid_adm_levels) {
    stop("adm_level must be one of: ", paste(valid_adm_levels, collapse = ", "))
  }
  
  # Get all available recall data
  all_recalls <- tv_list_available_recalls()
  
  # Filter by year if specified
  if (!is.null(year)) {
    all_recalls <- dplyr::filter(all_recalls, .data$year %in% !!year)
  }
  
  # Filter by office if specified  
  if (!is.null(office)) {
    all_recalls <- dplyr::filter(all_recalls, .data$office %in% !!office)
  }
  
  # Get area data for each recall election
  areas_list <- list()
  
  for (i in seq_len(nrow(all_recalls))) {
    recall_info <- all_recalls[i, ]
    
    # Load the data
    file_name <- paste0(recall_info$year, "_", recall_info$office, "_recall.csv")
    data <- tv_read_data(file_name)
    
    # Extract areas based on adm_level
    if (adm_level == "county") {
      areas <- data %>%
        dplyr::select("year", "office", area_name = "county") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          adm_level = "county",
          parent_area = NA_character_
        )
    } else if (adm_level == "town") {
      areas <- data %>%
        dplyr::select("year", "office", "county", area_name = "town") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          adm_level = "town",
          parent_area = .data$county
        ) %>%
        dplyr::select(-"county")
    } else if (adm_level == "village") {
      areas <- data %>%
        dplyr::select("year", "office", "town", area_name = "village") %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          adm_level = "village",
          parent_area = .data$town
        ) %>%
        dplyr::select(-"town")
    }
    
    areas_list[[i]] <- areas
  }
  
  # Combine all areas
  if (length(areas_list) > 0) {
    result <- dplyr::bind_rows(areas_list)
    result <- dplyr::arrange(result, .data$year, .data$area_name)
  } else {
    result <- tibble::tibble(
      year = numeric(0),
      office = character(0),
      area_name = character(0),
      adm_level = character(0),
      parent_area = character(0)
    )
  }
  
  return(result)
}
#' @importFrom rlang .data  
#' @importFrom dplyr filter distinct select group_by summarise n
