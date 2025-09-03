# Test for tv_get_recall function with new parameter structure

# Test basic functionality
test_that("tv_get_recall returns correct data structure", {
  result <- tv_get_recall(year = 2025)
  
  # Should return a data frame
  expect_s3_class(result, "data.frame")
  
  # Should have expected columns
  expected_cols <- c("year", "data_type", "office", "sub_type", "county", 
                     "town", "village", "polling_station_id", "candidate_name", 
                     "party", "votes", "vote_percentage", "is_recalled")
  expect_true(all(expected_cols %in% names(result)))
  
  # Should have data for 2025
  expect_true(all(result$year == 2025))
  expect_true(all(result$data_type == "recall"))
})

# Test year filtering
test_that("tv_get_recall filters by year correctly", {
  result_2025 <- tv_get_recall(year = 2025)
  
  # All records should be from 2025
  expect_true(all(result_2025$year == 2025))
  expect_gt(nrow(result_2025), 0)
})

# Test county filtering
test_that("tv_get_recall filters by county_name correctly", {
  result <- tv_get_recall(year = 2025, county_name = "新竹市")
  
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(result$county == "新竹市"))
})

# Test town filtering
test_that("tv_get_recall filters by town_name correctly", {
  result <- tv_get_recall(year = 2025, town_name = "新竹市東區")
  
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(result$county == "新竹市"))
  expect_true(all(result$town == "東區"))
})

# Test village filtering
test_that("tv_get_recall filters by village_name correctly", {
  result <- tv_get_recall(year = 2025, village_name = "新竹市東區三民里")
  
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(result$county == "新竹市"))
  expect_true(all(result$town == "東區"))
  expect_true(all(result$village == "三民里"))
})

# Test candidate filtering
test_that("tv_get_recall filters by candidate correctly", {
  # First get a candidate name from the data
  all_data <- tv_get_recall(year = 2025)
  candidate_name <- unique(all_data$candidate_name)[1]
  
  result <- tv_get_recall(year = 2025, candidate = candidate_name)
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(result$candidate_name == candidate_name))
})

# Test party filtering
test_that("tv_get_recall filters by party correctly", {
  # First get a party name from the data  
  all_data <- tv_get_recall(year = 2025)
  party_name <- unique(all_data$party)[1]
  
  result <- tv_get_recall(year = 2025, party = party_name)
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(result$party == party_name))
})

# Test combining filters
test_that("tv_get_recall combines filters correctly", {
  result <- tv_get_recall(year = 2025, county_name = "新竹市", candidate = "鄭正鈐")
  expect_s3_class(result, "data.frame")
  
  if (nrow(result) > 0) {
    expect_true(all(result$county == "新竹市"))
    expect_true(all(result$candidate_name == "鄭正鈐"))
  }
})

# Test multiple values in parameters
test_that("tv_get_recall handles multiple values in parameters", {
  result <- tv_get_recall(year = 2025, county_name = c("新竹市", "桃園市"))
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(result$county %in% c("新竹市", "桃園市")))
})

# Test error handling
test_that("tv_get_recall errors for invalid year", {
  expect_error(tv_get_recall(year = 2020), "Currently only 2025 recall data is available")
})

test_that("tv_get_recall errors for invalid office", {
  expect_error(tv_get_recall(year = 2025, office = "president"), "Currently only 'legislator' office type is supported")
})

test_that("tv_get_recall errors for invalid sub_type", {
  expect_error(tv_get_recall(year = 2025, sub_type = "party"), "Currently only 'regional' sub_type is supported")
})

test_that("tv_get_recall errors for invalid town_name format", {
  expect_error(tv_get_recall(year = 2025, town_name = "東區"), "town_name must include county/city name")
})

test_that("tv_get_recall errors for invalid village_name format", {
  expect_error(tv_get_recall(year = 2025, village_name = "三民里"), "village_name must include full address")
})

test_that("tv_get_recall errors for NULL year", {
  expect_error(tv_get_recall(year = NULL), "Year parameter is required")
})

# Test return value structure
test_that("tv_get_recall returns expected columns", {
  result <- tv_get_recall(year = 2025, county_name = "新竹市")
  expected_cols <- c("year", "data_type", "office", "sub_type", "county", "town", 
                     "village", "polling_station_id", "candidate_name", "party",
                     "votes", "vote_percentage", "is_recalled", "disagree", "invalid",
                     "total_valid", "total_ballots", "not_voted_but_issued", 
                     "issued_ballots", "unused_ballots", "registered", "turnout_rate")
  expect_true(all(expected_cols %in% names(result)))
})

test_that("tv_get_recall returns properly structured data", {
  result <- tv_get_recall(year = 2025, county_name = "新竹市")
  
  expect_gt(nrow(result), 0)
  
  # Test data types
  expect_type(result$year, "double")
  expect_type(result$county, "character")
  expect_type(result$town, "character")
  expect_type(result$village, "character")
  expect_type(result$candidate_name, "character")
  expect_type(result$party, "character")
  expect_type(result$votes, "double")
  expect_type(result$is_recalled, "logical")
  
  # Test for no missing values in key columns
  expect_false(any(is.na(result$year)))
  expect_false(any(is.na(result$county)))
  expect_false(any(is.na(result$candidate_name)))
})

# Integration test - comprehensive query
test_that("tv_get_recall integration test", {
  # Test a comprehensive query that combines multiple filters
  result <- tv_get_recall(year = 2025, town_name = "新竹市東區")
  
  expect_gt(nrow(result), 0)
  
  # Should have consistent data
  expect_true(all(result$year == 2025))
  expect_true(all(result$county == "新竹市"))
  expect_true(all(result$town == "東區"))
  expect_true(all(result$data_type == "recall"))
  expect_true(all(result$office == "legislator"))
  
  # Should have reasonable vote counts
  expect_true(all(result$votes >= 0))
  expect_true(all(result$vote_percentage >= 0 & result$vote_percentage <= 100))
})
