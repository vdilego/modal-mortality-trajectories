required_packages <- c(
  "HMDHFDplus", "dplyr", "tidyr", "purrr", "ggplot2",
  "readr", "stringr", "scales", "viridis", "patchwork"
)
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Install missing packages first: ", paste(missing, collapse = ", "))
}
invisible(lapply(required_packages, library, character.only = TRUE))

theme_set(
  theme_minimal(base_size = 13) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title.position = "plot",
      plot.title = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(size = 11),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom"
    )
)
