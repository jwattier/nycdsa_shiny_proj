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
    }
    else{
      map_and_pk_and_pop <- map_and_pk_and_pop %>% filter(., population > input$pop_cutoff)
    }
  })
  
  num_scale <- reactive({
    map_tbl <- main_map()
    pk_seats_pal <- colorNumeric(
      palette = "Blues",
      domain = map_tbl$seats_per_nta
    )
  })
  
  bottom_spots <- reactive({
    main_map() %>% 
      arrange(., seats_per_1000) %>% 
      top_n(., n=input$min_nbr) %>% 
      st_as_sf(x = ., sf_column_name = "geometry")
  })
  
  
  
    output$nyc_pk_analysis <- renderLeaflet({
      new_num_scale <- num_scale()  
    
      main_map() %>% 
      leaflet() %>% 
        setView(lat = 40.7128, lng = -74.0060, zoom = 10) %>% 
        addProviderTiles("CartoDB.Positron") %>% 
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                    #color = ~pk_seats_pal(seats_per_nta))%>%
                    color = ~new_num_scale(seats_per_nta))%>%
        addLegend(data = main_map(),
                  position = "topleft", 
                  # pal = pk_seats_pal, 
                  pal = new_num_scale,
                  values = ~seats_per_nta, 
                  title = "Pre-K Seats per NTA",
                  opacity = 1)
      # %>% 
      #   addPolygons(data = bottom_5, stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
      #               color = "red")
    })
    
    # Observe event for show/remove bottom 5 NTAs
    observeEvent(input$show, {
      proxy <- leafletProxy("nyc_pk_analysis")
      if(input$show){
        proxy %>% 
          addPolygons(data = bottom_spots(), stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
                      color = "red", layerId = LETTERS[1:input$min_nbr])
      } else {
        proxy %>%
          removeShape(layerId = LETTERS[1:input$min_nbr])
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
