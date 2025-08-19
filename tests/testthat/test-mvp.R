# tests/testthat/test-mvp.R
test_that("tv_get_recall_2025_by_candidate works (village)", {
  skip_on_cran()
  df <- tv_get_recall_2025_by_candidate("鄭正鈐", level = "village")
  expect_true(all(c("county","town","village","agree","total_ballots") %in% names(df)))
  expect_gt(nrow(df), 0)
})

test_that("tv_get_recall_2025_by_candidate works (town)", {
  skip_on_cran()
  df <- tv_get_recall_2025_by_candidate("鄭正鈐", level = "town")
  expect_true(all(!is.na(df$town)))
  expect_true(all(is.na(df$village)))
})

test_that("tv_get_recall_2025_by_area works with town name", {
  skip_on_cran()
  df <- tv_get_recall_2025_by_area("新竹市東區", level = "village", candidate = "鄭正鈐")
  expect_true(all(df$town == "東區"))
})
