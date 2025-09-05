test_that("tv_aggregate_and_calculate_winners function works correctly", {
  # Create test data
  test_data <- data.frame(
    year = 2024,
    data_type = "election",
    office = "president",
    sub_type = NA_character_,
    county = "新竹市",
    town = "東區",
    village = "三民里",
    polling_station_id = c("0001", "0001", "0002", "0002"),
    candidate_name = c("候選人A", "候選人B", "候選人A", "候選人B"),
    party = c("政黨甲", "政黨乙", "政黨甲", "政黨乙"),
    votes = c(100, 80, 120, 90),
    invalid = c(5, 5, 6, 6),
    total_valid = c(180, 180, 210, 210),
    total_ballots = c(185, 185, 216, 216),
    registered = c(250, 250, 280, 280),
    stringsAsFactors = FALSE
  )
  
  # Test polling station level (default)
  result_station <- tv_aggregate_and_calculate_winners(test_data, "polling_station")
  
  expect_equal(nrow(result_station), 4)
  expect_true(all(c("is_elected") %in% names(result_station)))
  
  # Check that winners are correctly identified at each polling station
  station_0001 <- result_station[result_station$polling_station_id == "0001", ]
  expect_true(station_0001[station_0001$candidate_name == "候選人A", "is_elected"][[1]])
  expect_false(station_0001[station_0001$candidate_name == "候選人B", "is_elected"][[1]])
  
  station_0002 <- result_station[result_station$polling_station_id == "0002", ]
  expect_true(station_0002[station_0002$candidate_name == "候選人A", "is_elected"][[1]])
  expect_false(station_0002[station_0002$candidate_name == "候選人B", "is_elected"][[1]])
  
  # Test village level aggregation
  result_village <- tv_aggregate_and_calculate_winners(test_data, "village")
  
  expect_equal(nrow(result_village), 2)  # Two candidates
  expect_true(all(is.na(result_village$polling_station_id)))
  
  # Check aggregated votes (100+120=220 for A, 80+90=170 for B)
  candidate_a <- result_village[result_village$candidate_name == "候選人A", ]
  candidate_b <- result_village[result_village$candidate_name == "候選人B", ]
  
  expect_equal(candidate_a$votes, 220)
  expect_equal(candidate_b$votes, 170)
  expect_true(candidate_a$is_elected)
  expect_false(candidate_b$is_elected)
})

test_that("tv_aggregate_and_calculate_recall_results function works correctly", {
  # Create test recall data
  test_data <- data.frame(
    year = 2025,
    data_type = "recall",
    office = "legislator",
    sub_type = "regional",
    county = "新竹市",
    town = "東區",
    village = "三民里",
    polling_station_id = c("0001", "0002"),
    candidate_name = c("候選人A", "候選人A"),
    party = c("政黨甲", "政黨甲"),
    votes = c(100, 120),  # agree votes
    disagree = c(80, 90),
    invalid = c(5, 6),
    total_valid = c(185, 216),
    total_ballots = c(190, 222),
    not_voted_but_issued = c(10, 8),
    issued_ballots = c(200, 230),
    unused_ballots = c(10, 8),
    registered = c(250, 280),
    stringsAsFactors = FALSE
  )
  
  # Test polling station level
  result_station <- tv_aggregate_and_calculate_recall_results(test_data, "polling_station")
  
  expect_equal(nrow(result_station), 2)
  expect_true(all(c("is_recalled") %in% names(result_station)))
  
  # Both polling stations should show recall success (agree > disagree)
  expect_true(all(result_station$is_recalled))
  
  # Test village level aggregation
  result_village <- tv_aggregate_and_calculate_recall_results(test_data, "village")
  
  expect_equal(nrow(result_village), 1)  # One candidate aggregated
  expect_equal(result_village$votes, 220)  # 100+120
  expect_equal(result_village$disagree, 170)  # 80+90
  expect_true(result_village$is_recalled)  # 220 > 170
})

test_that("Invalid adm_level parameter throws error", {
  test_data <- data.frame(
    votes = c(100, 80),
    candidate_name = c("A", "B"),
    stringsAsFactors = FALSE
  )
  
  expect_error(
    tv_aggregate_and_calculate_winners(test_data, "invalid_level"),
    "Invalid adm_level"
  )
  
  expect_error(
    tv_aggregate_and_calculate_recall_results(test_data, "invalid_level"),
    "Invalid adm_level"
  )
})

test_that("Empty data handling", {
  empty_data <- data.frame()
  
  result_election <- tv_aggregate_and_calculate_winners(empty_data)
  expect_equal(nrow(result_election), 0)
  expect_true("is_elected" %in% names(result_election))
  
  result_recall <- tv_aggregate_and_calculate_recall_results(empty_data)
  expect_equal(nrow(result_recall), 0)
  expect_true("is_recalled" %in% names(result_recall))
})
