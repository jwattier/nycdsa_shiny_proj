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
  # output$hist <-
  
    # 
    # output$nyc_pk_analysis <- renderLeaflet({
    #   tm <- tm_shape(map_and_pk_and_pop) +
    #     tm_polygons("seats_per_1000", id = "nta_code", palette = "Greens")
    #   plot <- tmap_leaflet(tm)
    #   plot$elementid <- NULL
    #   plot
    # })    
    # 
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
      
      
      # ggthemr::ggthemr_reset() # reset is needed here otherwise all plots 
      # will have the same theme
      }
    )

})
