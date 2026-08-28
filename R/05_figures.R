source("R/00_packages.R")
metrics <- readRDS("data/derived/modal_metrics.rds")
lt_all <- readRDS("data/raw/hmd_period_lifetables.rds")
pairs <- readr::read_csv("data/derived/matched_pairs_contemporary.csv", show_col_types = FALSE)

# Figure 1: M-H(M) state space
latest <- metrics %>% group_by(Country, Sex) %>% slice_max(Year, n = 1, with_ties = FALSE) %>% ungroup()
p1 <- metrics %>%
  filter(Year >= 1850) %>%
  ggplot(aes(M, HM, group = interaction(Country, Sex))) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  geom_path(alpha = 0.20, linewidth = 0.7) +
  geom_point(aes(colour = Year), alpha = 0.40, size = 1.3) +
  geom_point(data = latest, aes(M, HM), inherit.aes = FALSE, size = 3) +
  geom_text(data = latest, aes(M, HM, label = Country), inherit.aes = FALSE,
            nudge_y = 0.025, size = 3.2, check_overlap = TRUE) +
  scale_colour_viridis_c() + facet_wrap(~Sex) +
  labs(title = "Modal longevity and mortality accumulated before reaching it",
       subtitle = "Historical population-years trace different paths through M-H(M) space",
       x = "Modal age at death, M", y = expression(H(M)), colour = "Year")
ggsave("figures/fig1_M_HM_space.pdf", p1, width = 10, height = 6.5)

# Figure 2: conditional range of H(M)
modal_bins <- metrics %>% mutate(M_bin = round(M * 2) / 2) %>%
  group_by(Sex, M_bin) %>%
  summarise(n = n(), HM_mean = mean(HM), HM_min = min(HM), HM_max = max(HM), HM_sd = sd(HM), .groups = "drop") %>%
  filter(n >= 10)
p2 <- ggplot(modal_bins, aes(M_bin, HM_mean, ymin = HM_min, ymax = HM_max)) +
  geom_hline(yintercept = 1, linetype = "dashed") + geom_ribbon(alpha = 0.20) +
  geom_line(linewidth = 1) + facet_wrap(~Sex) +
  labs(title = "A single modal age can correspond to a range of mortality histories",
       subtitle = "Mean and observed range of H(M) within 0.5-year modal-age groups",
       x = "Modal age at death", y = expression(H(M)))
ggsave("figures/fig2_conditional_range.pdf", p2, width = 9, height = 5.5)

# Figure 3: Sweden long-run two-panel
sweden <- metrics %>% filter(CountryCode == "SWE")
p3a <- ggplot(sweden, aes(Year, M, linetype = Sex)) + geom_line(linewidth = 0.9) +
  labs(title = "A. Modal longevity", x = NULL, y = "Modal age at death", linetype = NULL)
p3b <- ggplot(sweden, aes(Year, HM, linetype = Sex)) + geom_hline(yintercept = 1, linetype = "dashed") +
  geom_line(linewidth = 0.9) +
  labs(title = "B. Mortality accumulated before the modal age", x = "Year", y = expression(H(M)), linetype = NULL)
p3 <- p3a / p3b + plot_annotation(title = "Mortality progress changes both the endpoint and the path", subtitle = "Sweden, period life tables")
ggsave("figures/fig3_sweden_transition.pdf", p3, width = 9, height = 8)

# Figure 4: strongest contemporary matched pair and its trajectories
if (nrow(pairs) > 0) {
  bp <- pairs %>% slice(1)
  ids <- bind_rows(
    bp %>% transmute(CountryCode = CountryCode_1, Country = Country_1, Sex = Sex, Year = Year_1),
    bp %>% transmute(CountryCode = CountryCode_2, Country = Country_2, Sex = Sex, Year = Year_2)
  )
  traj <- lt_all %>% semi_join(ids, by = c("CountryCode", "Country", "Sex", "Year")) %>%
    group_by(Country, Sex, Year) %>% arrange(Age) %>%
    mutate(S = lx / first(lx), H = -log(S), Population = paste(Country, Year)) %>% ungroup()
  pa <- traj %>% filter(Age >= 30, Age <= 105, mx > 0) %>%
    ggplot(aes(Age, mx, linetype = Population)) + geom_line(linewidth = 1) +
    scale_y_log10(labels = label_number()) +
    labs(title = "A. Age-specific mortality", x = "Age", y = expression(mu(x)), linetype = NULL)
  pb <- traj %>% filter(Age <= 105) %>%
    ggplot(aes(Age, H, linetype = Population)) + geom_hline(yintercept = 1, linetype = "dashed") +
    geom_line(linewidth = 1) + labs(title = "B. Cumulative hazard", x = "Age", y = expression(H(x)), linetype = NULL)
  p4 <- pa + pb + plot_annotation(title = "Nearly the same modal age, different mortality trajectories")
  ggsave("figures/fig4_matched_trajectories.pdf", p4, width = 11, height = 5.5)
}

# Figure 5: Taylor approximation diagnostic
p5 <- metrics %>% filter(abs(DeltaM) < 15, abs(Delta_pred) < 15) %>%
  ggplot(aes(Delta_pred, DeltaM)) + geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  geom_point(aes(colour = Year), alpha = 0.4, size = 1.4) + scale_colour_viridis_c() +
  facet_wrap(~Sex) + coord_equal() +
  labs(title = "Local approximation in observed life tables",
       x = expression((H(M)-1)/mu(M)), y = expression(Delta[M] == M-M[H]), colour = "Year")
ggsave("figures/figA1_taylor_check.pdf", p5, width = 8, height = 6)
