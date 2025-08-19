# data-raw/01_clean_2025_recall.R
# Purpose: Clean "2025 Legislative Recall" raw xlsx files -> standardized CSV (village level)
# Input : data-raw/raw/*.xlsx
# Output: data-raw/release/2025_legislator_recall.csv


# 行政區別	town	鄉鎮市區，例如「東區」
# 村里別	village	村里名稱，例如「育賢里」
# 投開票所別	precinct_id	投開票所代號（數字編號）
# 同意罷免票數	agree	同意罷免票數
# 不同意罷免票數	disagree	不同意罷免票數
# 有效票數	total_valid	同意 + 不同意
# 無效票數	invalid	作廢票
# 投票人數	total_ballots	投出的票數（有效 + 無效）
# 已領未投票數	not_voted_but_issued	已領票但沒投進票匭
# 發出票數	issued_ballots	發出去的票數（投票人數 + 已領未投）
# 用餘票數	unused_ballots	未發出的票數
# 投票人總數	registered	投票權人數（發出+用餘）
# 投票率 (%)	turnout_rate	投票率（投票人數 ÷ 投票人總數），轉為 0–1 小數



suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(readr)
  library(stringr)
  library(janitor)
  library(cli)
  library(purrr)
})

# ---- Paths ----
in_dir  = "data-raw/raw"
out_dir = "data-raw/release"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ---- Helpers: convert to numeric / normalize Chinese ----
to_num = function(x) {
  # Convert string with commas or blanks to numeric; NA if not valid
  x = as.character(x)
  x = str_replace_all(x, ",", "")
  suppressWarnings(as.numeric(x))
}

norm_zh = function(x) {
  x %>%
    as.character() %>%
    str_replace_all("台", "臺") %>%
    str_squish()
}

# ---- Infer county and candidate from filename ----
infer_county = function(fname) {
  m = str_match(fname, "(?<county>[\\p{Han}]{2,3}(市|縣))")[, "county"]
  ifelse(is.na(m), NA_character_, m)
}

infer_candidate = function(fname) {
  m = str_match(fname, "([\\p{Han}]{2,5})罷免案")[, 2]
  ifelse(is.na(m), NA_character_, m)
}

# ---- Clean one xlsx file ----
clean_one = function(file) {
  cli_h1(basename(file))

  # Skip first 6 header rows, read all as text to avoid type mismatch
  raw = readxl::read_excel(
    file, skip = 6, col_names = FALSE, col_types = "text"
  )

  # Expect 13 columns (A~M). Stop if not 13.
  stopifnot(ncol(raw) == 13)

  # Set column names according to the provided format
  colnames(raw) = c(
    "town", "village", "precinct_id",
    "agree", "disagree", "total_valid", "invalid",
    "total_ballots", "not_voted_but_issued",
    "issued_ballots", "unused_ballots", "registered",
    "turnout_rate_pct"
  )

  raw = raw %>%
    fill(town, .direction = "down")

  county    = infer_county(basename(file))
  candidate = infer_candidate(basename(file))

  # If not detected from filename, leave NA (or manually set later if needed)
  if (is.na(county))    county    = NA_character_
  if (is.na(candidate)) candidate = NA_character_

  df = raw %>%
    mutate(
      across(c(town, village), norm_zh),
      county        = county,
      candidate     = candidate,
      level         = "village",
      precinct_id   = as.character(precinct_id),

      agree               = to_num(agree),
      disagree            = to_num(disagree),
      total_valid         = to_num(total_valid),
      invalid             = to_num(invalid),
      total_ballots       = to_num(total_ballots),
      not_voted_but_issued= to_num(not_voted_but_issued),
      issued_ballots      = to_num(issued_ballots),
      unused_ballots      = to_num(unused_ballots),
      registered          = to_num(registered),
      turnout_rate_pct    = to_num(turnout_rate_pct)
    ) %>%
    # Remove totals and blank rows
    filter(
      !is.na(village),
      village != "",
      !str_detect(village, "總\\s*計")
    ) %>%
    # If turnout_rate is NA, calculate; convert to 0-1 scale
    mutate(
      turnout_rate = ifelse(
        is.na(turnout_rate_pct),
        total_ballots / registered,
        turnout_rate_pct / 100
      ),
      agree_rate    = ifelse(total_valid > 0, agree/total_valid, NA_real_),
      disagree_rate = ifelse(total_valid > 0, disagree/total_valid, NA_real_)
    ) %>%
    select(
      candidate, level,
      county, town, village, precinct_id,
      agree, disagree, invalid, total_valid,
      total_ballots, not_voted_but_issued, issued_ballots, unused_ballots, registered,
      agree_rate, disagree_rate, turnout_rate
    )

  # ---- Basic validation ----
  if (!all(df$total_valid == df$agree + df$disagree, na.rm = TRUE)) {
    cli_warn("Validation: total_valid != agree + disagree")
  }
  if (!all(df$total_ballots == df$total_valid + df$invalid, na.rm = TRUE)) {
    cli_warn("Validation: total_ballots != total_valid + invalid")
  }
  if (!all(df$registered == df$issued_ballots + df$unused_ballots, na.rm = TRUE)) {
    cli_warn("Validation: registered != issued_ballots + unused_ballots")
  }

  df
}

# ---- Main loop: process all files and export CSV ----
files = list.files(in_dir, pattern = "\\.xlsx?$", full.names = TRUE)

if (length(files) == 0L) {
  cli_abort("No source files (*.xlsx) found. Put them into {in_dir}/")
}



all_data = lapply(files, function(file) {
  clean_one(file)
}) %>% bind_rows()

write_csv(all_data, file.path(out_dir, "2025_legislator_recall.csv"))

cli_h1("All done")
