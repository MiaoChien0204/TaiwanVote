# data-raw/03_clean_legislator.R
# Purpose: Clean "2024 Legislator Election" raw xlsx files -> standardized CSV
# Input : data-raw/raw/2024_legislator/區域立委/*.xlsx
#         data-raw/raw/2024_legislator/平地立委/*.xlsx  
#         data-raw/raw/2024_legislator/山地立委/*.xlsx
# Output: data-raw/release/2024_legislator_election.csv

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(cli)
  library(purrr)
})

# ---- Paths ----
in_dir  = "data-raw/raw/2024_legislator"
out_dir = "data-raw/release"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ---- Helper functions ----
to_num = function(x) {
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

infer_county = function(fname) {
  m = str_match(fname, "(?<county>[\\p{Han}]{2,3}(市|縣))")[, "county"]
  ifelse(is.na(m), NA_character_, m)
}

map_sub_type = function(folder_name) {
  case_when(
    str_detect(folder_name, "區域立委") ~ "regional",
    str_detect(folder_name, "平地立委") ~ "indigenous_lowland", 
    str_detect(folder_name, "山地立委") ~ "indigenous_highland",
    TRUE ~ NA_character_
  )
}

# Parse candidate information from Excel header (row 3)
parse_candidate_info = function(file_path, sheet_name) {
  # Read the candidate info row (row 3, starting from column D)
  candidate_row = readxl::read_excel(file_path, sheet = sheet_name, range = "D3:Z3", col_names = FALSE)
  
  candidates = list()
  
  for (i in 1:ncol(candidate_row)) {
    cell_value = candidate_row[[i]][1]
    
    if (!is.na(cell_value) && nzchar(trimws(cell_value))) {
      # Split by newline to get parts: (1)\n候選人姓名\n政黨
      parts = strsplit(as.character(cell_value), "\n")[[1]]
      
      if (length(parts) >= 3) {
        number = trimws(parts[1])  # (1), (2), etc.
        name = trimws(parts[2])    # 候選人姓名
        party = trimws(parts[3])   # 政黨
        
        candidates[[length(candidates) + 1]] = list(
          column_index = i + 3,  # +3 because we start from column D (4th column)
          number = number,
          name = name,
          party = party
        )
      }
    }
  }
  
  return(candidates)
}

# ---- Clean one xlsx file ----
clean_one = function(file, sub_type) {
  cli_h1(paste(sub_type, "-", basename(file)))
  
  county = infer_county(basename(file))
  sheets = readxl::excel_sheets(file)
  
  cli_alert_info("Found {length(sheets)} constituencies")
  
  # Process each sheet (constituency)
  all_sheets_data = map_dfr(sheets, function(sheet_name) {
    tryCatch({
      # Parse candidate information from header
      candidates = parse_candidate_info(file, sheet_name)
      cli_alert_info("Found {length(candidates)} candidates in {sheet_name}")
      
      if (length(candidates) == 0) {
        cli_alert_warning("No candidates found in {sheet_name}")
        return(tibble())
      }
      
      # Read header row to identify column positions
      header = readxl::read_excel(file, sheet = sheet_name, range = "A2:Z2", col_names = FALSE)
      
      # Find the positions of key columns by searching header names
      find_col_by_header = function(pattern) {
        for(i in 1:ncol(header)) {
          if(!is.na(header[[i]][1]) && str_detect(header[[i]][1], pattern)) {
            return(i)
          }
        }
        return(NA)
      }
      
      # Identify key column positions
      valid_votes_col = find_col_by_header("有效票數")
      invalid_votes_col = find_col_by_header("無效票數") 
      total_ballots_col = find_col_by_header("投票數")
      not_voted_but_issued_col = find_col_by_header("已領未投票數")
      issued_ballots_col = find_col_by_header("發出票數")
      unused_ballots_col = find_col_by_header("用餘票數")
      registered_col = find_col_by_header("選舉人數")
      turnout_col = find_col_by_header("投票率")
      
      cli_alert_info("Column positions - valid:{valid_votes_col}, invalid:{invalid_votes_col}, total:{total_ballots_col}, registered:{registered_col}")
      
      # Read data starting from row 7 (skip=6) to include town names
      raw = readxl::read_excel(
        file, sheet = sheet_name, skip = 6, col_names = FALSE, col_types = "text"
      )
      
      if (nrow(raw) == 0) return(tibble())
      
      # Set column names based on actual structure
      n_cols = ncol(raw)
      col_names = rep("unknown", n_cols)
      col_names[1] = "town"
      col_names[2] = "village" 
      col_names[3] = "precinct_id"
      
      # Set candidate column names (from D onwards until valid_votes_col-1)
      candidate_start = 4  # Column D
      candidate_end = valid_votes_col - 1
      if (candidate_end >= candidate_start) {
        for(i in candidate_start:candidate_end) {
          col_names[i] = paste0("candidate_", i - candidate_start + 1)
        }
      }
      
      # Set summary statistic column names
      if (!is.na(valid_votes_col)) col_names[valid_votes_col] = "total_valid"
      if (!is.na(invalid_votes_col)) col_names[invalid_votes_col] = "invalid"
      if (!is.na(total_ballots_col)) col_names[total_ballots_col] = "total_ballots"
      if (!is.na(not_voted_but_issued_col)) col_names[not_voted_but_issued_col] = "not_voted_but_issued"
      if (!is.na(issued_ballots_col)) col_names[issued_ballots_col] = "issued_ballots"
      if (!is.na(unused_ballots_col)) col_names[unused_ballots_col] = "unused_ballots"
      if (!is.na(registered_col)) col_names[registered_col] = "registered"
      if (!is.na(turnout_col)) col_names[turnout_col] = "turnout_rate"
      
      colnames(raw) = make.names(col_names, unique = TRUE)
      
      # Clean data
      df_clean = raw %>%
        # Forward fill town names first (like president and recall processing)
        fill(town, .direction = "down") %>%
        mutate(
          across(c(town, village), norm_zh),
          year = 2024,
          data_type = "election",
          office = "legislator", 
          sub_type = sub_type,
          county = county,
          polling_station_id = as.character(as.integer(precinct_id))  # Convert to integer first, then character
        ) %>%
        filter(
          !is.na(village),
          village != "",
          !str_detect(village, "總\\s*計|小\\s*計|合\\s*計")
        )
      
      # Convert candidate vote columns to numeric
      candidate_cols = names(df_clean)[str_detect(names(df_clean), "candidate_")]
      for (col in candidate_cols) {
        df_clean[[col]] = to_num(df_clean[[col]])
      }
      
      # Convert other numeric columns - include all raw data fields
      other_numeric = c("total_valid", "invalid", "total_ballots", "not_voted_but_issued", "issued_ballots", "unused_ballots", "registered", "turnout_rate")
      for (col in other_numeric) {
        if (col %in% names(df_clean)) {
          df_clean[[col]] = to_num(df_clean[[col]])
        }
      }
      
      # Convert to long format with real candidate names
      if (length(candidate_cols) > 0) {
        df_long = df_clean %>%
          pivot_longer(
            cols = all_of(candidate_cols),
            names_to = "candidate_order", 
            values_to = "votes"
          ) %>%
          mutate(
            candidate_order = as.numeric(str_extract(candidate_order, "\\d+")),
            votes = to_num(votes)
            # Note: vote_percentage removed - not available in raw Excel data
          ) %>%
          # Map candidate order to actual candidate info
          left_join(
            tibble(
              candidate_order = 1:length(candidates),
              candidate_name = map_chr(candidates, "name"),
              party = map_chr(candidates, "party")
            ),
            by = "candidate_order"
          ) %>%
          filter(!is.na(candidate_name)) %>%  # Remove rows without candidate mapping
          select(
            year, data_type, office, sub_type, county, town, village, polling_station_id,
            candidate_name, party, votes,
            # Include all raw data fields from Excel
            invalid, total_valid, total_ballots, not_voted_but_issued, issued_ballots, unused_ballots, registered, turnout_rate
          )
        
        return(df_long)
      }
      
      return(tibble())
      
    }, error = function(e) {
      cli_alert_danger("Error in {sheet_name}: {e$message}")
      return(tibble())
    })
  })
  
  return(all_sheets_data)
}

# ---- Main processing ----
cli_h1("Processing 2024 Legislator Election Data")

folders_to_process = c("區域立委", "平地立委", "山地立委")
all_data = tibble()

for (folder in folders_to_process) {
  folder_path = file.path(in_dir, folder)
  
  if (!dir.exists(folder_path)) {
    cli_alert_warning("Folder not found: {folder_path}")
    next
  }
  
  sub_type = map_sub_type(folder)
  cli_h2("Processing {folder} (sub_type: {sub_type})")
  
  files = list.files(folder_path, pattern = "\\.xlsx?$", full.names = TRUE)
  
  if (length(files) == 0) {
    cli_alert_warning("No files found in {folder_path}")
    next
  }
  
  cli_alert_info("Found {length(files)} files")
  
  # Process first file only for testing - change to all files for production
  folder_data = clean_one(files[1], sub_type)
  all_data = bind_rows(all_data, folder_data)
}

# Validation and output
cli_h2("Data validation") 
cli_alert_info("Total rows: {nrow(all_data)}")
cli_alert_info("Counties: {length(unique(all_data$county))}")
cli_alert_info("Sub-types: {paste(unique(all_data$sub_type), collapse=', ')}")

if (nrow(all_data) > 0) {
  output_file = file.path(out_dir, "2024_legislator_election.csv")
  write_csv(all_data, output_file)
  
  cli_h1("Processing complete!")
  cli_alert_success("Output saved to: {output_file}")
  
  # Show sample data
  cli_alert_info("Sample data:")
  print(head(all_data, 3))
} else {
  cli_alert_danger("No data processed!")
}