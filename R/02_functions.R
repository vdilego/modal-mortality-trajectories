estimate_modal_metrics <- function(df, min_mode_age = 30, max_mode_age = 110, spar = 0.50) {
  df <- df %>%
    arrange(Age) %>%
    filter(is.finite(Age), is.finite(lx), lx > 0)

  empty <- tibble(M = NA_real_, M_raw = NA_real_, HM = NA_real_, SM = NA_real_,
                  MH = NA_real_, DeltaM = NA_real_, muM = NA_real_)
  if (nrow(df) < 20) return(empty)

  l0 <- df$lx[which.min(df$Age)]
  df <- df %>% mutate(S = lx / l0, H = -log(S))

  adult <- df %>%
    filter(Age >= min_mode_age, Age <= max_mode_age, is.finite(dx), dx > 0)
  if (nrow(adult) < 10) return(empty)

  M_raw <- adult$Age[which.max(adult$dx)]
  fit <- smooth.spline(adult$Age, log(adult$dx), spar = spar)
  age_grid <- seq(min(adult$Age), max(adult$Age), by = 0.01)
  d_hat <- exp(predict(fit, x = age_grid)$y)
  M <- age_grid[which.max(d_hat)]

  HM <- approx(df$Age, df$H, xout = M, rule = 2)$y
  SM <- exp(-HM)

  hdat <- df %>% filter(is.finite(H), is.finite(Age)) %>% distinct(H, .keep_all = TRUE)
  MH <- if (max(hdat$H, na.rm = TRUE) >= 1) approx(hdat$H, hdat$Age, xout = 1)$y else NA_real_
  DeltaM <- M - MH
  muM <- approx(df$Age, df$mx, xout = M, rule = 2)$y

  tibble(M, M_raw, HM, SM, MH, DeltaM, muM)
}

make_pair_candidates <- function(metrics) {
  a <- metrics %>% select(Country, CountryCode, Sex, Year, M, HM, SM, MH, DeltaM)
  a %>%
    inner_join(a, by = "Sex", suffix = c("_1", "_2"), relationship = "many-to-many") %>%
    filter(paste(CountryCode_1, Year_1) < paste(CountryCode_2, Year_2)) %>%
    mutate(
      dM = abs(M_1 - M_2),
      dHM = abs(HM_1 - HM_2),
      dSM = abs(SM_1 - SM_2),
      year_gap = abs(Year_1 - Year_2)
    )
}
