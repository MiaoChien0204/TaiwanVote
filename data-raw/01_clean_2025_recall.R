# data-raw/01_clean_2025_recall.R
# Purpose: Clean "2025 Legislative Recall" raw xlsx files -> standardized CSV (village level)
# Input : data-raw/raw/*.xlsx
# Output: data-raw/release/2025_legislator_recall.csv

# Output columns aligned with README2.md vision:
# year, data_type, office, sub_type, county, town, village, polling_station_id,
# candidate_name, party, votes, vote_percentage, is_recalled,
# disagree, invalid, total_valid, total_ballots, not_voted_but_issued,
# issued_ballots, unused_ballots, registered, turnout_rate



suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(janitor)
  library(cli)
  library(purrr)
})

# ---- Paths ----
in_dir  = "data-raw/raw/2025_recall"
out_dir = "data-raw/release"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ---- 2025 Recall Candidate-Party Mapping ----
candidate_party_mapping = tibble(
  candidate_name = c(
    "馬文君", "游顥", "林沛祥", "羅明才", "廖先翔", "洪孟楷", "葉元之", "張智倫", "林德福",
    "鄭正鈐", "林思銘", "牛煦庭", "涂權吉", "魯明哲", "萬美玲", "呂玉玲", "邱若華",
    "顏寬恒", "楊瓊瓔", "廖偉翔", "黃健豪", "羅廷瑋", "江啟臣", "王鴻薇", "李彥秀",
    "羅智強", "徐巧芯", "賴士葆", "黃建賓", "傅崐萁", "丁學忠"
  ),
  party = rep("中國國民黨", 31)
)

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

# ---- Infer county, candidate and determine office/sub_type ----
infer_county = function(fname) {
  m = str_match(fname, "(?<county>[\\p{Han}]{2,3}(市|縣))")[, "county"]
  ifelse(is.na(m), NA_character_, m)
}

infer_candidate = function(fname) {
  m = str_match(fname, "([\\p{Han}]{2,5})罷免案")[, 2]
  ifelse(is.na(m), NA_character_, m)
}

determine_office_subtype = function(fname) {
  # All 2025 recall are legislator/regional based on current data
  list(office = "legislator", sub_type = "regional")
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
  office_info = determine_office_subtype(basename(file))

  # If not detected from filename, leave NA (or manually set later if needed)
  if (is.na(county))    county    = NA_character_
  if (is.na(candidate)) candidate = NA_character_

  df = raw %>%
    mutate(
      across(c(town, village), norm_zh),

      # Core identification columns (README2.md vision)
      year = 2025,
      data_type = "recall",
      office = office_info$office,
      sub_type = office_info$sub_type,
      county = county,
      candidate_name = candidate,
      polling_station_id = as.character(precinct_id),

      # Convert vote numbers
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
    # Calculate derived columns (README2.md vision)
    mutate(
      turnout_rate = ifelse(
        is.na(turnout_rate_pct),
        total_ballots / registered,
        turnout_rate_pct / 100
      ),
      votes = agree,  # Main vote count for recall (agree votes)
      vote_percentage = ifelse(total_valid > 0, agree/total_valid, NA_real_),
      is_recalled = agree > disagree  # Boolean: recall successful
    ) %>%
    # Join with party information
    left_join(candidate_party_mapping, by = "candidate_name") %>%
    select(
      # README2.md vision column order
      year, data_type, office, sub_type, county, town, village, polling_station_id,
      candidate_name, party, votes, vote_percentage, is_recalled,
      # Additional recall-specific columns
      disagree, invalid, total_valid, total_ballots, not_voted_but_issued,
      issued_ballots, unused_ballots, registered, turnout_rate
    )

  # ---- Basic validation ----
  if (!all(df$total_valid == df$votes + df$disagree, na.rm = TRUE)) {
    cli_warn("Validation: total_valid != votes + disagree")
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
