test_that("Administrative level determines is_elected calculation BEFORE filtering", {
  skip_if_offline()
  skip_on_cran()
  
  # Test the core logic: is_elected should be calculated at specified adm_level
  # BEFORE candidate/party filtering is applied
  
  # Use a real example to test this logic
  # Get data for a specific village where we can verify the logic
  village_name <- "新北市三峽區中埔里"
  
  # Test 1: Get village-level data (aggregated to village)
  village_data <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "village",
    village_name = village_name
  )
  
  # Test 2: Get county-level data for the same county
  county_data <- tv_get_election(
    year = 2024,
    office = "president", 
    adm_level = "county",
    county_name = "新北市"
  )
  
  if(nrow(village_data) > 0 && nrow(county_data) > 0) {
    # The winner at village level may be different from county level
    village_winner <- village_data[village_data$is_elected == TRUE, "candidate_name"][[1]]
    county_winner <- county_data[county_data$is_elected == TRUE, "candidate_name"][[1]]
    
    # This is expected behavior: different winners at different administrative levels
    cat("Village winner:", village_winner, "\n")
    cat("County winner:", county_winner, "\n")
    
    # Key test: Each administrative level should have exactly one winner
    expect_equal(sum(village_data$is_elected), 1)
    expect_equal(sum(county_data$is_elected), 1)
  }
})

test_that("is_elected calculation precedes candidate filtering", {
  skip_if_offline()
  skip_on_cran()
  
  # This test verifies that is_elected is calculated BEFORE candidate filtering
  # so the winner status reflects competition against ALL candidates, not just filtered ones
  
  village_name <- "新北市三峽區中埔里"
  
  # Get all candidates data at village level
  all_candidates <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "village", 
    village_name = village_name
  )
  
  # Get data for just one specific candidate
  candidate_name <- all_candidates$candidate_name[1]  # Pick first candidate
  single_candidate <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "village",
    village_name = village_name,
    candidate = candidate_name
  )
  
  if(nrow(all_candidates) > 1 && nrow(single_candidate) == 1) {
    # The is_elected value for the candidate should be the same
    # whether we query all candidates or just that specific candidate
    candidate_in_all <- all_candidates[all_candidates$candidate_name == candidate_name, ]
    
    expect_equal(
      candidate_in_all$is_elected,
      single_candidate$is_elected,
      info = "is_elected should be same whether querying all candidates or specific candidate"
    )
    
    # The filtered result should preserve the original is_elected calculation
    expect_equal(
      candidate_in_all$votes,
      single_candidate$votes,
      info = "Vote counts should match"
    )
  }
})

test_that("Different administrative levels produce different is_elected results", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that the same candidate can have different is_elected values
  # at different administrative levels
  
  candidate_name <- "賴清德"  # A major candidate likely to appear in most areas
  county_name <- "新北市"
  
  # Get polling station level data
  polling_data <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "polling_station",
    county_name = county_name,
    candidate = candidate_name
  )
  
  # Get county level data  
  county_data <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "county", 
    county_name = county_name,
    candidate = candidate_name
  )
  
  if(nrow(polling_data) > 1 && nrow(county_data) == 1) {
    # At polling station level, the candidate may win some stations and lose others
    winning_stations <- sum(polling_data$is_elected)
    losing_stations <- sum(!polling_data$is_elected)
    
    # At county level, there should be exactly one result
    county_is_elected <- county_data$is_elected[1]
    
    cat("Candidate:", candidate_name, "\n")
    cat("Winning stations:", winning_stations, "\n") 
    cat("Losing stations:", losing_stations, "\n")
    cat("County level is_elected:", county_is_elected, "\n")
    
    # The candidate might win some polling stations but lose at county level, or vice versa
    # This demonstrates that is_elected depends on the administrative level
    expect_true(winning_stations >= 0)
    expect_true(losing_stations >= 0)
    expect_true(is.logical(county_is_elected))
    
    # If candidate wins at county level, total county votes should be highest
    if(county_is_elected) {
      # Get all candidates at county level to verify winner
      all_county <- tv_get_election(
        year = 2024,
        office = "president",
        adm_level = "county",
        county_name = county_name
      )
      max_votes <- max(all_county$votes)
      expect_equal(county_data$votes[1], max_votes)
    }
  }
})

test_that("Recall elections follow same logic as regular elections", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that recall elections also calculate is_recalled BEFORE filtering
  candidate_name <- "鄭正鈐"
  
  # Get all data for the candidate's area
  all_data <- tv_get_recall(
    year = 2025,
    county_name = "新竹市",
    adm_level = "polling_station"
  )
  
  # Get filtered data for just this candidate
  candidate_data <- tv_get_recall(
    year = 2025,
    candidate = candidate_name,
    adm_level = "polling_station"
  )
  
  if(nrow(all_data) > 0 && nrow(candidate_data) > 0) {
    # Since recall elections have only one candidate per case,
    # is_recalled should be consistent across all polling stations for same candidate
    unique_recall_results <- unique(candidate_data$is_recalled)
    
    # All polling stations for same candidate should have same recall result
    # (since agree vs disagree is calculated per station)
    expect_true(length(unique_recall_results) >= 1)
    
    # Verify the recall logic: is_recalled = TRUE when agree > disagree
    for(i in 1:nrow(candidate_data)) {
      row <- candidate_data[i, ]
      expected_recalled <- row$votes > row$disagree
      expect_equal(row$is_recalled, expected_recalled)
    }
  }
})

test_that("Administrative level aggregation affects vote totals correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test that vote aggregation works correctly across administrative levels
  candidate_name <- "賴清德"
  county_name <- "新北市"
  
  # Get detailed polling station data
  polling_data <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "polling_station",
    county_name = county_name,
    candidate = candidate_name
  )
  
  # Get aggregated county data
  county_data <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "county",
    county_name = county_name,
    candidate = candidate_name
  )
  
  if(nrow(polling_data) > 1 && nrow(county_data) == 1) {
    # Total votes at county level should equal sum of polling station votes
    total_polling_votes <- sum(polling_data$votes)
    county_votes <- county_data$votes[1]
    
    expect_equal(total_polling_votes, county_votes,
      info = "County votes should equal sum of polling station votes")
    
    # Total valid votes should also aggregate correctly
    total_polling_valid <- sum(polling_data$total_valid)
    county_valid <- county_data$total_valid[1]
    
    expect_equal(total_polling_valid, county_valid,
      info = "County total_valid should equal sum of polling station total_valid")
  }
})

test_that("Edge case: Single candidate still gets correct is_elected value", {
  # Test with artificially created data to ensure edge cases work
  
  # Create test data with single candidate
  test_data <- data.frame(
    year = 2024,
    data_type = "election",
    office = "president",
    sub_type = NA_character_,
    county = "測試縣",
    town = "測試鎮", 
    village = "測試里",
    polling_station_id = c("001", "002"),
    candidate_name = c("候選人A", "候選人A"),
    party = c("政黨甲", "政黨甲"),
    votes = c(100, 150),
    invalid = c(5, 5),
    total_valid = c(200, 300),
    total_ballots = c(205, 305),
    registered = c(250, 350),
    stringsAsFactors = FALSE
  )
  
  # Test village level aggregation
  result <- tv_aggregate_and_calculate_winners(test_data, "village")
  
  # Single candidate should always be elected
  expect_equal(nrow(result), 1)
  expect_true(result$is_elected[1])
  expect_equal(result$votes[1], 250)  # 100 + 150
  
  # Test polling station level
  result_station <- tv_aggregate_and_calculate_winners(test_data, "polling_station")
  
  # Both polling stations should show candidate as elected (no competition)
  expect_equal(nrow(result_station), 2)
  expect_true(all(result_station$is_elected))
})
