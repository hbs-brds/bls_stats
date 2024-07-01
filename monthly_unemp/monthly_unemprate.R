# Title: Monthly Unemployment Rate at Metro Level 
# Name: monthly_unemprate.R
# Purpose: Pull the Monthly Unemployment Rate at metro-area level using BLS API 
# Content: 
#   I.    Set up 
#   II.   Get Data
#   III.  Export

# Notes: 
#     1. BLS API Documentation: https://www.bls.gov/developers/home.htm 
#     2. Obtaining an API Key: https://data.bls.gov/registrationEngine/    
#     3. R-Package Used for API by mikeasilva: https://www.bls.gov/developers/home.htm  
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
### Folders
dir <- getwd()
data <- glue("{dir}/data")

### Parameters
startyear <- 2010 
endyear <- 2021
date <- Sys.Date()

### Files
output_file <- glue("{data}/output/unemprate_metroareas_{startyear}-{endyear}_{date}.csv")


## 3. API Set Up ---- 
if (interactive()) {
  print(glue("Please enter your API Key. If you need an API Key, go to: https://data.bls.gov/registrationEngine/ "))
  api_key <- readline(prompt = "Enter API Key: ")
} else {
  stop("This script must be run interactively.")
}
  ## Alternatively, enter API code manually in code: api_key <- "YOUR_KEY_HERE"




#----II. Get Data ----
## 1. Get names of Metro Areas ----
### Print names of areas
help_laus_areacodes()

### Select only the metropolitan statistical areas 
areacodes <- help_laus_areacodes()  %>% 
  mutate(row = row_number()) %>%  # Create row numbers to more easily filter 
  filter(row >=53 & row <= 448) #Filter to just metropolitan statistical areas
selectedareas <- areacodes$area_text


### Split areas selected into smaller chunks to avoid API daily limits 
areacodes_1to100 <- areacodes[1:100, ]
areacodes_101to200 <- areacodes[101:200, ]
areacodes_201to300 <- areacodes[201:300, ]
areacodes_301to396 <- areacodes[301:396, ]

areacodes <- areacodes_1to100 #Change this to a new value on later dates


## 2. Obtain monthly unemp rate for selected areas ----
#unemployment_rate <- laus_get_data(c("Staunton-Waynesboro, VA MSA", "Naples-Immokalee-Marco Island, FL MSA"), "unemployment rate", 2010, 2021)
## Pull data for each area and bind together (this avoids an out of bounds error)
error_areas <- list()

areacodes_end <- tail(areacodes, 100)
for(i in 1:nrow(areacodes_end)) {
  result <- tryCatch(
    {
    #Attempt to get Data
    unemployment_rate_1area <- laus_get_data(areacodes$area_text[i], "unemployment rate", 2010, 2021, api.version=2, bls.key=api_key)
    
    # If Succesfful:    
    if (i==1) { 
      unemployment_rate <-  unemployment_rate_1area
    }
    else {
      unemployment_rate <- rbind(unemployment_rate, unemployment_rate_1area)
    }
  }, 
  error = function(e) {
    # If an error occurs, save the value of area_text[i] in the list
    error_areas <- c(error_areas, areacodes$area_text[i])
    # Print Error Message
    print(paste("Error for area:", areacodes$area_text[i], "Error message:", e$message))
  }) #End Try/Catch
  
  
  ## Print Progress 
  if( i %% 50 ==0 | i == nrow(areacodes)) {
    remaining <- nrow(areacodes) - i
    print (glue(" "))
    print(glue("*** {i} of {nrow(areacodes)} areas completed. {remaining} remaining."))
    print (glue(" "))
  }

} #End For loop

## Check Results
head(unemployment_rate)
tail(unemployment_rate)



#----III. Export ----
write_csv(unemployment_rate, glue("{output_file}"))

