library(tidyverse)
library(fs)

if(!file_exists("data/Most-Recent-Cohorts-Institution.csv")) {
  options(timeout = max(300, getOption("timeout")))
  download.file(
    "https://ed-public-download.app.cloud.gov/downloads/Most-Recent-Cohorts-Institution_09012022.zip",
    "data/Most-Recent-Cohorts-Institution_09012022.zip")
  
  unzip("data/Most-Recent-Cohorts-Institution_09012022.zip", exdir = "./data/")
}

data <- read_csv("data/Most-Recent-Cohorts-Institution.csv",
                 na = c("NULL", "PrivacySuppressed"),
                 guess_max = 1e6)

CONTROL_LEVELS = list(
  "Public" = "1",
  "Private, non-profit" = "2",
  "Private, for-profit" = "3"
)

LOCALE_LEVELS = list(
  "City: Large" = "11",
  "City: Midsize" = "12",
  "City: Small" = "13",
  "Suburb: Large" = "21",
  "Suburb: Midsize" = "22",
  "Suburb: Small" = "23",
  "Town: Fringe" = "31",
  "Town: Distant" = "32",
  "Town: Remote" = "33",
  "Rural: Fringe" = "41",
  "Rural: Distant" = "42",
  "Rural: Remote" = "43"
)


analysis <- data %>%
  filter(SCH_DEG == 3, MAIN == 1) %>%
  select(
    UNITID,
    CDR3,
    INSTNM,
    HBCU,
    MENONLY,
    WOMENONLY,
    RELAFFIL,
    DISTANCEONLY,
    CONTROL,
    LOCALE,
    ADM_RATE,
    SATVRMID,
    SATMTMID,
    SATWRMID,
    UGDS,
    TUITIONFEE_IN,
    TUITIONFEE_OUT,
    INEXPFTE,
    AVGFACSAL,
    PFTFAC,
    PCTPELL,
    PCTFLOAN,
    RET_FT4,
    GRAD_DEBT_MDN
  ) %>%
  mutate(
    HIGH_CDR = CDR3 >= 0.1,
    SINGLEGENDER = pmax(MENONLY, WOMENONLY),
    RELIGIOUS = !is.na(RELAFFIL),
    CONTROL = CONTROL %>% as_factor %>% fct_recode(!!!CONTROL_LEVELS),
    LOCALE = LOCALE %>% as_factor() %>% fct_recode(!!!LOCALE_LEVELS)
  )

analysis %>%
  write_csv("data/analysis_data.csv")

