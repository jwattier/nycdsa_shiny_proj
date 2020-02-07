library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.providers)
library(maps)
library(tidyverse)


nyc_pop_by_nta_fp <- "./data/New_York_City_Population_By_Neighborhood_Tabulation_Areas.csv"
nyc_pk_loc_fp <- "./data/Universal_Pre-K__UPK__School_Locations.csv"

# location information for pre-k schools in NYC
nyc_pk <- read_csv(file = nyc_pk_loc_fp)
nyc_pk <- nyc_pk %>% rename(., lat = Latitude, lng = Longitude)
