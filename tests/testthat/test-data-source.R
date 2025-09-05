test_that("tv_read_data function works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  # Test reading recall data
  result <- tv_read_data("2025_legislator_recall.csv")
  
  # Check basic structure
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  
  # Check that required columns exist for recall data
  recall_cols <- c(
    "year", "data_type", "office", "sub_type",
    "county", "town", "village", "polling_station_id",
    "candidate_name", "party", "votes", "disagree"
  )
  expect_true(all(recall_cols %in% names(result)))
  
  # Check data consistency
  expect_equal(unique(result$year), 2025)
  expect_equal(unique(result$data_type), "recall")
  expect_equal(unique(result$office), "legislator")
})

test_that("tv_read_data error handling works", {
  # Test with non-existent file
  expect_error(
    tv_read_data("nonexistent_file.csv"),
    "Failed to download file"
  )
})

test_that("Data consistency checks work", {
  skip_if_offline()
  skip_on_cran()
  
  # Test recall data consistency
  recall_data <- tv_read_data("2025_legislator_recall.csv")
  
  # Check that all parties are 中國國民黨
  expect_true(all(recall_data$party == "中國國民黨"))
  
  # Check that votes and disagree are non-negative
  expect_true(all(recall_data$votes >= 0, na.rm = TRUE))
  expect_true(all(recall_data$disagree >= 0, na.rm = TRUE))
  
  # Check that total_valid correctly equals votes + disagree for recall data
  # For recall: total_valid should be agree votes + disagree votes (NOT including invalid)
  total_check <- with(recall_data, votes + disagree)
  diff <- abs(total_check - recall_data$total_valid)
  max_diff <- max(diff, na.rm = TRUE)
  cat("Maximum difference between calculated and recorded total_valid:", max_diff, "\n")
  
  # Now the calculation should be exact
  expect_true(max_diff < 0.01, 
    info = sprintf("Maximum difference %f should be less than 0.01", max_diff))
  
  # Check that total_ballots = total_valid + invalid
  ballots_check <- with(recall_data, total_valid + invalid)
  ballots_diff <- abs(ballots_check - recall_data$total_ballots)
  max_ballots_diff <- max(ballots_diff, na.rm = TRUE)
  cat("Maximum difference between calculated and recorded total_ballots:", max_ballots_diff, "\n")
  
  expect_true(max_ballots_diff < 0.01,
    info = sprintf("total_ballots difference %f should be less than 0.01", max_ballots_diff))
  
  # Check that registered >= total_ballots
  expect_true(all(recall_data$registered >= recall_data$total_ballots, na.rm = TRUE))
})
