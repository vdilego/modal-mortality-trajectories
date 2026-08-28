source("R/00_packages.R")
source("R/02_functions.R")
metrics <- readRDS("data/derived/modal_metrics.rds")

pairs <- make_pair_candidates(metrics)

best_all <- pairs %>%
  filter(dM <= 0.25) %>%
  arrange(desc(dHM))

best_contemporary <- pairs %>%
  filter(dM <= 0.25, year_gap <= 5, Country_1 != Country_2) %>%
  arrange(desc(dHM))

readr::write_csv(best_all, "data/derived/matched_pairs_all.csv")
readr::write_csv(best_contemporary, "data/derived/matched_pairs_contemporary.csv")

print(best_contemporary %>%
        select(Sex, Country_1, Year_1, M_1, HM_1, SM_1,
               Country_2, Year_2, M_2, HM_2, SM_2, dM, dHM) %>%
        slice_head(n = 20))
