source("R/00_packages.R")
if (file.exists("config.R")) source("config.R")

HMD_USER <- Sys.getenv("HMD_USERNAME")
HMD_PASS <- Sys.getenv("HMD_PASSWORD")
if (HMD_USER == "" || HMD_PASS == "") {
  stop("Set HMD_USERNAME and HMD_PASSWORD, or copy config.example.R to config.R.")
}

countries <- c(
  SWE = "Sweden",
  FRATNP = "France",
  ITA = "Italy",
  JPN = "Japan",
  USA = "United States"
)

read_hmd_lt <- function(code, country_name, sex) {
  item <- ifelse(sex == "Female", "fltper_1x1", "mltper_1x1")
  message("Downloading ", country_name, " - ", sex)
  x <- HMDHFDplus::readHMDweb(
    CNTRY = code,
    item = item,
    username = HMD_USER,
    password = HMD_PASS
  )
  x %>%
    mutate(
      CountryCode = code,
      Country = country_name,
      Sex = sex,
      Age = readr::parse_number(as.character(Age)),
      Year = as.integer(Year)
    )
}

lt_all <- purrr::imap_dfr(
  countries,
  ~ bind_rows(
    read_hmd_lt(.y, .x, "Female"),
    read_hmd_lt(.y, .x, "Male")
  )
)

saveRDS(lt_all, "data/raw/hmd_period_lifetables.rds")
message("Saved data/raw/hmd_period_lifetables.rds")
