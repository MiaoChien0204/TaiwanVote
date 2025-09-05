
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

**Ultimate Goal:** TaiwanVote aims to become a **comprehensive Taiwan
election data retrieval interface**, expanding beyond recall elections
to cover detailed historical data of all central and local public
official elections, providing standardized and user-friendly interfaces
for researchers and citizens.

`TaiwanVote` 是一個專為取得臺灣選舉投票結果而設計的 R
語言套件，支援不同行政層級的資料擷取。套件提供三大核心功能：**行政層級選擇**、**資料篩選**、**組合操作**。使用者可以指定所需的行政層級（縣市、鄉鎮、村里或投票所），決定當選者的計算方式，同時可對候選人、政黨、地區等進行多條件篩選。

**終極目標：** `TaiwanVote`
旨在成為一個**全面的臺灣選舉資料擷取介面**，不僅限於罷免案，更將擴展至涵蓋歷年來所有中央與地方公職人員選舉的詳盡數據，並提供標準化、易於使用的介面供研究者和公民取用。

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
- ✅ **Standardized Format**: Unified field design aligned with ultimate
  vision
- ✅ **標準化格式**: 符合終極願景的統一欄位設計
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

### 📋 Planned Features \| 規劃中功能

#### **Complete Election System \| 完整選舉體系**

- 📋 **Local Elections**: Mayor and councilor election data
- 📋 **地方選舉**: 縣市長、縣市議員選舉資料
- 📋 **Grassroots Elections**: Township mayor and village chief election
  data
- 📋 **基層選舉**: 鄉鎮市長、村里長選舉資料
- 📋 **Other Recall Elections**: Mayor and councilor recall election
  data
- 📋 **其他罷免案**: 縣市長、議員罷免案資料
- 📋 **Referendums**: Historical referendum data
- 📋 **公民投票**: 歷年公投案資料

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

### View Available Data \| 查看可用資料

``` r
# View available recall election data | 查看可用的罷免案資料
tv_list_available_recalls()

# View queryable candidates | 查看可查詢的候選人
tv_list_available_candidates()

# View queryable parties | 查看可查詢的政黨
tv_list_available_parties()

# View queryable areas | 查看可查詢的地區
tv_list_available_areas(level = "county")
```

## Core Features \| 核心功能

### 1. Administrative Level Selection \| 行政層級選擇

Specify the administrative level to determine data aggregation and
winner calculation:

指定行政層級來決定資料聚合方式和當選者計算基準：

``` r
# County-level data: winners determined by county-wide vote totals
# 縣市層級：以全縣市得票數決定當選者
tv_get_election(year = 2024, office = "president", level = "county")

# Village-level data: winners determined by individual polling stations  
# 村里層級：以各投票所得票數決定當選者
tv_get_recall(year = 2025, level = "polling_station")

# Town-level data: winners determined by town-wide aggregated votes
# 鄉鎮層級：以全鄉鎮區聚合得票數決定當選者  
tv_get_election(year = 2024, office = "president", level = "town")
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
  level = "county",
  candidate = "賴清德"
)

# Get polling station-level results for specific region and party
# 取得特定地區和政黨的投票所層級結果
tv_get_recall(
  year = 2025,
  level = "polling_station",
  county_name = "新竹市",
  party = "中國國民黨"
)

# Get town-level aggregated results with multiple filters
# 取得多重篩選條件下的鄉鎮層級聚合結果
tv_get_election(
  year = 2024,
  office = "president",
  level = "town", 
  county_name = c("臺中市", "臺北市"),
  candidate = c("賴清德", "侯友宜")
)
```

## Understanding Administrative Levels \| 理解行政層級

The `level` parameter determines both data aggregation and how
`is_elected`/`is_recalled` is calculated:

`level` 參數決定資料聚合方式以及 `is_elected`/`is_recalled` 的計算基準：

### Administrative Level Impact \| 行政層級的影響

``` r
# Same candidate, different administrative levels = different results
# 同一候選人，不同行政層級 = 不同結果

# Polling station level: Individual polling station winners
# 投票所層級：各投票所的個別勝負
polling_data <- tv_get_election(
  year = 2024, 
  office = "president", 
  level = "polling_station",
  county_name = "臺中市"
)
# is_elected = TRUE for highest vote getter at each polling station
# is_elected = TRUE 表示該投票所得票最高者

# County level: County-wide aggregated winner  
# 縣市層級：全縣市聚合後的勝負
county_data <- tv_get_election(
  year = 2024,
  office = "president", 
  level = "county",
  county_name = "臺中市"
)
# is_elected = TRUE for highest vote getter across entire county
# is_elected = TRUE 表示全縣市得票最高者

# Result: Different candidates may be marked as "elected" at different levels
# 結果：不同層級可能有不同的候選人被標記為「當選」
```

### Practical Examples \| 實際範例

``` r
# Example 1: Presidential election at different levels
# 範例 1：不同層級的總統選舉結果

# Get polling station-level results for specific village
# 取得特定村里的投票所層級結果
village_stations <- tv_get_election(
  year = 2024,
  office = "president",
  level = "polling_station", 
  village_name = "臺中市南區平和里"
)
# Shows winner at each individual polling station within the village
# 顯示該村里內各投票所的個別勝負

# Get village-level aggregated results 
# 取得村里層級的聚合結果
village_total <- tv_get_election(
  year = 2024,
  office = "president", 
  level = "village",
  village_name = "臺中市南區平和里"
)
# Shows winner based on total votes across entire village
# 顯示以整個村里總得票數計算的勝負

# Example 2: Recall election with filtering
# 範例 2：加上篩選條件的罷免案

# Get county-level recall results for specific party
# 取得特定政黨的縣市層級罷免結果
party_county <- tv_get_recall(
  year = 2025,
  level = "county",
  party = "中國國民黨",
  county_name = c("新竹市", "桃園市")
)
# Shows recall success/failure aggregated at county level for KMT candidates
# 顯示國民黨候選人在縣市層級的罷免成功/失敗結果
```

## 🔮 Ultimate Vision Design \| 終極願景設計

### Unified Data Retrieval Interface \| 統一資料擷取介面

Future unified data retrieval functions with consistent `level`
parameter:

未來將提供統一的資料擷取函數，配備一致的 `level` 參數：

``` r
# Election data retrieval (planned) | 選舉資料擷取 (計劃中)
tv_get_election(
  year = 2024,              # Election year | 選舉年份
  office = "president",     # Office type | 競選職務
  level = "county",         # Administrative level determines is_elected calculation
                           # 行政層級決定 is_elected 的計算方式
  county_name = "臺中市",    # Filter by region | 地區篩選
  candidate = "賴清德"       # Filter by candidate | 候選人篩選
)

# Recall election data retrieval (implemented) | 罷免案資料擷取 (已實作)
tv_get_recall(
  year = 2025,              # Recall year | 罷免年份
  office = "legislator",    # Office being recalled | 被罷免職務
  level = "polling_station", # Administrative level determines is_recalled calculation
                           # 行政層級決定 is_recalled 的計算方式
  county_name = "新竹市",    # Filter by region | 地區篩選
  party = "中國國民黨"       # Filter by party | 政黨篩選
)
```

### Standardized Parameter Design \| 標準化參數設計

#### **Core Parameters \| 核心參數:**

<table style="width:99%;">
<colgroup>
<col style="width: 11%" />
<col style="width: 38%" />
<col style="width: 48%" />
</colgroup>
<thead>
<tr>
<th>Parameter 參數</th>
<th>Description 描述</th>
<th>Example Values 範例值</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>year</code></td>
<td>Election/Recall year 選舉/罷免年份</td>
<td><code>2024</code>, <code>2025</code></td>
</tr>
<tr>
<td><code>office</code></td>
<td>Office type 職務類型</td>
<td><p><code>"president"</code> (總統)</p>
<p><code>"legislator"</code> (立法委員)</p>
<p><code>"mayor"</code> (縣市長)</p>
<p><code>"councilor"</code> (縣市議員)</p></td>
</tr>
<tr>
<td><code>level</code></td>
<td>Administrative level 行政層級</td>
<td><p><code>"polling_station"</code> (投票所)</p>
<p><code>"village"</code> (村里)</p>
<p><code>"town"</code> (鄉鎮市區)</p>
<p><code>"county"</code> (縣市)</p></td>
</tr>
<tr>
<td><code>sub_type</code></td>
<td>Office subtype 職務子類型</td>
<td><code>"regional"</code> (區域), <code>"indigenous"</code> (原住民),
<code>"at_large"</code> (不分區)</td>
</tr>
<tr>
<td><code>county_name</code></td>
<td>County/City name 縣市名稱</td>
<td><code>"新竹市"</code>, <code>"桃園市"</code></td>
</tr>
<tr>
<td><code>town_name</code></td>
<td>Town/District name with county 鄉鎮市區名稱（含縣市）</td>
<td><code>"新竹市東區"</code>, <code>"桃園市桃園區"</code></td>
</tr>
<tr>
<td><code>village_name</code></td>
<td>Village name with full address 村里名稱（含完整地址）</td>
<td><code>"新竹市東區三民里"</code>,
<code>"桃園市桃園區文中里"</code></td>
</tr>
<tr>
<td><code>candidate</code></td>
<td>Candidate name 候選人姓名</td>
<td><code>"鄭正鈐"</code>, <code>"蔡英文"</code>,
<code>c("賴清德", "柯文哲")</code></td>
</tr>
<tr>
<td><code>party</code></td>
<td>Party name 政黨名稱</td>
<td><code>"中國國民黨"</code>, <code>"民主進步黨"</code>,
<code>c("民主進步黨", "台灣民眾黨")</code></td>
</tr>
</tbody>
</table>

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

**Basic Information \| 基本資訊:** - `year` (Year 年份) - `data_type`
(Data type: “election” or “recall” 資料類型) - `office` (Office type
職務類型) - `sub_type` (Office subtype 職務子類型)

**Geographic Information \| 地理資訊:** - `county` (County/City 縣市) -
`town` (Town/District 鄉鎮市區) - `village` (Village 村里) -
`polling_station_id` (Polling station ID 投票所代碼)

**Candidate Information \| 候選人資訊:** - `candidate_name` (Candidate
name 候選人姓名) - `party` (Political party 政黨)

**Vote Results \| 投票結果:** - `votes` (Vote count/Agree votes
得票數/同意票數) - `vote_percentage` (Vote percentage 得票率) -
`is_elected` / `is_recalled` (Winner status at specified administrative
level 在指定行政層級的勝出狀態) - **Determined by `level` parameter**:
Results calculated based on the specified administrative level -
**Election**: TRUE if candidate received most votes at the specified
level - **Recall**: TRUE if agree votes \> disagree votes at the
specified level - **由 `level` 參數決定**：根據指定的行政層級計算結果 -
**選舉**：該候選人在指定層級得票最多為 TRUE -
**罷免**：該層級同意票多於不同意票為 TRUE

**Election Statistics \| 選舉統計:** - `invalid` (Invalid votes
無效票數) - `total_valid` (Total valid votes 有效票總數) -
`total_ballots` (Total ballots cast 總投票數) - `registered` (Registered
voters 選舉人數) - `turnout_rate` (Voter turnout rate 投票率)

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
