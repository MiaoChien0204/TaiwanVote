
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TaiwanVote

## Taiwan Election Database R Package

## 臺灣選舉資料庫 R 語言套件

<!-- badges: start -->

<!-- badges: end -->

## Package Overview \| 套件總覽

**TaiwanVote** is an R package designed for querying and processing
Taiwan’s election voting results. Currently, it provides tools for
accessing and analyzing **2025 Taiwan Legislative Recall Election**
polling station results. Users can query voting data by candidate names,
administrative districts, villages, and various administrative levels,
with support for data aggregation and analysis.

**Ultimate Goal:** TaiwanVote aims to become a **comprehensive Taiwan
election data query interface**, expanding beyond recall elections to
cover detailed historical data of all central and local public official
elections, providing standardized and user-friendly interfaces for
researchers and citizens.

`TaiwanVote` 是一個專為查詢與處理臺灣選舉投票結果而設計的 R
語言套件。目前已提供了 **2025
年臺灣立法委員罷免案**各投開票所的開票結果查詢與資料處理工具。使用者可以依據候選人姓名、行政區、村里等不同層級來查詢投票結果，並支援資料的彙整與分析。

**終極目標：** `TaiwanVote`
旨在成為一個**全面的臺灣選舉資料查詢介面**，不僅限於罷免案，更將擴展至涵蓋歷年來所有中央與地方公職人員選舉的詳盡數據，並提供標準化、易於使用的介面供研究者和公民取用。

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

### Basic Query Functions \| 基本查詢功能

#### 1. Get All 2025 Recall Election Data \| 取得所有 2025 年罷免案資料

``` r
# Complete village-level data | 村里層級的完整資料
all_village_data <- tv_get_recall(year = 2025)
head(all_village_data)

# Get data for specific county | 取得特定縣市資料
all_county_data <- tv_get_recall(year = 2025, county_name = "新竹市")
head(all_county_data)
```

#### 2. Query by Candidate \| 按候選人查詢

``` r
# Query specific candidate's recall election results | 查詢特定候選人的罷免案結果
zheng_data <- tv_get_recall(year = 2025, candidate = "鄭正鈐")
head(zheng_data)

# Candidate results in specific county | 特定候選人在特定縣市的結果
zheng_county <- tv_get_recall(year = 2025, candidate = "鄭正鈐", county_name = "新竹市")
head(zheng_county)
```

#### 3. Query by Party \| 按政黨查詢

``` r
# Query recall results for specific party candidates | 查詢特定政黨候選人的罷免案結果
kmt_data <- tv_get_recall(year = 2025, party = "中國國民黨")
head(kmt_data)
```

#### 4. Query by Region \| 按地區查詢

``` r
# Query results for specific county/city | 查詢特定縣市的罷免案結果
hsinchu_data <- tv_get_recall(year = 2025, county_name = "新竹市")
head(hsinchu_data)

# Query results for specific township/district | 查詢特定鄉鎮市區的結果
dongqu_data1 <- tv_get_recall(year = 2025, town_name = "新竹市東區")
head(dongqu_data1)

# Query results for specific village | 查詢特定村里的結果
village_data1 <- tv_get_recall(year = 2025, village_name = "新竹市東區三民里")
head(village_data1)
```

#### 6. Understanding Administrative Scale Impact \| 理解行政區尺度的影響

``` r
# Same candidate may have different is_recalled results at different scales
# 同一候選人在不同尺度可能有不同的 is_recalled 結果

# Village-level results: detailed polling station winners
# 村里級結果：詳細的投票所勝負
village_results <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  village_name = "新竹市東區三民里"
)
# is_recalled shows agree/disagree winner per polling station
# is_recalled 顯示各投票所的同意/不同意票勝負

# County-level results: aggregated across entire county
# 縣市級結果：整個縣市的聚合結果
county_results <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  county_name = "新竹市"
)
# is_recalled shows overall agree/disagree result for entire county
# is_recalled 顯示整個縣市的整體同意/不同意票結果
```

#### 7. Combined Queries \| 組合查詢

``` r
# Detailed results for specific candidate in specific region | 特定候選人在特定地區的詳細結果
detailed_data <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  county_name = "新竹市"
)
head(detailed_data)

# More specific: candidate in specific district | 更具體：特定候選人在特定區的結果
district_data <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  town_name = "新竹市東區"
)
head(district_data)

# Most specific: candidate in specific village | 最具體：特定候選人在特定村里的結果
village_detail <- tv_get_recall(
  year = 2025, 
  candidate = "鄭正鈐", 
  village_name = "新竹市東區三民里"
)
head(village_detail)
```

## 🔮 Ultimate Vision Design \| 終極願景設計

### Separated Data Retrieval Interface \| 分離式資料擷取介面

Future unified but separated data retrieval functions will be provided:

未來將提供統一但分離的資料擷取函數：

``` r
# Election data query (planned) | 選舉資料查詢 (計劃中)
tv_get_election(
  year = 2024,          # Election year | 選舉年份
  office = "president", # Office type | 競選職務
  county_name = "臺中市" # Administrative level determines is_elected calculation
                        # 行政區尺度決定 is_elected 的計算方式
)

# Different administrative levels yield different is_elected results
# 不同行政區尺度產生不同的 is_elected 結果:
# - Village level: winner per polling station
# - County level: winner aggregated across entire county
# - 村里級：各投票所的勝出者
# - 縣市級：整個縣市聚合後的勝出者

# Recall election data query (implemented) | 罷免案資料查詢 (已實作)
tv_get_recall(
  year = 2025,              # Recall year | 罷免年份
  office = "legislator",    # Office being recalled | 被罷免職務
  county_name = "新竹市"     # County name | 縣市名稱
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
<p><code>"councilor"</code> (縣市議員)</p>
<p><code>"indigenous_district_chief"</code> (原住民區長)</p>
<p><code>"indigenous_district_representative"</code>
(原住民區民代表)</p>
<p><code>"township_mayor"</code> (鄉鎮市長)</p>
<p><code>"township_representative"</code> (鄉鎮市民代表)</p>
<p><code>"village_chief"</code> (村里長)</p></td>
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
<td><code>"鄭正鈐"</code>, <code>"蔡英文"</code></td>
</tr>
<tr>
<td><code>party</code></td>
<td>Party name 政黨名稱</td>
<td><code>"中國國民黨"</code>, <code>"民主進步黨"</code></td>
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
`is_elected` / `is_recalled` (Winner status at selected administrative
level 在所選行政區尺度的勝出狀態) - For elections: TRUE if candidate
received most votes at the selected level - For recalls: TRUE if agree
votes \> disagree votes at the selected level - **Note**: Results vary
by administrative scale (village vs. county level) -
選舉：該候選人在所選行政區尺度得票最多為 TRUE -
罷免：該行政區尺度同意票多於不同意票為 TRUE -
**注意**：結果會隨行政區尺度而異（村里級 vs. 縣市級）

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

- **Academic Research**
- **學術研究**: Political science, sociology, and electoral studies
- **Journalism**
- **新聞報導**: Data-driven election analysis and reporting
- **Civil Society**
- **公民社會**: Citizen participation and democratic oversight
- **Policy Analysis**
- **政策分析**: Government and think tank research
- **Educational Purposes**
- **教育用途**: Teaching quantitative political analysis

## License \| 授權

MIT License

## Issues & Contributions \| 問題回報與貢獻

For bug reports, feature requests, or contributions, please visit our
[GitHub Issues](https://github.com/MiaoChien0204/TaiwanVote/issues).

如有問題或建議，請至 [GitHub
Issues](https://github.com/MiaoChien0204/TaiwanVote/issues) 回報。

## About \| 關於

**TaiwanVote** aims to provide a convenient and standardized interface
for accessing and analyzing Taiwan’s election data. We believe that open
and accessible data can promote deeper academic research, informed
journalism, and enhanced civic participation in Taiwan’s democratic
processes.

`TaiwanVote`
套件旨在提供一個便捷且標準化的介面，幫助使用者快速獲取和分析臺灣的選舉數據。我們相信透過開放且易於取用的資料，能夠促進更深入的學術研究、新聞報導以及公民參與。

------------------------------------------------------------------------

*Built with ❤️ for Taiwan’s democracy \| 為臺灣民主而建*
