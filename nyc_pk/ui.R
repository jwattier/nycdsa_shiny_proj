
shinyUI(dashboardPage(
    dashboardHeader(title = "NYC Pre-K School Location Analysis"),

    dashboardSidebar(
        sidebarMenu(
            menuItem(text = "Map", tabName = "map", icon = icon("map")),
            menuItem(text = "Chart", tabName = "chart", icon = icon("chart-area")),
            menuItem(text = "Charts",
                     menuSubItem(
                         text = "Bottom Area List",
                         tabName = "btm_area_tbl"
                     ),
                     menuSubItem(
                         text = "Bottom Area Detail",
                         tabName = "bmt_area_dtl"
                     )),
            selectizeInput(inputId = "bor",
                           label = "Boroughs to Show",
                           choices = boroughs,
                           selected = "All"
                           )
        )

        # numericInput(inputID = "min_pop", label = "Select Minimum Population Threshold",
        #              value = 12000, min = 0, max = 50000, step = 2000
        #                )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "map",
                    fluidPage(
                        title = "NYC PK Map",
                            leafletOutput("nyc_pk_analysis", height = 800),
                            br(),
                            checkboxInput("show", "Show Bottom", value = FALSE)
                        )
                    ),
            tabItem(tabName = "chart",
                fluidRow(box(
                    status = "primary",
                    width = 12,
                    plotOutput("nyc_seats_hist")
                    )),
                fluidRow(
                    width = 12,
                    plotOutput("nyc_seats_box_by_bor")
                    )
                ),
            tabItem(tabName = 'btm_area_tbl',
                    fluidRow(
                        box(width = 12,
                            DT::dataTableOutput("btm_nta"))
                    ))
        )

        )
    )
)
# )