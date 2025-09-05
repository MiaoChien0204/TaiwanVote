test_that("tv_get_recall parameter validation works", {
  # Test missing year parameter
  expect_error(
    tv_get_recall(year = NULL),
    "Year parameter is required"
  )
  
  # Test invalid year
  expect_error(
    tv_get_recall(year = 2024),
    "Currently only 2025 recall data is available"
  )
  
  # Test invalid office
  expect_error(
    tv_get_recall(year = 2025, office = "president"),
    "Currently only 'legislator' office type is supported"
  )
  
  # Test invalid sub_type
  expect_error(
    tv_get_recall(year = 2025, sub_type = "at_large"),
    "Currently only 'regional' sub_type is supported"
  )
  
  # Test invalid adm_level
  expect_error(
    tv_get_recall(year = 2025, adm_level = "invalid"),
    "adm_level must be one of:"
  )
})

test_that("tv_get_recall basic functionality works", {
  skip_if_offline()
  skip_on_cran()
  
  # Test basic recall data retrieval
  result <- tv_get_recall(year = 2025)
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check required columns exist
  required_cols <- c(
    "year", "data_type", "office", "sub_type",
    "county", "town", "village", "polling_station_id",
    "candidate_name", "party", "votes", "vote_percentage",
    "is_recalled", "disagree", "invalid", "total_valid",
    "total_ballots", "registered", "turnout_rate"
  )
  
  expect_true(all(required_cols %in% names(result)))
  
  # Check data types and values
  expect_equal(unique(result$year), 2025)
  expect_equal(unique(result$data_type), "recall")
  expect_equal(unique(result$office), "legislator")
  expect_equal(unique(result$sub_type), "regional")
  expect_true(all(result$party == "中國國民黨"))
})

test_that("tv_get_recall filtering works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test county filtering
  result_county <- tv_get_recall(year = 2025, county_name = "新竹市")
  expect_true(all(result_county$county == "新竹市"))
  
  # Test candidate filtering
  result_candidate <- tv_get_recall(year = 2025, candidate = "鄭正鈐")
  expect_true(all(result_candidate$candidate_name == "鄭正鈐"))
  
  # Test party filtering
  result_party <- tv_get_recall(year = 2025, party = "中國國民黨")
  expect_true(all(result_party$party == "中國國民黨"))
  
  # Test combined filtering
  result_combined <- tv_get_recall(
    year = 2025, 
    county_name = "新竹市", 
    candidate = "鄭正鈐"
  )
  expect_true(all(result_combined$county == "新竹市"))
  expect_true(all(result_combined$candidate_name == "鄭正鈐"))
})

test_that("tv_get_recall adm_level functionality works", {
  skip_if_offline()
  skip_on_cran()
  
  # Test different administrative levels for same candidate
  candidate_name <- "鄭正鈐"
  
  # Polling station level
  result_station <- tv_get_recall(
    year = 2025, 
    candidate = candidate_name, 
    adm_level = "polling_station"
  )
  
  # Village level  
  result_village <- tv_get_recall(
    year = 2025, 
    candidate = candidate_name, 
    adm_level = "village"
  )
  
  # County level
  result_county <- tv_get_recall(
    year = 2025, 
    candidate = candidate_name, 
    adm_level = "county"
  )
  
  # Check row counts (should decrease as we aggregate up)
  expect_true(nrow(result_station) >= nrow(result_village))
  expect_true(nrow(result_village) >= nrow(result_county))
  
  # Check that polling_station_id is NA for aggregated levels
  expect_true(all(is.na(result_village$polling_station_id)))
  expect_true(all(is.na(result_county$polling_station_id)))
  
  # Check that votes are aggregated correctly
  if(nrow(result_station) > 1 && nrow(result_village) == 1) {
    total_station_votes <- sum(result_station$votes, na.rm = TRUE)
    village_votes <- result_village$votes[1]
    expect_equal(total_station_votes, village_votes)
  }
})

test_that("tv_get_recall town and village name parsing works", {
  skip_if_offline()
  skip_on_cran()
  
  # Test town name parsing
  result_town <- tv_get_recall(year = 2025, town_name = "新竹市東區")
  if(nrow(result_town) > 0) {
    expect_true(all(result_town$county == "新竹市"))
    expect_true(all(result_town$town == "東區"))
  }
  
  # Test village name parsing  
  result_village <- tv_get_recall(year = 2025, village_name = "新竹市東區三民里")
  if(nrow(result_village) > 0) {
    expect_true(all(result_village$county == "新竹市"))
    expect_true(all(result_village$town == "東區"))
    expect_true(all(result_village$village == "三民里"))
  }
})

test_that("tv_get_recall error handling for malformed names", {
  # Test malformed town name
  expect_error(
    tv_get_recall(year = 2025, town_name = "東區"),
    "town_name must include county/city name"
  )
  
  # Test malformed village name
  expect_error(
    tv_get_recall(year = 2025, village_name = "三民里"),
    "village_name must include full address"
  )
})
