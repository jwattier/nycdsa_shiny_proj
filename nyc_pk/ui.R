
shinyUI(dashboardPage(
    dashboardHeader(title = "NYC Pre-K School Location Analysis"),

    dashboardSidebar(
        sidebarMenu(
            menuItem(text = "Home", tabName = "home", icon = icon("home")),
            menuItem(text = "Map", tabName = "map", icon = icon("map")),
            menuItem(text = "Chart", tabName = "chart", icon = icon("chart-area")),
            # menuItem(text = "Charts",
            #          menuSubItem(
            #              text = "Bottom Area List",
            #              tabName = "btm_area_tbl"
            #          ),
            #          menuSubItem(
            #              text = "Bottom Area Detail",
            #              tabName = "bmt_area_dtl"
            #          )),
            selectizeInput(inputId = "bor",
                           label = "Boroughs to Show",
                           choices = boroughs,
                           selected = "All"
                           ),
            numericInput("min_nbr","Minimum Number to Display:", value = 5,
                         min = 1, max = 10, step = 1),
            numericInput("pop_cutoff","Population Threshold:", 
                         value = 12000, min = 0, max = 25000, step = 1000)
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "home",
                    fluidRow(p(
                        "Hi, welcome to my R Shiny project. This dashboared analyzes the pre-school ('Pre-K') in NYC.
                        
                        NYC started the Pre-K program in 2014.
                        
                        This analysis combines the latest census from 2010 then pre-school location as of 2018 to
                        identify areas where there are relatively fewer seats.
                        ", style="text-align:center; font-family: times"
                        ),
                        br(),
                        # a(href = "https://www.schools.nyc.gov/enrollment/enroll-grade-by-grade/pre-k"
                        #   , "Here",target="_blank")
                        # ,style="text-align:center;color:black")
                        p("For more information please check the",em("NYC's DOE"),"page by clicking",
                          br(),
                          a(href="https://www.schools.nyc.gov/enrollment/enroll-grade-by-grade/pre-k", "here",target="_blank")
                          ,style="text-align:center;color:black")
                        ,
                        width = 8
                    )
                
            ),
            tabItem(tabName = "map",
                    fluidPage(
                        title = "NYC PK Map",
                        leafletOutput("nyc_pk_analysis", height = 600),
                        br(),
                        checkboxInput("show", "Highlight Lowest", value = FALSE),
                        DT::dataTableOutput("btm_lst")
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