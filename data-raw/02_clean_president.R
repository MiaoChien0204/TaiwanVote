# data-raw/02_clean_president.R
# Purpose: Clean "2024 Presidential Election" raw xlsx files -> standardized CSV
# Input : data-raw/raw/2024_president/*.xlsx (各投開票所檔案 + 選舉結果清冊)
# Output: data-raw/release/2024_president.csv

# Output columns aligned with README vision:
# year, data_type, office, sub_type, county, town, village, polling_station_id,
# candidate_name, party, votes, vote_percentage, is_elected,
# invalid, total_valid, total_ballots, registered, turnout_rate

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
in_dir  = "data-raw/raw/2024_president"
out_dir = "data-raw/release"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ---- Load candidate-party mapping from 選舉結果清冊 ----
load_candidate_party_mapping = function() {
  cli_h2("Loading candidate-party mapping from 選舉結果清冊")
  
  registry_file = file.path(in_dir, "總統-A06-1-選舉結果清冊.xlsx")
  if (!file.exists(registry_file)) {
    cli_abort("Registry file not found: {registry_file}")
  }
  
  # Read the registry file to get candidate-party mapping
  registry = readxl::read_excel(registry_file)
  
  # Extract candidate names and party from specific columns
  # Based on the actual structure: ...2 = 候選人姓名, ...5 = 登記方式
  candidate_party_mapping = registry %>%
    # Skip header row and select the right columns
    slice(-1) %>%  # Remove the header row
    select(候選人姓名 = 2, 登記方式 = 5) %>%  # Column 2 = names, Column 5 = party
    filter(!is.na(候選人姓名), !is.na(登記方式)) %>%
    mutate(
      candidate_name = str_trim(as.character(候選人姓名)),
      party = case_when(
        str_detect(登記方式, "台灣民眾黨|臺灣民眾黨") ~ "台灣民眾黨",
        str_detect(登記方式, "民主進步黨") ~ "民主進步黨",
        str_detect(登記方式, "中國國民黨") ~ "中國國民黨",
        TRUE ~ as.character(登記方式)
      )
    ) %>%
    # Only keep presidential candidates (not vice presidents)
    # Filter to get only the main candidates (柯文哲, 賴清德, 侯友宜)
    filter(candidate_name %in% c("柯文哲", "賴清德", "侯友宜")) %>%
    select(candidate_name, party) %>%
    distinct()
  
  cli_alert_success("Loaded {nrow(candidate_party_mapping)} candidate-party mappings")
  print(candidate_party_mapping)
  
  return(candidate_party_mapping)
}

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

# ---- Infer county from filename ----
infer_county = function(fname) {
  m = str_match(fname, "(?<county>[\\p{Han}]{2,3}(市|縣))")[, "county"]
  ifelse(is.na(m), NA_character_, m)
}

# ---- Clean one xlsx file ----
clean_one = function(file, candidate_mapping) {
  cli_h1(basename(file))
  
  # Read the Excel file, skip header rows
  # Need to examine actual file structure first
  raw = readxl::read_excel(
    file, skip = 6, col_names = FALSE, col_types = "text"
  )
  
  # Check number of columns and adjust accordingly
  cli_alert_info("File has {ncol(raw)} columns")
  
  # Set proper column names based on actual Excel file structure  
  if (ncol(raw) >= 14) {
    colnames(raw) = c(
      "town", "village", "precinct_id",
      "candidate1_votes", "candidate2_votes", "candidate3_votes",
      "total_valid", "invalid", "total_ballots", 
      "ballots_not_returned", "ballots_issued", "ballots_remaining",
      "registered", "turnout_rate_pct"
    )[1:ncol(raw)]
  } else {
    # For files with fewer columns, give them generic names
    colnames(raw) = paste0("col_", 1:ncol(raw))
  }
  
  # Ensure no NA or empty column names
  colnames(raw) = make.names(colnames(raw), unique = TRUE)
  
  county = infer_county(basename(file))
  
  # Clean and process the data
  df_clean = raw %>%
    # Forward fill town names
    fill(town, .direction = "down") %>%
    mutate(
      # First, ensure all character columns are properly handled
      across(where(is.character), ~ifelse(is.na(.x), "", as.character(.x))),
      across(c(town, village), norm_zh),
      
      # Core identification columns
      year = 2024,
      data_type = "election", 
      office = "president",
      sub_type = NA_character_,  # 總統沒有子類型
      county = county,
      polling_station_id = as.character(precinct_id)
    )
  
  # Convert vote counts to numeric, using original values from Excel
  numeric_cols = intersect(names(df_clean), 
                          c("candidate1_votes", "candidate2_votes", "candidate3_votes",
                            "total_valid", "invalid", "total_ballots", "registered",
                            "ballots_not_returned", "ballots_issued", "ballots_remaining",
                            "turnout_rate_pct"))
  
  for (col in numeric_cols) {
    df_clean[[col]] = to_num(df_clean[[col]])
  }
  
  # Use original turnout rate from Excel data (convert from percentage to decimal)
  df_clean = df_clean %>%
    mutate(
      turnout_rate = ifelse(!is.na(turnout_rate_pct), turnout_rate_pct / 100, NA_real_)
    )
  
  # Remove totals and blank rows
  df_clean = df_clean %>%
    filter(
      !is.na(village),
      village != "",
      !str_detect(village, "總\\s*計|小\\s*計|合\\s*計")
    )
  
  # Convert from wide to long format (one row per candidate per location)
  candidate_cols = names(df_clean)[str_detect(names(df_clean), "candidate\\d+_votes")]
  
  if (length(candidate_cols) == 3) {
    # Map candidate columns to actual candidate names
    candidates = candidate_mapping$candidate_name
    
    df_long = df_clean %>%
      pivot_longer(
        cols = all_of(candidate_cols),
        names_to = "candidate_order",
        values_to = "votes"
      ) %>%
      mutate(
        candidate_order = str_extract(candidate_order, "\\d+"),
        candidate_name = case_when(
          candidate_order == "1" ~ candidates[1],
          candidate_order == "2" ~ candidates[2], 
          candidate_order == "3" ~ candidates[3],
          TRUE ~ NA_character_
        )
      ) %>%
      filter(!is.na(candidate_name)) %>%
      # Add party information
      left_join(candidate_mapping, by = "candidate_name") %>%
      # Calculate vote percentage 
      mutate(
        votes = to_num(votes),
        vote_percentage = ifelse(total_valid > 0, votes / total_valid, NA_real_)
      ) %>%
      # Calculate election result by polling station
      group_by(county, town, village, polling_station_id) %>%
      mutate(
        is_elected = votes == max(votes, na.rm = TRUE)
      ) %>%
      ungroup() %>%
      select(
        # README vision column order
        year, data_type, office, sub_type, county, town, village, polling_station_id,
        candidate_name, party, votes, vote_percentage, is_elected,
        # Additional election-specific columns
        invalid, total_valid, total_ballots, registered, turnout_rate
      )
  } else {
    cli_warn("Expected 3 candidate columns, found {length(candidate_cols)}")
    return(tibble())
  }
  
  return(df_long)
}

# ---- Main processing ----
# Load candidate-party mapping first
candidate_mapping = load_candidate_party_mapping()

# Process only 各投開票所 files
files = list.files(
  in_dir, 
  pattern = "各投開票所.*\\.xlsx?$", 
  full.names = TRUE
)

if (length(files) == 0L) {
  cli_abort("No 各投開票所 files found in {in_dir}/")
}

cli_alert_info("Found {length(files)} 各投開票所 files to process")

# Process all files with error handling
all_data = map_dfr(files, function(file) {
  tryCatch({
    clean_one(file, candidate_mapping)
  }, error = function(e) {
    cli_alert_danger("Error processing {basename(file)}: {e$message}")
    return(tibble())  # Return empty tibble on error
  })
})

# Basic validation
cli_h2("Data validation")
cli_alert_info("Total rows: {nrow(all_data)}")
cli_alert_info("Counties: {length(unique(all_data$county))}")
cli_alert_info("Candidates: {length(unique(all_data$candidate_name))}")

# Write output
output_file = file.path(out_dir, "2024_president_election.csv")
write_csv(all_data, output_file)

cli_h1("Processing complete!")
cli_alert_success("Output saved to: {output_file}")