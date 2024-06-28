# Title: Monthly Unemployment Rate at Metro Level 
# Name: monthly_unemprate.R
# Purpose: Pull the Monthly Unemployment Rate at metro-area level using BLS API 
# Content: 
#   I.    Set up 
#   II.   Get Data
#   III.  Export

# Notes: 
#     1. See BLS API Documentation: https://www.bls.gov/developers/home.htm 
#     2. See R-Package Used for API by mikeasilva: https://www.bls.gov/developers/home.htm  
#
#
# Daniel Mangoubi, Baker Research and Data Services
# DMangoubi@hbs.edu
# 06-28-2024

#----I. Set up ----

## 1. Libraries ----
### BLS API Library
  #install_github('mikeasilva/blsAPI', force=TRUE)
library(devtools)
library(blsAPI)

### General Libraries
library(dplyr)
library(tidyverse)
library(glue)
library(janitor)
library(readxl)
library(utils)
library(stringr)
library(sqldf)
library(lubridate)
library(glue)
library(eeptools)
library(knitr)
library(assertr)
library(haven)
library(arsenal)


## 2. File Paths ----
export <- "R:/Staff/DMANGOUBI/BLS API/Monthly Unemployment Rate"




#----II. Get Data ----
## 1. Get names of Metro Areas ----
### Print names of areas
help_laus_areacodes()

### Select only the metropolitan statistical areas 
areacodes <- help_laus_areacodes()  %>% 
  mutate(row = row_number()) %>%  # Create row numbers to more easily filter 
  filter(row >=53 & row_number <= 448) #Filter to just metropolitan statistical areas


## 2. Obtain monthly unemp rate for selected areas ----
unemployment_rate <- laus_get_date(areacodes$area_text, "unemployment rate", 2010, 2021)
head(unemployment_rate)



#----III. Export ----
write_csv(unemployment_rate, glue("{export}/monthlyunemprate_2010to21.csv"))

