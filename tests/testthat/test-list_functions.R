# Test for list functions

# Test tv_list_available_recalls
test_that("tv_list_available_recalls works correctly", {
  result <- tv_list_available_recalls()
  
  # Should return a data frame
  expect_s3_class(result, "data.frame")
  
  # Should have expected columns
  expect_true("year" %in% names(result))
  expect_true("description" %in% names(result))
  
  # Should include 2025 data
  expect_true(2025 %in% result$year)
  
  # Description should be in Chinese
  descriptions <- result$description
  expect_true(any(grepl("立法委員", descriptions)))
  expect_true(any(grepl("罷免", descriptions)))
})

# Test tv_list_available_candidates
test_that("tv_list_available_candidates works correctly", {
  result <- tv_list_available_candidates(year = 2025)
  
  # Should return a character vector or data frame
  expect_true(is.character(result) || is.data.frame(result))
  
  if (is.character(result)) {
    expect_gt(length(result), 0)
    # Should include known candidates
    expect_true(any(grepl("馬文君|鄭正鈐|羅智強", result)))
  }
  
  if (is.data.frame(result)) {
    expect_gt(nrow(result), 0)
    expect_true("candidate_name" %in% names(result))
  }
})

# Test tv_list_available_parties
test_that("tv_list_available_parties works correctly", {
  result <- tv_list_available_parties(year = 2025)
  
  # Should return a character vector or data frame
  expect_true(is.character(result) || is.data.frame(result))
  
  if (is.character(result)) {
    expect_gt(length(result), 0)
    # Should include major parties
    expect_true(any(grepl("中國國民黨|民主進步黨", result)))
  }
  
  if (is.data.frame(result)) {
    expect_gt(nrow(result), 0)
    expect_true("party" %in% names(result))
  }
})

# Test tv_list_available_areas
test_that("tv_list_available_areas works correctly", {
  # Test county level
  result_county <- tv_list_available_areas(year = 2025, level = "county")
  expect_true(is.character(result_county) || is.data.frame(result_county))
  
  if (is.character(result_county)) {
    expect_gt(length(result_county), 0)
    expect_true(any(grepl("新竹市|臺北市|桃園市", result_county)))
  }
  
  # Test town level  
  result_town <- tv_list_available_areas(year = 2025, level = "town")
  expect_true(is.character(result_town) || is.data.frame(result_town))
  
  if (is.character(result_town)) {
    expect_gt(length(result_town), 0)
    expect_true(any(grepl("東區|中山區", result_town)))
  }
  
  # Test village level
  result_village <- tv_list_available_areas(year = 2025, level = "village")
  expect_true(is.character(result_village) || is.data.frame(result_village))
  
  if (is.character(result_village)) {
    expect_gt(length(result_village), 0)
    expect_true(any(grepl("里$", result_village)))  # Should end with 里
  }
})

# Test error handling for list functions
test_that("list functions handle invalid inputs", {
  # Test invalid level - should throw error
  expect_error(
    tv_list_available_areas(year = 2025, level = "invalid"),
    "level must be one of:"
  )
})

# Test list functions return reasonable data
test_that("list functions return reasonable data", {
  # Test that candidates are unique
  candidates <- tv_list_available_candidates(year = 2025)
  if (is.character(candidates)) {
    expect_equal(length(candidates), length(unique(candidates)))
  }
  
  # Test that parties are unique
  parties <- tv_list_available_parties(year = 2025)
  if (is.character(parties)) {
    expect_equal(length(parties), length(unique(parties)))
  }
  
  # Test that areas are unique
  areas <- tv_list_available_areas(year = 2025, level = "county")
  if (is.character(areas)) {
    expect_equal(length(areas), length(unique(areas)))
  }
})
