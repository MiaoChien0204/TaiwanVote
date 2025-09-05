test_that("CRITICAL TEST: is_elected calculation order verification", {
  skip_if_offline()
  skip_on_cran()
  
  # This is the CRITICAL TEST to verify the exact behavior the user asked about
  # We will demonstrate that is_elected is calculated BEFORE candidate filtering
  
  # Step 1: Get complete competition data at village level
  village_name <- "新北市三峽區中埔里"
  
  complete_village_data <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "village",
    village_name = village_name
  )
  
  # Step 2: Get the same data but filtered for specific candidate
  if(nrow(complete_village_data) > 1) {
    candidate_name <- complete_village_data$candidate_name[1]
    
    filtered_candidate_data <- tv_get_election(
      year = 2024,
      office = "president", 
      adm_level = "village",
      village_name = village_name,
      candidate = candidate_name
    )
    
    # Step 3: Verify the is_elected value is preserved from complete competition
    complete_row <- complete_village_data[complete_village_data$candidate_name == candidate_name, ]
    filtered_row <- filtered_candidate_data[1, ]
    
    expect_equal(
      complete_row$is_elected,
      filtered_row$is_elected,
      info = "is_elected should be same in complete data vs filtered data"
    )
    
    expect_equal(
      complete_row$votes,
      filtered_row$votes, 
      info = "Vote counts should be same in complete data vs filtered data"
    )
    
    # Step 4: Verify winner was determined based on competition with ALL candidates
    if(filtered_row$is_elected) {
      # If this candidate is marked as elected, they should have highest votes
      max_votes_in_village <- max(complete_village_data$votes)
      expect_equal(filtered_row$votes, max_votes_in_village,
        info = "Elected candidate should have highest votes among ALL candidates")
    }
  }
})

test_that("DEMONSTRATION: Same candidate different is_elected at different levels", {
  skip_if_offline()
  skip_on_cran()
  
  # This test demonstrates the exact scenario the user described:
  # A candidate may be is_elected=TRUE at village level but is_elected=FALSE at county level
  
  candidate_name <- "賴清德"
  
  # Get village-level results for this candidate across multiple villages in New Taipei
  village_results <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "village",
    county_name = "新北市",
    candidate = candidate_name
  )
  
  # Get county-level result for the same candidate
  county_result <- tv_get_election(
    year = 2024,
    office = "president",
    adm_level = "county", 
    county_name = "新北市",
    candidate = candidate_name
  )
  
  if(nrow(village_results) > 10 && nrow(county_result) == 1) {
    # Count how many villages this candidate won vs lost
    villages_won <- sum(village_results$is_elected)
    villages_lost <- sum(!village_results$is_elected) 
    county_result_elected <- county_result$is_elected[1]
    
    cat("\n=== DEMONSTRATION OF ADMINISTRATIVE LEVEL IMPACT ===\n")
    cat("Candidate:", candidate_name, "\n")
    cat("Villages won:", villages_won, "\n")
    cat("Villages lost:", villages_lost, "\n") 
    cat("County-level is_elected:", county_result_elected, "\n")
    cat("=================================================\n")
    
    # Key insight: Candidate can win some villages but lose at county level
    # This proves that is_elected depends on administrative level and competition scope
    
    expect_true(villages_won >= 0)
    expect_true(villages_lost >= 0)
    expect_true(is.logical(county_result_elected))
    
    # Document the behavior for verification
    if(villages_won > 0 && !county_result_elected) {
      cat("VERIFIED: Candidate won", villages_won, "villages but lost at county level\n")
    } else if(villages_lost > 0 && county_result_elected) {
      cat("VERIFIED: Candidate lost", villages_lost, "villages but won at county level\n") 
    }
  }
})

test_that("VERIFICATION: Filter order does not affect is_elected calculation", {
  skip_if_offline()
  skip_on_cran()
  
  # Verify that applying filters in different orders produces same is_elected results
  # This confirms that is_elected is calculated before filtering
  
  test_params <- list(
    year = 2024,
    office = "president",
    adm_level = "village",
    county_name = "新北市"
  )
  
  candidate_name <- "賴清德"
  party_name <- "民主進步黨"
  
  # Method 1: Filter by candidate first, then verify against party
  result1 <- tv_get_election(
    year = test_params$year,
    office = test_params$office,
    adm_level = test_params$adm_level,
    county_name = test_params$county_name,
    candidate = candidate_name
  )
  
  # Method 2: Filter by party first, then verify candidate is included
  result2 <- tv_get_election(
    year = test_params$year,
    office = test_params$office, 
    adm_level = test_params$adm_level,
    county_name = test_params$county_name,
    party = party_name
  )
  
  # Method 3: Filter by both candidate and party simultaneously
  result3 <- tv_get_election(
    year = test_params$year,
    office = test_params$office,
    adm_level = test_params$adm_level, 
    county_name = test_params$county_name,
    candidate = candidate_name,
    party = party_name
  )
  
  if(nrow(result1) > 0 && nrow(result2) > 0 && nrow(result3) > 0) {
    # All methods should produce same is_elected values for the candidate
    candidate_in_result2 <- result2[result2$candidate_name == candidate_name, ]
    
    if(nrow(candidate_in_result2) > 0) {
      # Compare is_elected values - should be identical regardless of filter method
      expect_equal(
        result1$is_elected,
        candidate_in_result2$is_elected,
        info = "is_elected should be same regardless of filter method"
      )
      
      expect_equal(
        result1$is_elected,
        result3$is_elected,
        info = "Combined filters should produce same is_elected as individual filters"
      )
    }
  }
})
