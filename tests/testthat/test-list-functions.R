test_that("tv_list_available_recalls works correctly", {
  result <- tv_list_available_recalls()
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check required columns
  required_cols <- c("year", "office", "sub_type", "description")
  expect_true(all(required_cols %in% names(result)))
  
  # Check that 2025 legislator recall is included
  expect_true(2025 %in% result$year)
  expect_true("legislator" %in% result$office)
  expect_true("regional" %in% result$sub_type)
})

test_that("tv_list_available_elections works correctly", {
  result <- tv_list_available_elections()
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check required columns
  required_cols <- c("year", "office", "sub_type", "description")
  expect_true(all(required_cols %in% names(result)))
  
  # Check that 2024 president election is included
  expect_true(2024 %in% result$year)
  expect_true("president" %in% result$office)
})

test_that("tv_list_available_candidates works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test without parameters
  result <- tv_list_available_candidates()
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check required columns
  required_cols <- c("year", "office", "candidate_name", "party", "county", "electoral_district")
  expect_true(all(required_cols %in% names(result)))
  
  # Test with year filter
  result_2025 <- tv_list_available_candidates(year = 2025)
  expect_true(all(result_2025$year == 2025))
  
  # Test with office filter
  result_legislator <- tv_list_available_candidates(office = "legislator")
  expect_true(all(result_legislator$office == "legislator"))
  
  # Test with both filters
  result_filtered <- tv_list_available_candidates(year = 2025, office = "legislator")
  expect_true(all(result_filtered$year == 2025))
  expect_true(all(result_filtered$office == "legislator"))
})

test_that("tv_list_available_election_candidates works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test without parameters
  result <- tv_list_available_election_candidates()
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  
  # Check required columns
  required_cols <- c("year", "office", "candidate_name", "party", "is_elected")
  expect_true(all(required_cols %in% names(result)))
  
  # Test with year filter
  result_2024 <- tv_list_available_election_candidates(year = 2024)
  if(nrow(result_2024) > 0) {
    expect_true(all(result_2024$year == 2024))
  }
})

test_that("tv_list_available_parties works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test without parameters
  result <- tv_list_available_parties()
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check required columns
  required_cols <- c("year", "office", "party", "candidate_count")
  expect_true(all(required_cols %in% names(result)))
  
  # Check that candidate_count is positive
  expect_true(all(result$candidate_count > 0))
  
  # Test with filters
  result_2025 <- tv_list_available_parties(year = 2025)
  expect_true(all(result_2025$year == 2025))
})

test_that("tv_list_available_election_parties works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test without parameters
  result <- tv_list_available_election_parties()
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  
  # Check required columns
  required_cols <- c("year", "office", "party", "candidate_count", "elected_count")
  expect_true(all(required_cols %in% names(result)))
  
  # Check that counts are non-negative
  expect_true(all(result$candidate_count >= 0))
  expect_true(all(result$elected_count >= 0))
  expect_true(all(result$elected_count <= result$candidate_count))
})

test_that("tv_list_available_areas works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test county level (default)
  result_county <- tv_list_available_areas()
  
  # Check basic structure
  expect_s3_class(result_county, "data.frame")
  expect_true(nrow(result_county) > 0)
  
  # Check required columns
  required_cols <- c("year", "office", "area_name", "adm_level", "parent_area")
  expect_true(all(required_cols %in% names(result_county)))
  
  # Check that all are county level
  expect_true(all(result_county$adm_level == "county"))
  expect_true(all(is.na(result_county$parent_area)))
  
  # Test town level
  result_town <- tv_list_available_areas(adm_level = "town")
  if(nrow(result_town) > 0) {
    expect_true(all(result_town$adm_level == "town"))
    expect_true(all(!is.na(result_town$parent_area)))
  }
  
  # Test village level
  result_village <- tv_list_available_areas(adm_level = "village")
  if(nrow(result_village) > 0) {
    expect_true(all(result_village$adm_level == "village"))
    expect_true(all(!is.na(result_village$parent_area)))
  }
  
  # Test with filters
  result_filtered <- tv_list_available_areas(year = 2025, office = "legislator")
  expect_true(all(result_filtered$year == 2025))
  expect_true(all(result_filtered$office == "legislator"))
})

test_that("tv_list_available_areas parameter validation works", {
  # Test invalid adm_level
  expect_error(
    tv_list_available_areas(adm_level = "invalid"),
    "adm_level must be one of:"
  )
})
