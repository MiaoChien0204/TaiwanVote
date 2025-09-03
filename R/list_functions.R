#' List available Taiwan recall elections
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
      dplyr::select(.data$year, .data$office, .data$candidate_name, .data$party, .data$county) %>%
      dplyr::distinct() %>%
      dplyr::mutate(
        dplyr::mutate(
        electoral_district = paste0(.data$county, "選舉區")
      )
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
#' @param level Character. The administrative level. Options: "county", "town", "village".
#'
#' @return A tibble with area information including:
#' \describe{
#'   \item{year}{Election year}
#'   \item{office}{Office type}
#'   \item{area_name}{Area name}
#'   \item{level}{Administrative level}
#'   \item{parent_area}{Parent administrative area (for towns and villages)}
#' }
#'
#' @examples
#' \dontrun{
#' # List all counties with recall elections
#' tv_list_available_areas(level = "county")
#' 
#' # List all towns in 2025 recall elections
#' tv_list_available_areas(year = 2025, level = "town")
#' }
#'
#' @export
tv_list_available_areas <- function(year = NULL, office = NULL, level = "county") {
  
  valid_levels <- c("county", "town", "village")
  if (!level %in% valid_levels) {
    stop("level must be one of: ", paste(valid_levels, collapse = ", "))
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
    
    # Extract areas based on level
    if (level == "county") {
      areas <- data %>%
        dplyr::select(.data$year, .data$office, area_name = .data$county) %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          level = "county",
          parent_area = NA_character_
        )
    } else if (level == "town") {
      areas <- data %>%
        dplyr::select(.data$year, .data$office, .data$county, area_name = .data$town) %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          level = "town",
          parent_area = .data$county
        ) %>%
        dplyr::select(-.data$county)
    } else if (level == "village") {
      areas <- data %>%
        dplyr::select(.data$year, .data$office, .data$town, area_name = .data$village) %>%
        dplyr::distinct() %>%
        dplyr::mutate(
          level = "village",
          parent_area = .data$town
        ) %>%
        dplyr::select(-.data$town)
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
      level = character(0),
      parent_area = character(0)
    )
  }
  
  return(result)
}
