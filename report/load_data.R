library(tidyverse)

data <- read_csv(
  "../data/analysis_data.csv",
  col_types = cols(
    UNITID = col_double(),
    CDR3 = col_double(),
    INSTNM = col_character(),
    HBCU = col_double(),
    MENONLY = col_double(),
    WOMENONLY = col_double(),
    RELAFFIL = col_double(),
    DISTANCEONLY = col_double(),
    CONTROL = col_character(),
    LOCALE = col_character(),
    ADM_RATE = col_double(),
    SATVRMID = col_double(),
    SATMTMID = col_double(),
    SATWRMID = col_double(),
    UGDS = col_double(),
    TUITIONFEE_IN = col_double(),
    TUITIONFEE_OUT = col_double(),
    INEXPFTE = col_double(),
    AVGFACSAL = col_double(),
    PFTFAC = col_double(),
    PCTPELL = col_double(),
    PCTFLOAN = col_double(),
    RET_FT4 = col_double(),
    GRAD_DEBT_MDN = col_double(),
    HIGH_CDR = col_logical(),
    SINGLEGENDER = col_double(),
    RELIGIOUS = col_logical()
  )
)


data <- data %>% mutate(
  # Condense Locales to City, Rural, Suburb, and Town
  LOCALE = str_extract(data$LOCALE, ".*(?=:)"),
  # Factorize all these variables
  across(c(HBCU, MENONLY, WOMENONLY, DISTANCEONLY, CONTROL, LOCALE, HIGH_CDR, RELIGIOUS), as_factor),
  # Lump Private for profit and non-profit together
  CONTROL = fct_collapse(CONTROL, "Public" = "Public", "Private" = c("Private, for-profit", "Private, non-profit")))
