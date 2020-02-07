#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("NYC Pre-K School Location Analysis"),


    sidebarLayout(
        sidebarPanel(

        ),

        # Show a leaflet map of NYC pre-K school locations
        mainPanel(
            #leafletOutput("nyc_school_map"),
            leafletOutput("nyc_pk_analysis")
        )
    )
))
