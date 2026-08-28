source("R/00_packages.R")
source("R/02_functions.R")
lt_all <- readRDS("data/raw/hmd_period_lifetables.rds")

sensitivity <- purrr::map_dfr(c(0.40, 0.50, 0.60), function(s) {
  lt_all %>%
    group_by(CountryCode, Country, Sex, Year) %>%
    group_modify(~ estimate_modal_metrics(.x, spar = s)) %>%
    ungroup() %>% mutate(spar = s)
})
saveRDS(sensitivity, "data/derived/smoothing_sensitivity.rds")

p <- sensitivity %>% ggplot(aes(Year, M, group = interaction(Country, Sex, spar), linetype = factor(spar))) +
  geom_line(alpha = 0.7) + facet_grid(Sex ~ Country, scales = "free_x") +
  labs(title = "Sensitivity of the estimated modal age to spline smoothing",
       x = "Year", y = "Modal age at death", linetype = "Spline spar")
ggsave("figures/figA2_smoothing_sensitivity.pdf", p, width = 12, height = 7)
