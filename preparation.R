library(sf)
library(fs)
library(shiny)
library(rgdal)
library(leaflet)
library(GISTools)
library(tidyverse)

# Create directories to store certain things
dir_create("raw-data")
dir_create("clean-data")

# Download VTA Light Rail and Bus stop locations
download.file("https://opendata.arcgis.com/datasets/a71c96cb960940798322f81a122a9334_2.csv", destfile = "raw-data/lrt_stops")
download.file("https://opendata.arcgis.com/datasets/490db54636704d35aae661a12c12e9a0_0.csv", destfile = "raw-data/bus_stops")
download.file("https://opendata.arcgis.com/datasets/cb9923f1ff0941d2b613ba75e40a4440_0.zip", destfile = "raw-data/zip_scc")
download.file("https://opendata.arcgis.com/datasets/cb9923f1ff0941d2b613ba75e40a4440_0.csv", destfile = "raw-data/zip_list")
download.file("http://www.psc.isr.umich.edu/dis/census/HCT012.csv", destfile = "raw-data/zip_incomes")



unzip("raw-data/zip_scc")

stops <- "https://opendata.arcgis.com/datasets/490db54636704d35aae661a12c12e9a0_0.geojson"
zips <- "https://opendata.arcgis.com/datasets/cb9923f1ff0941d2b613ba75e40a4440_0.geojson"

# Assign raw data to objects in RStudio env.
bus_stops <- read_csv("raw-data/bus_stops") %>% 
  st_as_sf(coords = c("X", "Y"), crs = 4236)

zip_list <- read_csv("raw-data/zip_list") %>% 
  as.character("ZCTA")

zip_scc <- st_read("Zip_Codes.shp") 

zip_income <- read_csv("raw-data/zip_incomes")

# Here I use readOGR in order for R to read geojson data
# This will allow us to count the bus stops in each zip code
# Then I assign them to new data frames

bus_stop_geojson <- readOGR(dsn = stops)

zip_boundary <- readOGR(dsn = zips)

counts <- poly.counts(bus_stop_geojson, zip_boundary)
setNames(counts, zip_boundary@zip_list$ZCTA)

count <- colSums(gContains(zip_boundary, bus_stop_geojson, byid = TRUE))
setNames(count, zip_boundary@data$NAME_1)

zip_scc <- zip_scc %>% 
  mutate(stop_count = count) %>% 
  st_transform(4326) %>% 
  st_as_sf(coords = c("LONGITUDE", "LATITUDE"), crs = 4236)

zip_list <- zip_list %>% 
  mutate(stop_count = count)

zip_income <- zip_income %>% 
  filter(Zip %in% zip_scc$ZCTA) %>% 
  dplyr::select(Zip, `Median Total`)

zip_data <- full_join(zip_list, zip_income, by = c("ZCTA" = "Zip"))


# Make map in Leaflet
map <- leaflet() %>% 
  addProviderTiles("Stamen.Terrain") %>% 
  addPolygons(data = zip_scc,
              color = "black",
              weight = 1.5,
              opacity = 1,
              fillColor = "white",
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "red"),
              popup = ~ZCTA, ~stop_count) %>%
  addCircleMarkers(data = bus_stop_geojson,
                   radius = 4,
                   popup = ~stopname,
                   color = "navy",
                   fillColor = "navy",
                   clusterOptions = markerClusterOptions()
                   )

map






