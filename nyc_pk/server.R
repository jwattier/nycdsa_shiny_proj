#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  
  
  main_map <- reactive({
    if(input$bor != 'All'){
      map_and_pk_and_pop <- map_and_pk_and_pop %>% filter(., borough.y == input$bor
                                                          , population > input$pop_cutoff)
    } else {
      map_and_pk_and_pop <- map_and_pk_and_pop %>% filter(., population > input$pop_cutoff)
    }
  })
  
  num_scale <- reactive({
    
    map_tbl <- main_map()
    
    if(input$metric_option == "Total Seats"){
      pk_seats_pal <- colorNumeric(
        palette = "Blues",
        domain = map_tbl$seats_per_nta
      )
    } else {
      pk_seats_pal <- colorNumeric(
        palette = "Greens",
        domain = map_tbl$seats_per_1000
      )
    }
    
    # return(pk_seats_pal)
  })
  
  bottom_spots <- reactive({
    # if(input$metric_option == "Total Seats"){
    #     bottom <- map_plus_layers() %>%
    #       arrange(., seats_per_nta) %>%
    #       top_n(., n=input$min_nbr) %>%
    #       st_as_sf(x = ., sf_column_name = "geometry")
    #   } else {
    #     bottom <- map_plus_layers() %>%
    #       arrange(., seats_per_1000) %>%
    #       top_n(., n=input$min_nbr) %>%
    #       st_as_sf(x = ., sf_column_name = "geometry")
    map_tbl <- main_map()
    
    if(input$metric_option == "Total Seats"){
      
      bottom <- map_tbl %>%
        arrange(., seats_per_nta) %>%
        st_as_sf(x = ., sf_column_name = "geometry")
    } else {
      bottom <- map_tbl %>%
        arrange(., seats_per_1000) %>% 
        st_as_sf(x = ., sf_column_name = "geometry")
      }
    })
  
  map_plus_layers <- reactive({
    # save reactive num scale to variable to pass to below function
    new_num_scale <- num_scale() 
    map_tbl <- main_map()
    
    if(input$metric_option == "Total Seats"){
      map_tbl %>% 
        leaflet() %>% 
        setView(lat = 40.7128, lng = -74.0060, zoom = 10) %>% 
        addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~new_num_scale(seats_per_nta),
                    popup = ~as.character(seats_per_nta), label = ~as.character(seats_per_nta))%>%
        addLegend(data = map_tbl,
                  position = "topleft", 
                  pal = new_num_scale,
                  values = ~seats_per_nta, 
                  title = "Pre-K Seats per NTA",
                  opacity = 1)  
    } else {
      map_tbl %>% 
        leaflet() %>% 
        setView(lat = 40.7128, lng = -74.0060, zoom = 10) %>% 
        addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = ~new_num_scale(seats_per_1000),
                    popup = ~as.character(seats_per_1000), label = ~as.character(seats_per_1000))%>%
        addLegend(data = map_tbl,
                  position = "topleft", 
                  pal = new_num_scale,
                  values = ~seats_per_1000, 
                  title = "Pre-K Seats per 1k Population",
                  opacity = 1)  
      
    }
  })
  
  
  output$nyc_pk_analysis <- renderLeaflet({
    map_plus_layers()
    # new_num_scale <- num_scale()  # save reactive num scale to variable to pass to below function
    # 
    # main_map() %>% 
    # leaflet() %>% 
    #   setView(lat = 40.7128, lng = -74.0060, zoom = 10) %>% 
    #   addProviderTiles("CartoDB.Positron") %>% 
    #   addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
    #               color = ~new_num_scale(seats_per_nta))%>%
    #   addLegend(data = main_map(),
    #             position = "topleft", 
    #             pal = new_num_scale,
    #             values = ~seats_per_nta, 
    #             title = "Pre-K Seats per NTA",
    #             opacity = 1)
    # %>% 
    #   addPolygons(data = bottom_5, stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
    #               color = "red")
  })
  
  # Observe event for show/remove bottom 5 NTAs
  observe({
    
    min_number <- input$min_nbr
    btm_sf <- bottom_spots()
    
    
    proxy <- leafletProxy("nyc_pk_analysis")
    if(input$show){
      proxy %>% 
        addPolygons(data = btm_sf[1:min_number, ], stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    color = "red", layerId = LETTERS[1:min_number])
    } else {
      proxy %>%
        removeShape(layerId = LETTERS[1:min_number])
    }
  })
  
  output$nyc_seats_hist <- renderPlot({
    ggplot(data = map_and_pk_and_pop, mapping = aes(x = seats_per_1000)) +
      geom_histogram(binwidth = 5, colour = "white", fill = "#1380A1") +
      geom_hline(yintercept = 0, size = 1, colour = "#333333") +
      # bbc_style() +
      scale_x_continuous(limits = c(0, 55),
                         breaks = seq(5, 50, by = 5),
                         labels = c("5", "10", "15", "20", "25",
                                    "30", "35", "40", "45", " 55")) +
      labs(title = "How Available Seats Vary Across NYC",
           subtitle = "Distribution of Pre-K Seats per 1000")
  }
  )
  
  output$nyc_seats_box_by_bor <- renderPlot({
    
    map_and_pk_and_pop %>% 
      ggplot(., mapping= aes(x = reorder(borough.y, seats_per_1000, median), y = seats_per_1000, fill = borough.y)) +
      geom_boxplot()  +
      ylab("Seats per 1000") +
      xlab("") + 
      theme(legend.position = "None") +
      ggtitle("Seat Distribution Across NYC Boroughs")
    
  }
  )
  
  output$btm_lst <- DT::renderDataTable(
    bottom_spots() %>% 
      st_drop_geometry(.) %>% # drop geometry b/c select will not exclude
      mutate(., seats_per_1000 = round(seats_per_1000, 2)) %>% 
      arrange(., seats_per_1000) %>% 
      select(., "NTA Name" = nta, "Borough" = borough.y, "Total Population" = population, "Total Schools" = schl_per_nta, 
             "Total Seats" = seats_per_nta, "Seats per 1k" = seats_per_1000) %>% 
        DT::datatable(data = ., rownames = FALSE)
    )
    
      
    output$btm_nta <- DT::renderDataTable(
      pk_and_pop %>% 
        filter(., population > 12000) %>%
        mutate(., seats_per_1000 = round(seats_per_1000, 2)) %>% 
        arrange(., seats_per_1000) %>% 
        # top_n(., n=5) %>%
        # select(., "NTA Name" = nta, "Borough" = borough.y, "NTA Population" = population, "Total Schools" = schl_per_nta, 
        #        "Total Seat" = seats_per_nta) %>% 
        #arrange(., total_seats / population) %>% 
        DT::datatable(data = ., rownames = FALSE)
    )

})
