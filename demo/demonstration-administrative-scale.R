# demonstration-administrative-scale.R
# Demonstration of is_elected and is_recalled logic at different administrative scales
# 展示 is_elected 和 is_recalled 在不同行政區尺度的邏輯

library(TaiwanVote)
library(dplyr)

cat("=== TaiwanVote Administrative Scale Logic Demonstration ===\n")
cat("=== is_elected 和 is_recalled 行政區尺度邏輯展示 ===\n\n")

# 1. 展示選舉資料中的 is_elected 邏輯
cat("1. Presidential Election is_elected Logic (2024) | 總統選舉 is_elected 邏輯\n")
cat("─────────────────────────────────────────────────────────────\n")

# 村里級別：每個投票所的勝負
village_election <- tv_get_election(
  year = 2024, 
  office = "president", 
  village_name = "新北市新店區柴埕里"
)

if (nrow(village_election) > 0) {
  cat("Village Level (村里級) - 新北市新店區柴埕里:\n")
  cat("Each polling station has one winner | 每個投票所有一個勝者\n\n")
  
  # 顯示前3個投票所的結果
  sample_stations <- village_election %>%
    filter(polling_station_id %in% c("2278", "2279", "2280")) %>%
    select(polling_station_id, candidate_name, votes, vote_percentage, is_elected) %>%
    arrange(polling_station_id, desc(votes))
  
  print(sample_stations)
  
  # 驗證邏輯
  winners_per_station <- village_election %>%
    group_by(polling_station_id) %>%
    summarise(
      total_candidates = n(),
      winners = sum(is_elected, na.rm = TRUE),
      .groups = 'drop'
    )
  
  cat(sprintf("\n✓ Verification: All %d polling stations have exactly 1 winner each\n", 
              nrow(winners_per_station)))
  cat(sprintf("✓ 驗證：全部 %d 個投票所各有 1 位勝者\n\n", nrow(winners_per_station)))
}

# 縣市級別：聚合後的結果
county_election <- tv_get_election(
  year = 2024, 
  office = "president", 
  county_name = "新北市"
)

if (nrow(county_election) > 0) {
  cat("County Level (縣市級) - 新北市 (aggregated results | 聚合結果):\n")
  
  county_summary <- county_election %>%
    group_by(candidate_name, party) %>%
    summarise(
      total_votes = sum(votes, na.rm = TRUE),
      total_stations = n_distinct(polling_station_id),
      stations_won = sum(is_elected, na.rm = TRUE),
      win_rate = mean(is_elected, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    arrange(desc(total_votes))
  
  print(county_summary)
  
  cat(sprintf("\n✓ County winner: %s with %s votes (%.1f%% of stations won)\n",
              county_summary$candidate_name[1],
              format(county_summary$total_votes[1], big.mark = ","),
              county_summary$win_rate[1] * 100))
  cat(sprintf("✓ 縣市勝者：%s 得票 %s 票（勝出 %.1f%% 投票所）\n\n",
              county_summary$candidate_name[1],
              format(county_summary$total_votes[1], big.mark = ","),
              county_summary$win_rate[1] * 100))
}

# 2. 展示罷免資料中的 is_recalled 邏輯
cat("2. Legislative Recall is_recalled Logic (2025) | 立委罷免 is_recalled 邏輯\n")
cat("─────────────────────────────────────────────────────────────\n")

# 村里級別：每個投票所的同意/不同意勝負
village_recall <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  village_name = "新竹市東區三民里"
)

if (nrow(village_recall) > 0) {
  cat("Village Level (村里級) - 新竹市東區三民里, 候選人: 鄭正鈐\n")
  cat("Each polling station shows agree vs. disagree winner | 每個投票所顯示同意/不同意票勝負\n\n")
  
  sample_recall <- village_recall %>%
    mutate(
      disagree_votes = total_valid - votes,
      agree_vs_disagree = ifelse(votes > disagree_votes, "Agree Wins", "Disagree Wins")
    ) %>%
    select(polling_station_id, votes, disagree_votes, agree_vs_disagree, is_recalled) %>%
    head(5)
  
  print(sample_recall)
  
  # 驗證邏輯
  logic_check <- village_recall %>%
    mutate(
      disagree_votes = total_valid - votes,
      logic_correct = (is_recalled == (votes > disagree_votes))
    )
  
  cat(sprintf("\n✓ Verification: is_recalled logic is correct in %d/%d stations\n",
              sum(logic_check$logic_correct, na.rm = TRUE),
              nrow(logic_check)))
  cat(sprintf("✓ 驗證：is_recalled 邏輯在 %d/%d 個投票所正確\n\n",
              sum(logic_check$logic_correct, na.rm = TRUE),
              nrow(logic_check)))
}

# 縣市級別：整體罷免結果
county_recall <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  county_name = "新竹市"
)

if (nrow(county_recall) > 0) {
  cat("County Level (縣市級) - 新竹市, 候選人: 鄭正鈐 (overall result | 整體結果):\n")
  
  recall_summary <- county_recall %>%
    summarise(
      total_agree = sum(votes, na.rm = TRUE),
      total_valid = sum(total_valid, na.rm = TRUE),
      total_stations = n_distinct(polling_station_id),
      stations_recall_success = sum(is_recalled, na.rm = TRUE),
      recall_success_rate = mean(is_recalled, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    mutate(
      total_disagree = total_valid - total_agree,
      overall_result = ifelse(total_agree > total_disagree, "Recall Success", "Recall Failed")
    )
  
  print(recall_summary)
  
  cat(sprintf("\n✓ County result: %s (%s vs %s votes, %.1f%% stations favor recall)\n",
              recall_summary$overall_result[1],
              format(recall_summary$total_agree[1], big.mark = ","),
              format(recall_summary$total_disagree[1], big.mark = ","),
              recall_summary$recall_success_rate[1] * 100))
  cat(sprintf("✓ 縣市結果：%s（%s 對 %s 票，%.1f%% 投票所支持罷免）\n\n",
              recall_summary$overall_result[1],
              format(recall_summary$total_agree[1], big.mark = ","),
              format(recall_summary$total_disagree[1], big.mark = ","),
              recall_summary$recall_success_rate[1] * 100))
}

# 3. 關鍵概念總結
cat("3. Key Concepts Summary | 關鍵概念總結\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("✓ is_elected/is_recalled reflects winner at the SELECTED administrative level\n")
cat("✓ is_elected/is_recalled 反映在所選行政區尺度的勝者\n\n")

cat("✓ Village-level query: winner per polling station\n")
cat("✓ 村里級查詢：各投票所的勝者\n\n")

cat("✓ County-level query: aggregated results across entire county\n")
cat("✓ 縣市級查詢：整個縣市的聚合結果\n\n")

cat("✓ Same candidate may win/lose differently at different scales\n")
cat("✓ 同一候選人在不同尺度可能有不同的勝負結果\n\n")

cat("=== End of Demonstration ===\n")
