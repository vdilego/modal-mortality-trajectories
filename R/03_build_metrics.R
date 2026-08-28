source("R/00_packages.R")
source("R/02_functions.R")

lt_all <- readRDS("data/raw/hmd_period_lifetables.rds")

metrics <- lt_all %>%
  group_by(CountryCode, Country, Sex, Year) %>%
  group_modify(~ estimate_modal_metrics(.x, spar = 0.50)) %>%
  ungroup() %>%
  filter(is.finite(M), is.finite(HM), is.finite(MH)) %>%
  mutate(
    Delta_pred = (HM - 1) / muM,
    Delta_error = DeltaM - Delta_pred,
    sign_check = sign(DeltaM) == sign(HM - 1)
  )

if (!all(metrics$sign_check, na.rm = TRUE)) {
  warning("Some observations fail sign(DeltaM) = sign(H(M)-1). Inspect interpolation/smoothing.")
}

saveRDS(metrics, "data/derived/modal_metrics.rds")
readr::write_csv(metrics, "data/derived/modal_metrics.csv")
message("Saved modal metrics.")
