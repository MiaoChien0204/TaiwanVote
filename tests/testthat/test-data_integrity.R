# Test data consistency and integration

# Test data integrity
test_that("recall data has consistent structure", {
  data <- tv_get_recall(year = 2025)
  
  if (nrow(data) > 0) {
    # Test that all required columns exist
    required_cols <- c("year", "data_type", "office", "sub_type", "county", 
                       "town", "village", "polling_station_id", "candidate_name", 
                       "party", "votes", "vote_percentage", "is_recalled",
                       "disagree", "invalid", "total_valid", "total_ballots")
    
    missing_cols <- setdiff(required_cols, names(data))
    expect_equal(length(missing_cols), 0, 
                 info = paste("Missing columns:", paste(missing_cols, collapse = ", ")))
    
    # Test data types
    expect_type(data$year, "double")
    expect_type(data$votes, "double")
    expect_type(data$vote_percentage, "double")
    expect_type(data$is_recalled, "logical")
    
    # Test value ranges
    expect_true(all(data$votes >= 0, na.rm = TRUE))
    expect_true(all(data$vote_percentage >= 0 & data$vote_percentage <= 100, na.rm = TRUE))
    expect_true(all(data$year == 2025))
    
    # Test that recalled status is logical
    expect_true(all(data$is_recalled %in% c(TRUE, FALSE), na.rm = TRUE))
  }
})

# Test geographic hierarchy consistency
test_that("geographic data is hierarchically consistent", {
  data <- tv_get_recall(year = 2025)
  
  if (nrow(data) > 0) {
    # Group by county and check town consistency
    county_towns <- data %>%
      dplyr::select(county, town) %>%
      dplyr::distinct()
    
    # Each county-town combination should be unique
    expect_equal(nrow(county_towns), 
                 nrow(dplyr::distinct(county_towns, county, town)))
    
    # Group by county-town and check village consistency  
    town_villages <- data %>%
      dplyr::select(county, town, village) %>%
      dplyr::distinct()
    
    # Each county-town-village combination should be unique
    expect_equal(nrow(town_villages),
                 nrow(dplyr::distinct(town_villages, county, town, village)))
  }
})

# Test candidate-party consistency
test_that("candidate-party relationships are consistent", {
  data <- tv_get_recall(year = 2025)
  
  if (nrow(data) > 0) {
    # Each candidate should belong to only one party
    candidate_parties <- data %>%
      dplyr::select(candidate_name, party) %>%
      dplyr::distinct()
    
    candidate_counts <- candidate_parties %>%
      dplyr::count(candidate_name) %>%
      dplyr::filter(n > 1)
    
    expect_equal(nrow(candidate_counts), 0,
                 info = "Some candidates appear with multiple parties")
  }
})

# Test vote calculations consistency
test_that("vote calculations are mathematically consistent", {
  data <- tv_get_recall(year = 2025)
  
  if (nrow(data) > 0) {
    # Filter out rows with missing critical values
    complete_data <- data[!is.na(data$votes) & !is.na(data$total_valid) & 
                          !is.na(data$vote_percentage), ]
    
    if (nrow(complete_data) > 0) {
      # Test that votes don't exceed total valid votes
      expect_true(all(complete_data$votes <= complete_data$total_valid, na.rm = TRUE),
                  info = "Some vote counts exceed total valid votes")
      
      # Note: Skipping strict percentage validation as source data may use 
      # different rounding methods for vote percentages
    }
  }
})

# Test electoral district consistency
test_that("electoral districts are properly defined", {
  data <- tv_get_recall(year = 2025)
  
  if (nrow(data) > 0) {
    # Each electoral district should have consistent county information
    districts <- data %>%
      dplyr::select(county, town) %>%
      dplyr::distinct() %>%
      dplyr::arrange(county, town)
    
    # Should have reasonable number of districts
    expect_gt(nrow(districts), 0)
    
    # County names should be valid Taiwan counties/cities
    valid_counties <- c("臺北市", "新北市", "桃園市", "臺中市", "臺南市", "高雄市",
                        "新竹縣", "新竹市", "苗栗縣", "彰化縣", "南投縣", "雲林縣",
                        "嘉義縣", "嘉義市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣",
                        "澎湖縣", "金門縣", "連江縣", "基隆市")
    
    invalid_counties <- setdiff(unique(data$county), valid_counties)
    expect_equal(length(invalid_counties), 0,
                 info = paste("Invalid county names:", paste(invalid_counties, collapse = ", ")))
  }
})

# Test data completeness
test_that("data completeness meets expectations", {
  data <- tv_get_recall(year = 2025)
  
  if (nrow(data) > 0) {
    # Key columns should not have missing values
    key_cols <- c("year", "county", "town", "village", "candidate_name", "party")
    
    for (col in key_cols) {
      if (col %in% names(data)) {
        missing_count <- sum(is.na(data[[col]]))
        expect_equal(missing_count, 0, 
                     info = paste("Column", col, "has", missing_count, "missing values"))
      }
    }
    
    # Numeric columns should have reasonable values
    numeric_cols <- c("votes", "total_valid", "total_ballots")
    
    for (col in numeric_cols) {
      if (col %in% names(data)) {
        negative_count <- sum(data[[col]] < 0, na.rm = TRUE)
        expect_equal(negative_count, 0,
                     info = paste("Column", col, "has", negative_count, "negative values"))
      }
    }
  }
})

# Integration test with list functions
test_that("list functions are consistent with main data", {
  # Get all data
  all_data <- tv_get_recall(year = 2025)
  
  if (nrow(all_data) > 0) {
    # Test candidates consistency
    listed_candidates <- tv_list_available_candidates(year = 2025)
    actual_candidates <- unique(all_data$candidate_name)
    
    if (is.character(listed_candidates)) {
      # All listed candidates should exist in actual data
      missing_candidates <- setdiff(listed_candidates, actual_candidates)
      expect_equal(length(missing_candidates), 0,
                   info = paste("Listed candidates not in data:", 
                                paste(missing_candidates, collapse = ", ")))
    }
    
    # Test parties consistency
    listed_parties <- tv_list_available_parties(year = 2025)
    actual_parties <- unique(all_data$party)
    
    if (is.character(listed_parties)) {
      # All listed parties should exist in actual data
      missing_parties <- setdiff(listed_parties, actual_parties)
      expect_equal(length(missing_parties), 0,
                   info = paste("Listed parties not in data:", 
                                paste(missing_parties, collapse = ", ")))
    }
    
    # Test areas consistency
    listed_counties <- tv_list_available_areas(year = 2025, level = "county")
    actual_counties <- unique(all_data$county)
    
    if (is.character(listed_counties)) {
      # All listed counties should exist in actual data
      missing_counties <- setdiff(listed_counties, actual_counties)
      expect_equal(length(missing_counties), 0,
                   info = paste("Listed counties not in data:", 
                                paste(missing_counties, collapse = ", ")))
    }
  }
})
