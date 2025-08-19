# R/aggregate.R
# Aggregate village-level rows up to town-level

tv_aggregate_to_town <- function(df) {
  # Expect the village-grain schema produced by your cleaner
  stopifnot(all(c("county","town","agree","disagree","invalid",
                  "total_valid","total_ballots","registered",
                  "issued_ballots","unused_ballots") %in% names(df)))

  df %>%
    dplyr::group_by(candidate, level = "town", county, town) %>%
    dplyr::summarise(
      agree = sum(agree, na.rm = TRUE),
      disagree = sum(disagree, na.rm = TRUE),
      invalid = sum(invalid, na.rm = TRUE),
      total_valid = sum(total_valid, na.rm = TRUE),
      total_ballots = sum(total_ballots, na.rm = TRUE),
      registered = sum(registered, na.rm = TRUE),
      issued_ballots = sum(issued_ballots, na.rm = TRUE),
      unused_ballots = sum(unused_ballots, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      agree_rate = dplyr::if_else(total_valid > 0, agree / total_valid, NA_real_),
      disagree_rate = dplyr::if_else(total_valid > 0, disagree / total_valid, NA_real_),
      turnout_rate = dplyr::if_else(registered > 0, total_ballots / registered, NA_real_),
      village = NA_character_,
      precinct_id = NA_character_
    ) %>%
    dplyr::select(
      candidate, level, county, town, village, precinct_id,
      agree, disagree, invalid, total_valid,
      total_ballots, registered, issued_ballots, unused_ballots,
      agree_rate, disagree_rate, turnout_rate
    )
}
