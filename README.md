
## Installation

# install.packages(“devtools”)

# devtools::install_github(“MiaoChien0204/TaiwanVote”)

## Quick start

library(TaiwanVote)

# 1) By candidate (village level)

x \<- tv_get_recall_2025_by_candidate(“鄭正鈐”, level = “village”)
head(x)

# 2) Aggregate to town

x_town \<- tv_get_recall_2025_by_candidate(“鄭正鈐”, level = “town”)

# 3) By area name (town)

h \<- tv_get_recall_2025_by_area(“新竹市東區”, level = “village”,
candidate = “鄭正鈐”)
