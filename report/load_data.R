knitr::opts_chunk$set(echo = TRUE)
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
data$HBCU <- factor(data$HBCU)
data$MENONLY <- factor(data$MENONLY)
data$WOMENONLY <- factor(data$WOMENONLY)
data$DISTANCEONLY <- factor(data$DISTANCEONLY)
data$CONTROL <- factor(data$CONTROL)
data$LOCALE <- factor(data$LOCALE)
data$HIGH_CDR <- factor(data$HIGH_CDR)
data$RELIGIOUS <- factor(data$RELIGIOUS)

# Condense Locales to City, Rural, Suburb, and Town
levels(data$LOCALE) <- c("City", "City", "City", "Rural", "Rural", "Rural", "Suburb", "Suburb", "Suburb", "Town", "Town", "Town")
