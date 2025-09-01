
## Package Overview

`TaiwanVote` 提供 2025
年台灣立法委員罷免案各投開票所的開票結果查詢與資料處理工具。可依候選人姓名、行政區、村里等層級查詢投票結果，並支援彙整與分析。

`TaiwanVote` Provides tools for querying and processing the vote
counting results of the 2025 Taiwan Legislative Yuan recall election at
various polling places. It allows users to query voting results by
candidate name, administrative district, village, and other levels, and
supports aggregation and analysis.

### Package Description 主要功能

- 依候選人姓名查詢各村里/鄉鎮/區的罷免投票結果

- Get data by candidate name  

- 依行政區查詢特定候選人的投票結果

- Get data by area name

- 資料標準化與彙整

- Data was standardized and aggregated.

## 可查詢立委名單

下表為目前可查詢的立法委員罷免案名單與其選區：

The list of currently queryable legislative candidates for the recall
vote and their electoral districts:

| 候選人 | 選區             |
|--------|------------------|
| 馬文君 | 南投縣第1選舉區  |
| 游顥   | 南投縣第2選舉區  |
| 林沛祥 | 基隆市選舉區     |
| 羅明才 | 新北市第11選舉區 |
| 廖先翔 | 新北市第12選舉區 |
| 洪孟楷 | 新北市第1選舉區  |
| 葉元之 | 新北市第7選舉區  |
| 張智倫 | 新北市第8選舉區  |
| 林德福 | 新北市第9選舉區  |
| 鄭正鈐 | 新竹市選舉區     |
| 林思銘 | 新竹縣第2選舉區  |
| 牛煦庭 | 桃園市第1選舉區  |
| 涂權吉 | 桃園市第2選舉區  |
| 魯明哲 | 桃園市第3選舉區  |
| 萬美玲 | 桃園市第4選舉區  |
| 呂玉玲 | 桃園市第5選舉區  |
| 邱若華 | 桃園市第6選舉區  |
| 顏寬恒 | 臺中市第2選舉區  |
| 楊瓊瓔 | 臺中市第3選舉區  |
| 廖偉翔 | 臺中市第4選舉區  |
| 黃健豪 | 臺中市第5選舉區  |
| 羅廷瑋 | 臺中市第6選舉區  |
| 江啟臣 | 臺中市第8選舉區  |
| 王鴻薇 | 臺北市第3選舉區  |
| 李彥秀 | 臺北市第4選舉區  |
| 羅智強 | 臺北市第6選舉區  |
| 徐巧芯 | 臺北市第7選舉區  |
| 賴士葆 | 臺北市第8選舉區  |
| 黃建賓 | 臺東縣選舉區     |
| 傅崐萁 | 花蓮縣選舉區     |
| 丁學忠 | 雲林縣第1選舉區  |

## Installation

``` r
# devtools::install_github("MiaoChien0204/TaiwanVote")
```

## Quick start

``` r
library(TaiwanVote)
```

# 1) By candidate (village level)

``` r
x <- tv_get_recall_2025_by_candidate("鄭正鈐", level = "village") 
head(x)
```

# 2) Aggregate to town

``` r
x_town <- tv_get_recall_2025_by_candidate("鄭正鈐", level = "town") 
head(x_town)
```

# 3) By area name (town)

``` r
h1 <- tv_get_recall_2025_by_area("新竹市東區", level = "village", candidate = "鄭正鈐") head(h1)

h2 <- tv_get_recall_2025_by_area("新竹市東區", level = "village") 
head(h2)
```
