#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # output$nyc_school_map <- renderLeaflet({
    #     nyc_pk %>% 
    #         leaflet() %>% 
    #         addTiles() %>% 
    #         addMarkers(clusterOptions = markerClusterOptions())
    # 
    # })
    
    output$nyc_pk_analysis <- renderLeaflet({
      tm <- tm_shape(map_and_pk_and_pop) +
        tm_polygons("seats_per_1000", id = "nta_code", palette = "Greens")
      tmap_leaflet(tm)
    })    

})
