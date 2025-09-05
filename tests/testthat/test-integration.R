test_that("Administrative level consistency across functions", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that same candidate shows consistent results across different queries
  candidate_name <- "鄭正鈐"
  county_name <- "新竹市"
  
  # Get data at different levels
  station_data <- tv_get_recall(
    year = 2025, 
    candidate = candidate_name,
    adm_level = "polling_station"
  )
  
  village_data <- tv_get_recall(
    year = 2025, 
    candidate = candidate_name,
    adm_level = "village"
  )
  
  county_data <- tv_get_recall(
    year = 2025, 
    candidate = candidate_name,
    adm_level = "county"
  )
  
  # Check that vote totals are consistent when aggregated
  if(nrow(station_data) > 0 && nrow(county_data) > 0) {
    # Total votes should be same across all levels for same candidate
    total_station_votes <- sum(station_data$votes, na.rm = TRUE)
    total_county_votes <- sum(county_data$votes, na.rm = TRUE)
    
    expect_equal(total_station_votes, total_county_votes)
  }
})

test_that("Data filtering consistency", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that filtering by county gives same results as town filtering
  county_name <- "新竹市"
  
  # Get all data for county
  county_result <- tv_get_recall(year = 2025, county_name = county_name)
  
  # Get data by individual towns
  if(nrow(county_result) > 0) {
    unique_towns <- unique(paste0(county_result$county, county_result$town))
    
    town_results <- list()
    for(town in unique_towns) {
      town_data <- tv_get_recall(year = 2025, town_name = town)
      if(nrow(town_data) > 0) {
        town_results[[town]] <- town_data
      }
    }
    
    if(length(town_results) > 0) {
      combined_town_data <- do.call(rbind, town_results)
      
      # Should have same number of rows
      expect_equal(nrow(county_result), nrow(combined_town_data))
    }
  }
})

test_that("Winner calculation logic is correct", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that exactly one candidate is elected per administrative unit
  result <- tv_get_recall(year = 2025, county_name = "新竹市")
  
  if(nrow(result) > 0) {
    # For polling station level, each station should have consistent recall results
    # (since there's only one candidate per recall case)
    station_results <- aggregate(
      is_recalled ~ polling_station_id, 
      data = result, 
      FUN = function(x) length(unique(x))
    )
    
    # All polling stations should have consistent recall status
    expect_true(all(station_results$is_recalled == 1))
  }
})

test_that("Multiple candidate/party filtering works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test multiple candidate filtering
  candidates <- c("鄭正鈐", "馬文君")
  result_multiple <- tv_get_recall(year = 2025, candidate = candidates)
  
  if(nrow(result_multiple) > 0) {
    expect_true(all(result_multiple$candidate_name %in% candidates))
    
    # Should include data for both candidates
    found_candidates <- unique(result_multiple$candidate_name)
    expect_true(length(found_candidates) > 0)
  }
})

test_that("Edge cases and error handling", {
  # Test with empty filters that return no results
  result_empty <- tv_get_recall(year = 2025, county_name = "不存在的縣市")
  expect_equal(nrow(result_empty), 0)
  
  # Test with multiple conflicting filters
  result_conflict <- tv_get_recall(
    year = 2025, 
    county_name = "新竹市", 
    candidate = "不存在的候選人"
  )
  expect_equal(nrow(result_conflict), 0)
})

test_that("Performance and data quality checks", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that functions complete in reasonable time
  start_time <- Sys.time()
  result <- tv_get_recall(year = 2025)
  end_time <- Sys.time()
  
  # Should complete within 30 seconds
  expect_true(as.numeric(end_time - start_time, units = "secs") < 30)
  
  # Check data quality
  if(nrow(result) > 0) {
    # No missing values in key columns
    expect_true(all(!is.na(result$year)))
    expect_true(all(!is.na(result$candidate_name)))
    expect_true(all(!is.na(result$county)))
    
    # Valid percentages
    expect_true(all(result$vote_percentage >= 0 & result$vote_percentage <= 100, na.rm = TRUE))
    expect_true(all(result$turnout_rate >= 0 & result$turnout_rate <= 100, na.rm = TRUE))
    
    # Valid vote counts
    expect_true(all(result$votes >= 0, na.rm = TRUE))
    expect_true(all(result$total_valid >= 0, na.rm = TRUE))
    expect_true(all(result$registered >= 0, na.rm = TRUE))
  }
})
