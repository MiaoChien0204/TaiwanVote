
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TaiwanVote

## Taiwan Election Database R Package

## 臺灣選舉資料庫 R 語言套件

<!-- badges: start -->

<!-- badges: end -->

## Package Overview \| 套件總覽

**TaiwanVote** is an R package designed for retrieving Taiwan’s election
voting results at different administrative levels. The package provides
three core functionalities: **Administrative Level Selection**, **Data
Filtering**, and **Combined Operations**. Users can specify the desired
administrative level (county, town, village, or polling station) to
determine how election winners are calculated, while applying various
filters for candidates, parties, and regions.

⚠️ **Key Concept**: All statistical values (vote counts, percentages,
winner status) are recalculated based on the specified administrative
level.

**TaiwanVote** provides a **comprehensive Taiwan election data retrieval
interface**, covering recall elections and expanding to include detailed
historical data of central and local public official elections, with
standardized and user-friendly interfaces for researchers and citizens.

`TaiwanVote` 是一個專為取得臺灣選舉投票結果而設計的 R
語言套件，支援不同行政層級的資料擷取。套件提供三大核心功能：**行政層級選擇**、**資料篩選**、**組合操作**。使用者可以指定所需的行政層級（縣市、鄉鎮、村里或投票所），決定當選者的計算方式，同時可對候選人、政黨、地區等進行多條件篩選。

⚠️
**重要概念**：所有統計數值（得票數、得票率、勝負狀況）都會根據指定的行政層級重新計算。

**TaiwanVote**
提供一個**全面的臺灣選舉資料擷取介面**，涵蓋罷免案並擴展至歷年來所有中央與地方公職人員選舉的詳盡數據，並提供標準化、易於使用的介面供研究者和公民取用。

## 🚧 Development Progress \| 開發進度

### ✅ Completed Features \| 已完成功能

#### **2025 Legislative Recall Election \| 2025 年立法委員罷免案**

- ✅ **Core Function**: `tv_get_recall()` - Unified recall election
  query interface
- ✅ **核心函式**: 統一的罷免案查詢介面
- ✅ **Multi-dimensional Queries**: Support queries by year, candidate,
  party, and region
- ✅ **多維度查詢**: 支援按年份、候選人、政黨、地區查詢
- ✅ **Multi-level Data**: Support village, township, and county-level
  data aggregation
- ✅ **多層級資料**: 支援村里級、鄉鎮級、縣市級資料聚合
- ✅ **Standardized Format**: Unified field design for consistent data
  structure
- ✅ **標準化格式**: 統一欄位設計，確保資料結構一致性
- ✅ **Helper Functions**: `tv_list_available_recalls()`,
  `tv_list_available_candidates()`, etc.
- ✅ **輔助函式**: 等輔助查詢功能
- ✅ **Complete Data**: Village-level voting results for all 31
  legislators nationwide
- ✅ **完整資料**: 涵蓋全台 31 位立委的村里級投票結果

#### **Data Infrastructure \| 資料基礎建設**

- ✅ **Standardized Fields**: Unified data field design (`year`,
  `data_type`, `office`, etc.)
- ✅ **標準化欄位**: 實作統一的資料欄位設計
- ✅ **File Naming Convention**: Adopts `{year}_{office}_recall.csv`
  format
- ✅ **檔案命名規範**: 採用標準格式
- ✅ **Caching Mechanism**: Automatic download and local cache
  management
- ✅ **快取機制**: 自動下載與本地快取管理

### 🔄 In Development \| 開發中功能

#### **Election Data Expansion \| 選舉資料擴展**

- 🔄 **`tv_get_election()` Function**: Unified election data query
  interface
- 🔄 **函式**: 統一的選舉資料查詢介面
- 🔄 **Historical Presidential Elections**: 2024, 2020, 2016
  presidential election data
- 🔄 **歷年總統選舉**: 總統副總統選舉資料
- 🔄 **Legislative Elections**: 2024, 2020 legislative election data
- 🔄 **立法委員選舉**: 立法委員選舉資料

## Installation \| 安裝

You can install the development version of TaiwanVote from GitHub using
`devtools`:

您可以使用 `devtools` 從 GitHub 安裝 `TaiwanVote` 套件：

``` r
# install.packages("devtools")
devtools::install_github("MiaoChien0204/TaiwanVote")
```

## Quick Start \| 快速上手

### Load Package \| 載入套件

``` r
library(TaiwanVote)
```

## ⚠️ Important Usage Notes \| 重要使用須知

### Understanding `is_elected` and `is_recalled` Fields \| 理解 `is_elected` 和 `is_recalled` 欄位

這些欄位可能容易造成誤解！請注意 These fields can be misleading! Please
note:

- **`is_elected` / `is_recalled`
  反映的是「在指定行政層級的勝出狀況」，不是實際選舉結果**
- **These fields reflect “winning status at the specified administrative
  level”, NOT actual election outcomes**
- 同一候選人在不同層級可能有不同的 `is_elected` 值 The same candidate
  may have different `is_elected` values at different levels
- 投票所層級的 `is_elected = TRUE` 僅表示該候選人在該投票所得票最高 At
  polling station level, `is_elected = TRUE` only means the candidate
  got the most votes at that specific polling station

### All Statistics Vary by Administrative Level \| 所有統計數字都隨行政區層級變化

所有數字欄位都會根據 `adm_level` 參數重新計算 All numerical fields are
recalculated based on the `adm_level` parameter: - `votes`,
`vote_percentage`, `turnout_rate`, `total_valid`, etc. -
得票數、得票率、投票率、有效票總數等

### Administrative Level and Geographic Filter Consistency \| 行政層級與地理篩選的一致性

⚠️ **重要限制 Important Restriction**: `adm_level`
不能高於地理篩選的層級 The `adm_level` cannot be higher than the
geographic filter level

``` r
# ✅ 正確組合 Correct combinations
tv_get_election(county_name = "新北市", adm_level = "county")
tv_get_election(town_name = "新北市新店區", adm_level = "town")
tv_get_election(village_name = "新北市新店區中正里", adm_level = "village")

# ❌ 錯誤組合 Invalid combinations (will throw error)
tv_get_election(town_name = "新北市新店區", adm_level = "county")     # Error!
tv_get_election(village_name = "新北市新店區中正里", adm_level = "town")  # Error!
tv_get_election(village_name = "新北市新店區中正里", adm_level = "county") # Error!
```

**設計理念 Design Rationale**: - 防止產生誤導性結果 Prevents misleading
results - 確保數據語義清晰 Ensures clear data semantics  
- 如需跨層級比較，請分別查詢後自行處理 For cross-level comparisons,
query separately and process manually

### View Available Data \| 查看可用資料

``` r
# View available recall election data | 查看可用的罷免案資料
tv_list_available_recalls()

# View queryable candidates | 查看可查詢的候選人
tv_list_available_candidates()

# View queryable parties | 查看可查詢的政黨
tv_list_available_parties()

# View queryable areas | 查看可查詢的地區
tv_list_available_areas(adm_level = "county")
```

## Core Features \| 核心功能

⚠️ **重要提醒 Important Note**:
所有統計數字（得票數、得票率、投票率、勝負狀況等）都會根據指定的行政區層級重新計算
All statistics (vote counts, percentages, turnout rates, winner status,
etc.) are recalculated based on the specified administrative level

### 1. Administrative Level Selection \| 行政區層級選擇

Specify the administrative level to determine data aggregation and
winner calculation:

指定行政區層級來決定資料聚合方式和當選者計算基準：

``` r
# County-level data: winners determined by county-wide vote totals
# 縣市層級：以全縣市得票數決定當選者
tv_get_election(year = 2024, office = "president", adm_level = "county")

# Village-level data: winners determined by individual polling stations  
# 村里層級：以各投票所得票數決定當選者
tv_get_recall(year = 2025, adm_level = "polling_station")

# Town-level data: winners determined by town-wide aggregated votes
# 鄉鎮層級：以全鄉鎮區聚合得票數決定當選者  
tv_get_election(year = 2024, office = "president", adm_level = "town")
```

### 2. Data Filtering \| 資料篩選

Apply multiple filters simultaneously to retrieve specific subsets:

同時套用多種篩選條件來取得特定資料子集：

``` r
# Filter by candidate
# 按候選人篩選
tv_get_election(year = 2024, office = "president", candidate = "賴清德")

# Filter by party
# 按政黨篩選  
tv_get_recall(year = 2025, party = "中國國民黨")

# Filter by region
# 按地區篩選
tv_get_election(year = 2024, county_name = "臺中市")

# Multiple filters combined
# 多重篩選組合
tv_get_election(
  year = 2024, 
  office = "president",
  county_name = "臺中市",
  candidate = c("賴清德", "柯文哲"),  # Multiple candidates
  party = c("民主進步黨", "台灣民眾黨")  # Multiple parties
)
```

### 3. Combined Operations \| 組合操作

Specify administrative level while applying filters:

指定行政層級的同時套用篩選條件：

``` r
# Get county-level results for specific candidate
# 取得特定候選人的縣市層級結果
tv_get_election(
  year = 2024,
  office = "president", 
  adm_level = "county",
  candidate = "賴清德"
)

# Get polling station-level results for specific region and party
# 取得特定地區和政黨的投票所層級結果
tv_get_recall(
  year = 2025,
  adm_level = "polling_station",
  county_name = "新竹市",
  party = "中國國民黨"
)

# Get town-level aggregated results with multiple filters
# 取得多重篩選條件下的鄉鎮層級聚合結果
tv_get_election(
  year = 2024,
  office = "president",
  adm_level = "town", 
  county_name = c("臺中市", "臺北市"),
  candidate = c("賴清德", "侯友宜")
)
```

## Understanding Administrative Levels \| 理解行政區層級

The `adm_level` parameter determines both data aggregation and how **ALL
statistical fields** are calculated:

`adm_level` 參數決定資料聚合方式以及**所有統計欄位**的計算基準：

### ⚠️ Critical Understanding \| 重要概念

**All numbers change with administrative level \|
所有數字都會隨行政區層級改變**:

- `votes`: Aggregated vote counts at specified level \|
  指定行政區層級的聚合得票數

- `vote_percentage`: Percentage within specified level \|
  在指定行政區層級內的得票率

- `turnout_rate`: Turnout rate within specified level \|
  指定行政區層級內的投票率

- `is_elected`/`is_recalled`: Winner status at specified level \|
  指定行政區層級的勝負狀態

**Example**: A candidate may have 30% at polling station level but 45%
at county level  
**範例**: 同一候選人在投票所層級可能得票率 30%，但在縣市層級可能是 45%

### Administrative Level Impact \| 行政區層級的影響

``` r
# Same candidate, different administrative levels = different results
# 同一候選人，不同行政區層級 = 不同結果

# Polling station level: Individual polling station winners
# 投票所層級：各投票所的個別勝負
polling_data <- tv_get_election(
  year = 2024, 
  office = "president", 
  adm_level = "polling_station",
  county_name = "臺中市"
)
# is_elected = TRUE for highest vote getter at each polling station
# is_elected = TRUE 表示該投票所得票最高者

# County level: County-wide aggregated winner  
# 縣市層級：全縣市聚合後的勝負
county_data <- tv_get_election(
  year = 2024,
  office = "president", 
  adm_level = "county",
  county_name = "臺中市"
)
# is_elected = TRUE for highest vote getter across entire county
# is_elected = TRUE 表示全縣市得票最高者

# Result: Different candidates may be marked as "elected" at different levels
# 結果：不同行政區層級可能有不同的候選人被標記為「當選」
```

### Practical Examples \| 實際範例

``` r
# Example 1: Presidential election at different levels
# 範例 1：不同層級的總統選舉結果

# Get polling station-level results for specific village
# 取得投票所層級結果，且只回傳特定村里的結果
village_stations <- tv_get_election(
  year = 2024,
  office = "president",
  adm_level = "polling_station", 
  village_name = "南投縣中寮鄉內城村"
)
# Shows winner at each individual polling station within the village
# 顯示該村里內各投票所的個別勝負

# Get village-level aggregated results 
# 取得村里層級的聚合結果，且只回傳特定縣市的結果
village_total <- tv_get_election(
  year = 2024,
  office = "president", 
  adm_level = "village",
  county_name = "南投縣"
)
# Shows winner based on total votes across entire village
# 顯示該縣市中，以村里分組計算票數的勝負結果

# Example 2: Statistical differences across levels
# 範例 2：不同行政區層級的統計數字差異

# Same candidate data at different administrative levels
# 同一候選人在不同行政區層級的資料

# Polling station level: Detailed breakdown
# 投票所層級：詳細分解
station_data <- tv_get_election(
  year = 2024,
  office = "president",
  adm_level = "polling_station",
  village_name = "新北市三峽區中埔里",
  candidate = "賴清德"
)
# Result: Multiple rows (one per polling station)
# Each with different votes, vote_percentage, is_elected values
# 結果：多列資料（每個投票所一列）
# 各有不同的 votes、vote_percentage、is_elected 數值

# Village level: Aggregated across entire village
# 村里層級：整個村里的聚合結果  
village_data <- tv_get_election(
  year = 2024,
  office = "president", 
  adm_level = "village",
  village_name = "新北市三峽區中埔里",
  candidate = "賴清德"
)
# Result: Single row with village-wide aggregated numbers
# vote_percentage calculated as: village_total_votes / village_total_valid_votes
# is_elected based on village-wide comparison with other candidates
# 結果：單列資料，為村里範圍的聚合數字
# vote_percentage 計算方式：村里總得票數 / 村里總有效票數
# is_elected 基於村里範圍內與其他候選人的比較

# Example 3: Recall election with filtering
# 範例 2：加上篩選條件的罷免案

# Get county-level recall results for specific party
# 取得特定政黨的縣市層級罷免結果
party_county <- tv_get_recall(
  year = 2025,
  adm_level = "county",
  party = "中國國民黨",
  county_name = c("新竹市", "桃園市")
)
# Shows recall success/failure aggregated at county level for KMT candidates
# 顯示國民黨候選人在縣市層級的罷免成功/失敗結果
```

## Function Interface Design \| 函式介面設計

### Unified Data Retrieval Interface \| 統一資料擷取介面

Standardized data retrieval functions with consistent `adm_level`
parameter:

標準化的資料擷取函數，配備一致的 `adm_level` 參數：

``` r
# Election data retrieval | 選舉資料擷取
tv_get_election(
  year = 2024,              # Election year | 選舉年份
  office = "president",     # Office type | 競選職務
  adm_level = "county",     # Administrative level determines is_elected calculation
                           # 行政區層級決定 is_elected 的計算方式
  county_name = "臺中市",    # Filter by region | 地區篩選
  candidate = "賴清德"       # Filter by candidate | 候選人篩選
)

# Recall election data retrieval | 罷免案資料擷取
tv_get_recall(
  year = 2025,              # Recall year | 罷免年份
  office = "legislator",    # Office being recalled | 被罷免職務
  adm_level = "polling_station", # Administrative level determines is_recalled calculation
                           # 行政區層級決定 is_recalled 的計算方式
  county_name = "新竹市",    # Filter by region | 地區篩選
  party = "中國國民黨"       # Filter by party | 政黨篩選
)
```

### Standardized Parameter Design \| 標準化參數設計

#### **Core Parameters \| 核心參數:**

- **`year`** *(Required 必填)*

  - **Description 描述**: Election/Recall year 選舉/罷免年份

  - **Example Values 範例值**: `2024`, `2025`

- **`office`** *(Required 必填)*

  - **Description 描述**: Office type 職務類型

  - **Example Values 範例值**:

    - `"president"` (總統)

    - `"legislator"` (立法委員)

    - `"mayor"` (縣市長)

    - `"councilor"` (縣市議員)

- **`adm_level`** *(Optional 選填)*

  - **Description 描述**:  
    Administrative level you would like to aggregate
    指定聚合的行政區層級

  - **Default 預設值**: `"polling_station"`

  - **Example Values 範例值**:

    - `"polling_station"` (投票所)

    - `"village"` (村里)

    - `"town"` (鄉鎮市區)

    - `"county"` (縣市)

- **`sub_type`** *(Optional 選填)*

  - **Description 描述**: Office subtype 職務子類型

  - **Example Values 範例值**:

    - `"regional"` (區域)

    - `"indigenous"` (原住民)

    - `"at_large"` (不分區)

- **`county_name`** *(Optional 選填)*

  - **Description 描述**: County/City name 縣市名稱

  - **Example Values 範例值**: `"新竹市"`, `"桃園市"`

- **`town_name`** *(Optional 選填)*

  - **Description 描述**: Town/District name with administrative suffix
    鄉鎮市區名稱（須含行政區劃後綴：區、鎮、鄉、市）

  - **Example Values 範例值**: `"東區"`, `"桃園區"`, `"竹北市"`,
    `"峨眉鄉"`

  - **Note 注意**: Must end with proper administrative unit suffix
    (區/鎮/鄉/市) 必須以正確的行政區劃後綴結尾

- **`village_name`** *(Optional 選填)*

  - **Description 描述**: Village name with full address
    村里名稱（須含完整地址）

  - **Example Values 範例值**: `"新竹市東區三民里"`,
    `"桃園市桃園區文中里"`

- **`candidate`** *(Optional 選填)*

  - **Description 描述**: Candidate name 候選人姓名

  - **Example Values 範例值**: `"鄭正鈐"`, `"蔡英文"`,
    `c("賴清德", "柯文哲")` (multiple values 多值)

- **`party`** *(Optional 選填)*

  - **Description 描述**: Party name 政黨名稱

  - **Example Values 範例值**: `"中國國民黨"`, `"民主進步黨"`,
    `c("民主進步黨", "台灣民眾黨")` (multiple values 多值)

#### Office 與 sub_type 對照表

<table>
<colgroup>
<col style="width: 59%" />
<col style="width: 40%" />
</colgroup>
<thead>
<tr>
<th>office</th>
<th>sub_type</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>"president"</code> (總統)</td>
<td></td>
</tr>
<tr>
<td><code>"legislator"</code> (立法委員)</td>
<td><p><code>"regional"</code> (區域)</p>
<p><code>"at_large"</code> (不分區)</p>
<p><code>"indigenous_lowland"</code> (平地原住民)</p>
<p><code>"indigenous_highland"</code> (山地原住民)</p></td>
</tr>
<tr>
<td><code>"mayor"</code> (縣市長)</td>
<td></td>
</tr>
<tr>
<td><code>"councilor"</code> (縣市議員)</td>
<td><p><code>"regional"</code> (區域)</p>
<p><code>"indigenous_lowland"</code> (平地原住民)</p>
<p><code>"indigenous_highland"</code> (山地原住民)</p></td>
</tr>
<tr>
<td><code>"indigenous_district_chief"</code> (原住民區長)</td>
<td></td>
</tr>
<tr>
<td><code>"indigenous_district_representative"</code>
(原住民區民代表)</td>
<td></td>
</tr>
<tr>
<td><code>"township_mayor"</code> (鄉鎮市長)</td>
<td></td>
</tr>
<tr>
<td><code>"township_representative"</code> (鄉鎮市民代表)</td>
<td><p><code>"regional"</code> (區域)</p>
<p><code>"indigenous"</code> (原住民)</p></td>
</tr>
<tr>
<td><code>"village_chief"</code> (村里長)</td>
<td></td>
</tr>
</tbody>
</table>

#### **Standardized Output Fields \| 標準化輸出欄位:**

All functions return data with unified field design:

所有函式回傳的資料都採用統一的欄位設計：

**Basic Information \| 基本資訊:**

- `year` (Year 年份)

- `data_type` (Data type: “election” or “recall” 資料類型)

- `office` (Office type 職務類型)

- `sub_type` (Office subtype 職務子類型)

**Geographic Information \| 地理資訊:**

- `county` (County/City 縣市)

- `town` (Town/District 鄉鎮市區)

- `village` (Village 村里)

- `polling_station_id` (Polling station ID 投票所代碼)

**Candidate Information \| 候選人資訊:**

- `candidate_name` (Candidate name 候選人姓名)

- `party` (Political party 政黨)

**Election Statistics \| 選舉統計:**

⚠️ **重要提醒 Important Note**: 所有統計數字都會根據 `adm_level`
參數進行相應計算 All statistics are calculated based on the `adm_level`
parameter

- `votes` (Vote count/Agree votes 得票數/同意票數)
  - 該候選人在指定層級的得票數 Vote count for the candidate at the
    specified level
- `vote_percentage` (Vote percentage 得票率)
  - 該候選人在指定層級的得票率 Vote percentage at the specified level
- `is_elected` / `is_recalled` (Winner status at specified
  administrative level 在指定行政層級的勝出狀態)
  - ⚠️ **重要概念 Key Concept**:
    此欄位反映「在指定行政層級範圍內的勝負狀況」，不是實際選舉結果 This
    field reflects “winning status within the specified administrative
    level scope”, not actual election outcomes
  - **計算邏輯 Calculation Logic**: 先依據 `adm_level`
    聚合計算，再進行候選人篩選 First aggregate by `adm_level`, then
    apply candidate filtering
  - **Election**: TRUE if candidate received most votes at the specified
    level 在指定層級得票最多為 TRUE
  - **Recall**: TRUE if agree votes \> disagree votes at the specified
    level 在指定層級同意票多於不同意票為 TRUE
  - **平票處理 Tie Handling**: 在得票數相同時，所有最高票者都標記為 TRUE
    When tied for highest votes, all top vote-getters are marked TRUE
  - **關鍵特性 Key Feature**: 同一候選人在不同行政層級可能有不同的
    is_elected 值 Same candidate may have different is_elected values at
    different levels
  - **選舉**：該候選人在指定層級得票最多為 TRUE
  - **罷免**：該層級同意票多於不同意票為 TRUE
- `invalid` (Invalid votes 無效票數)
  - 指定層級的無效票數 Invalid votes at the specified level
- `total_valid` (Total valid votes 有效票總數)
  - **選舉案 Election**: 所有候選人得票數總和 Sum of all candidates’
    votes
  - **罷免案 Recall**: 同意票 + 不同意票 `votes + disagree`
  - **重要 Important**: 不包含無效票 Does NOT include invalid votes
  - 指定層級的有效票總數 Total valid votes at the specified level
- `total_ballots` (Total ballots cast 總投票數)
  - **計算公式 Formula**: `total_valid + invalid` (有效票 + 無效票)
  - 指定層級的總投票數 Total ballots cast at the specified level
- `registered` (Registered voters 選舉人數)
  - 指定層級的選舉人數 Registered voters at the specified level
- `turnout_rate` (Voter turnout rate 投票率)
  - **計算公式 Formula**: `total_ballots / registered * 100`
  - **說明 Note**: `total_ballots = total_valid + invalid` (有效票 +
    無效票)
  - 指定層級的投票率 Voter turnout rate at the specified level

## Available Legislators for 2025 Recall \| 可查詢立委名單 (2025年罷免案)

The 2025 recall election covers the following 31 legislators (all
members of the Kuomintang):

目前 2025 年罷免案涵蓋以下 31 位立法委員（全部屬於中國國民黨）：

| Candidate 候選人 | Constituency 選區 | Party 政黨 |
|:-----------------|:------------------|:-----------|
| 馬文君           | 南投縣第1選舉區   | 中國國民黨 |
| 游顥             | 南投縣第2選舉區   | 中國國民黨 |
| 林沛祥           | 基隆市選舉區      | 中國國民黨 |
| 羅明才           | 新北市第11選舉區  | 中國國民黨 |
| 廖先翔           | 新北市第12選舉區  | 中國國民黨 |
| 洪孟楷           | 新北市第1選舉區   | 中國國民黨 |
| 葉元之           | 新北市第7選舉區   | 中國國民黨 |
| 張智倫           | 新北市第8選舉區   | 中國國民黨 |
| 林德福           | 新北市第9選舉區   | 中國國民黨 |
| 鄭正鈐           | 新竹市選舉區      | 中國國民黨 |
| 林思銘           | 新竹縣第2選舉區   | 中國國民黨 |
| 牛煦庭           | 桃園市第1選舉區   | 中國國民黨 |
| 涂權吉           | 桃園市第2選舉區   | 中國國民黨 |
| 魯明哲           | 桃園市第3選舉區   | 中國國民黨 |
| 萬美玲           | 桃園市第4選舉區   | 中國國民黨 |
| 呂玉玲           | 桃園市第5選舉區   | 中國國民黨 |
| 邱若華           | 桃園市第6選舉區   | 中國國民黨 |
| 顏寬恒           | 臺中市第2選舉區   | 中國國民黨 |
| 楊瓊瓔           | 臺中市第3選舉區   | 中國國民黨 |
| 廖偉翔           | 臺中市第4選舉區   | 中國國民黨 |
| 黃健豪           | 臺中市第5選舉區   | 中國國民黨 |
| 羅廷瑋           | 臺中市第6選舉區   | 中國國民黨 |
| 江啟臣           | 臺中市第8選舉區   | 中國國民黨 |
| 王鴻薇           | 臺北市第3選舉區   | 中國國民黨 |
| 李彥秀           | 臺北市第4選舉區   | 中國國民黨 |
| 羅智強           | 臺北市第6選舉區   | 中國國民黨 |
| 徐巧芯           | 臺北市第7選舉區   | 中國國民黨 |
| 賴士葆           | 臺北市第8選舉區   | 中國國民黨 |
| 黃建賓           | 臺東縣選舉區      | 中國國民黨 |
| 傅崐萁           | 花蓮縣選舉區      | 中國國民黨 |
| 丁學忠           | 雲林縣第1選舉區   | 中國國民黨 |

## Data Information \| 資料說明

- **Data Source**: Central Election Commission (中央選舉委員會)
- **Data Level**: Village-level (aggregatable to township and county
  levels)
- **資料層級**: 村里級（可聚合至鄉鎮級、縣市級）
- **Update Frequency**: Updated upon official election result
  announcements
- **更新頻率**: 隨選舉結果公布更新
- **Caching Mechanism**: Automatic local caching to reduce repeated
  downloads
- **快取機制**: 自動快取至本地，減少重複下載
- **Data Format**: Standardized CSV format following tidy data
  principles
- **資料格式**: 標準化 CSV 格式，符合 tidy data 原則

## Use Cases \| 使用案例

This package is particularly valuable for:

本套件特別適用於：

- **Academic Research \| 學術研究**: Retrieving standardized election
  data at various administrative levels for political science,
  sociology, and electoral studies
- **Journalism \| 新聞報導**: Obtaining election data for data-driven
  analysis and reporting across different geographic scales  
- **Civil Society \| 公民社會**: Accessing election results for citizen
  participation and democratic oversight
- **Policy Analysis \| 政策分析**: Gathering election data for
  government and think tank research
- **Educational Purposes \| 教育用途**: Teaching quantitative political
  analysis with real Taiwan election data

## License \| 授權

MIT License

## Issues & Contributions \| 問題回報與貢獻

For bug reports, feature requests, or contributions, please visit our
[GitHub Issues](https://github.com/MiaoChien0204/TaiwanVote/issues).

如有問題或建議，請至 [GitHub
Issues](https://github.com/MiaoChien0204/TaiwanVote/issues) 回報。

## About \| 關於

**TaiwanVote** aims to provide a convenient and standardized interface
for retrieving Taiwan’s election data at different administrative
levels. We believe that easily accessible data with flexible level
controls can promote deeper academic research, informed journalism, and
enhanced civic participation in Taiwan’s democratic processes.

`TaiwanVote`
套件旨在提供一個便捷且標準化的介面，幫助使用者在不同行政層級擷取臺灣的選舉數據。我們相信透過可彈性控制層級的開放資料，能夠促進更深入的學術研究、新聞報導以及公民參與。

------------------------------------------------------------------------

*Built with ❤️ for Taiwan’s democracy \| 為臺灣民主而建*
