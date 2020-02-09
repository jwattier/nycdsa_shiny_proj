library(shiny)
library(shinydashboard)
library(geojsonsf)
library(sf)
library(janitor)
library(leaflet)
library(leaflet.providers)
library(tmap)
library(tmaptools)
library(maps)
library(tidyverse)
# library(bbplot)
library(extrafont)
library(ggthemr)

# loadfonts(device = "win")
ggthemr::ggthemr("earth")
options(scipen = 999)

# options for input
boroughs <- c("All", "Brooklyn","Bronx", "Manhattan", "Queens", "Staten Island")

# collect file paths
nyc_pop_by_nta_fp <- "./data/New_York_City_Population_By_Neighborhood_Tabulation_Areas.csv"
nyc_pk_loc_fp <- "./data/Universal_Pre-K__UPK__School_Locations.csv"

# location information for pre-k schools in NYC
nyc_pk <- read_csv(file = nyc_pk_loc_fp)
nyc_pk <- nyc_pk %>% rename(., lat = Latitude, lng = Longitude)

# aggregate pk school information at the nta level
pk_by_nta <- nyc_pk %>% 
  clean_names(.) %>% 
  group_by(., borough, nta) %>% 
  summarise(., schl_per_nta = n(), seats_per_nta = sum(seats)) %>% 
  ungroup()

# geo information for nyc's nta grid (nta = neighborhood tabular area)
nyc_nta_sf <- geojson_sf(geojson = './data/nyc_nta.geojson')

# population import
nyc_pop <- read_csv(file = nyc_pop_by_nta_fp)
nyc_pop

nyc_pop <- nyc_pop %>% filter(., Year == 2010) # only bring in 2010 census information that is in the file


# name clean 
nyc_pop <- clean_names(dat = nyc_pop)
nyc_nta_sf <- clean_names(dat = nyc_nta_sf)


# combine map and population information
map_and_pop <- right_join(x = nyc_pop, y = nyc_nta_sf, by = 'nta_code')

# combine population and pk information (for DT)
# pk_and_pop <- 
pk_and_pop <- inner_join(x = pk_by_nta, y = nyc_pop, by = c("nta" = "nta_name")) %>% 
  select(., borough = borough.y, nta_code, nta_name = nta, total_schools = schl_per_nta,
         total_seats = seats_per_nta, population) %>% 
  mutate(., seats_per_1000 = total_seats / (population / 1000))

# combine pk school information together with map_and_pop
map_and_pk_and_pop <- inner_join(x = pk_by_nta, y = map_and_pop, by = c("nta" = "nta_name.x")) %>% 
  mutate(., seats_per_1000 = seats_per_nta / (population / 1000)) %>% 
  st_as_sf(x = ., sf_column_name = "geometry") # has to be converted back to a spatial form data type


# set up palette for map
pk_seats_pal <- colorNumeric(
  palette = "Blues",
  domain = map_and_pk_and_pop$seats_per_nta
)

# highlight bottom 5 ntas -> which we will make programatic later
bottom_5 <-map_and_pk_and_pop %>% 
  arrange(., seats_per_1000) %>% 
  top_n(., n=5) %>% 
  st_as_sf(x = ., sf_column_name = "geometry")
