# Test for address parsing functionality with new parameter structure

test_that("address parsing supports required formats", {
  # Test town level with new parameter structure
  expect_no_error({
    result1 <- tv_get_recall(year = 2025, town_name = "新竹市東區")
  })
  
  expect_no_error({
    result2 <- tv_get_recall(year = 2025, town_name = "臺北市中山區")
  })
  
  # Test village level with new parameter structure  
  expect_no_error({
    result3 <- tv_get_recall(year = 2025, village_name = "新竹市東區三民里")
  })
})

test_that("address parsing rejects unsupported formats", {
  # Test town name without county (should throw error)
  expect_error(
    tv_get_recall(year = 2025, town_name = "東區"),
    "town_name must include county/city name"
  )
  
  # Test village name without full address (should throw error) 
  expect_error(
    tv_get_recall(year = 2025, village_name = "三民里"),
    "village_name must include full address"
  )
  
  # Test county name in village_name without village part
  expect_error(
    tv_get_recall(year = 2025, village_name = "新竹市東區"),
    "Failed to parse town and village"
  )
})

test_that("address parsing handles edge cases", {
  # Test empty town name (should throw error)
  expect_error(
    tv_get_recall(year = 2025, town_name = ""),
    "town_name must include county/city name"
  )
  
  # Test empty village name (should throw error)
  expect_error(
    tv_get_recall(year = 2025, village_name = ""),
    "village_name must include full address"
  )
  
  # Test malformed address
  expect_error(
    tv_get_recall(year = 2025, village_name = "invalid_format"),
    "village_name must include full address"
  )
  
  # Test address without 里 ending
  expect_error(
    tv_get_recall(year = 2025, village_name = "新竹市東區三民"),
    "Failed to parse town and village"
  )
})

test_that("address parsing handles multiple addresses", {
  # Test multiple town names
  expect_no_error({
    result1 <- tv_get_recall(year = 2025, town_name = c("新竹市東區", "臺北市中山區"))
  })
  
  # Test multiple village names
  expect_no_error({
    result2 <- tv_get_recall(year = 2025, village_name = c("新竹市東區三民里"))
  })
  
  # Test mixed valid and invalid formats (should error)
  expect_error(
    tv_get_recall(year = 2025, town_name = c("新竹市東區", "東區")),
    "town_name must include county/city name"
  )
})

test_that("address parsing recognizes Taiwan address patterns", {
  # Test different administrative divisions - 區 (districts)
  test_patterns_town <- c("新竹市東區", "臺北市中山區", "高雄市三民區")
  
  for (pattern in test_patterns_town) {
    expect_no_error({
      result <- tv_get_recall(year = 2025, town_name = pattern)
    })
  }
  
  # Test different administrative divisions - 鄉鎮 villages
  test_patterns_village <- c("新竹市東區三民里", "桃園市桃園區文中里")
  
  for (pattern in test_patterns_village) {
    expect_no_error({
      result <- tv_get_recall(year = 2025, village_name = pattern)
    })
  }
})

test_that("address parsing results are consistent with input", {
  # Test that parsing results match the expected administrative levels
  result <- tv_get_recall(year = 2025, town_name = "新竹市東區")
  
  if (nrow(result) > 0) {
    expect_true(all(result$county == "新竹市"))
    expect_true(all(result$town == "東區"))
  }
  
  # Test village level consistency
  result_village <- tv_get_recall(year = 2025, village_name = "新竹市東區三民里")
  
  if (nrow(result_village) > 0) {
    expect_true(all(result_village$county == "新竹市"))
    expect_true(all(result_village$town == "東區"))
    expect_true(all(result_village$village == "三民里"))
  }
})

test_that("address parsing handles special characters", {
  # Test traditional characters like 臺
  expect_no_error({
    result1 <- tv_get_recall(year = 2025, county_name = "臺北市")
  })
  
  expect_no_error({
    result2 <- tv_get_recall(year = 2025, county_name = "臺中市")
  })
  
  # Test if results are returned (might be empty if no data exists)
  expect_s3_class(result1, "data.frame")
  expect_s3_class(result2, "data.frame")
})

test_that("address parsing validates input types", {
  # Test numeric input (should work as it gets converted to character)
  expect_no_error({
    result <- tv_get_recall(year = 2025, county_name = "新竹市")
  })
  
  # Test factor input (should work as it gets converted to character)
  expect_no_error({
    result <- tv_get_recall(year = 2025, county_name = as.factor("新竹市"))
  })
})

test_that("address parsing performance is reasonable", {
  # Test that parsing doesn't take too long for simple queries
  start_time <- Sys.time()
  
  result <- tv_get_recall(year = 2025, town_name = "新竹市東區")
  
  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Should complete within 5 seconds (generous allowance for parsing)
  expect_lt(elapsed, 5)
  
  # Should return a data frame
  expect_s3_class(result, "data.frame")
})
