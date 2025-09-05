test_that("tv_get_election parameter validation works", {
  # Test missing year parameter
  expect_error(
    tv_get_election(year = NULL),
    "Year parameter is required"
  )
  
  # Test missing office parameter  
  expect_error(
    tv_get_election(year = 2024, office = NULL),
    "Office parameter is required"
  )
  
  # Test invalid adm_level
  expect_error(
    tv_get_election(year = 2024, office = "president", adm_level = "invalid"),
    "adm_level must be one of:"
  )
})

test_that("tv_get_election basic functionality works", {
  skip_if_offline()
  skip_on_cran()
  
  # Test basic election data retrieval
  result <- tv_get_election(year = 2024, office = "president")
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check required columns exist
  required_cols <- c(
    "year", "data_type", "office", "sub_type",
    "county", "town", "village", "polling_station_id",
    "candidate_name", "party", "votes", "vote_percentage",
    "is_elected", "invalid", "total_valid",
    "total_ballots", "registered", "turnout_rate"
  )
  
  expect_true(all(required_cols %in% names(result)))
  
  # Check data types and values
  expect_equal(unique(result$year), 2024)
  expect_equal(unique(result$data_type), "election")
  expect_equal(unique(result$office), "president")
})

test_that("tv_get_election filtering works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test county filtering
  result_county <- tv_get_election(
    year = 2024, 
    office = "president", 
    county_name = "新竹市"
  )
  expect_true(all(result_county$county == "新竹市"))
  
  # Test candidate filtering
  result_candidate <- tv_get_election(
    year = 2024, 
    office = "president", 
    candidate = "賴清德"
  )
  expect_true(all(result_candidate$candidate_name == "賴清德"))
  
  # Test party filtering
  result_party <- tv_get_election(
    year = 2024, 
    office = "president", 
    party = "民主進步黨"
  )
  expect_true(all(result_party$party == "民主進步黨"))
  
  # Test multiple candidate filtering
  result_multiple <- tv_get_election(
    year = 2024, 
    office = "president", 
    candidate = c("賴清德", "侯友宜")
  )
  expect_true(all(result_multiple$candidate_name %in% c("賴清德", "侯友宜")))
})

test_that("tv_get_election adm_level functionality works", {
  skip_if_offline()
  skip_on_cran()
  
  # Test different administrative levels
  county_name <- "新竹市"
  
  # Polling station level (default)
  result_station <- tv_get_election(
    year = 2024, 
    office = "president", 
    county_name = county_name,
    adm_level = "polling_station"
  )
  
  # Village level
  result_village <- tv_get_election(
    year = 2024, 
    office = "president", 
    county_name = county_name,
    adm_level = "village"
  )
  
  # County level
  result_county <- tv_get_election(
    year = 2024, 
    office = "president", 
    county_name = county_name,
    adm_level = "county"
  )
  
  # Check row counts (should decrease as we aggregate up)
  expect_true(nrow(result_station) >= nrow(result_village))
  expect_true(nrow(result_village) >= nrow(result_county))
  
  # Check that polling_station_id is NA for aggregated levels
  expect_true(all(is.na(result_village$polling_station_id)))
  expect_true(all(is.na(result_county$polling_station_id)))
  
  # Check that exactly one candidate is elected per administrative unit
  # For polling station level
  if(nrow(result_station) > 0) {
    elected_per_station <- aggregate(
      is_elected ~ polling_station_id, 
      data = result_station, 
      FUN = sum
    )
    # Allow for ties: each polling station should have at least 1 winner
    # In case of ties, multiple candidates may be marked as elected
    expect_true(all(elected_per_station$is_elected >= 1))  # At least one winner per station
    
    # Check that ties are handled correctly
    ties <- elected_per_station[elected_per_station$is_elected > 1, ]
    if(nrow(ties) > 0) {
      cat("Found", nrow(ties), "polling stations with ties\n")
      # Verify ties are legitimate (same vote count)
      for(station_id in ties$polling_station_id[1:min(3, nrow(ties))]) {
        station_data <- result_station[result_station$polling_station_id == station_id, ]
        elected_votes <- station_data[station_data$is_elected, "votes"]
        expect_true(length(unique(elected_votes)) == 1, 
          info = paste("All elected candidates in station", station_id, "should have same vote count"))
      }
    }
  }
  
  # For county level
  if(nrow(result_county) > 0) {
    elected_per_county <- aggregate(
      is_elected ~ county, 
      data = result_county, 
      FUN = sum
    )
    expect_true(all(elected_per_county$is_elected == 1))
  }
})

test_that("tv_get_election town and village name parsing works", {
  skip_if_offline()
  skip_on_cran()
  
  # Test town name parsing
  result_town <- tv_get_election(
    year = 2024, 
    office = "president", 
    town_name = "新竹市東區"
  )
  if(nrow(result_town) > 0) {
    expect_true(all(result_town$county == "新竹市"))
    expect_true(all(result_town$town == "東區"))
  }
  
  # Test village name parsing
  result_village <- tv_get_election(
    year = 2024, 
    office = "president", 
    village_name = "新竹市東區三民里"
  )
  if(nrow(result_village) > 0) {
    expect_true(all(result_village$county == "新竹市"))
    expect_true(all(result_village$town == "東區"))
    expect_true(all(result_village$village == "三民里"))
  }
})

test_that("tv_get_election error handling for malformed names", {
  # Test malformed town name
  expect_error(
    tv_get_election(year = 2024, office = "president", town_name = "東區"),
    "town_name must include county/city name"
  )
  
  # Test malformed village name
  expect_error(
    tv_get_election(year = 2024, office = "president", village_name = "三民里"),
    "village_name must include full address"
  )
})
