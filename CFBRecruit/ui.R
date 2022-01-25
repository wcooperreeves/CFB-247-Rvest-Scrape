library(shiny)
library(leaflet)
library(tidyverse)
library(DT)
library(shinydashboard)
library(shinyWidgets)
library(plotly)



dashboardPage(
    dashboardHeader(title = "247 Recruitment Data"),
    dashboardSidebar(
        uiOutput('CollegeChoice'),
        uiOutput('YearChoiceBegin'),
        uiOutput('YearChoiceEnd'),
        sidebarMenu(
            menuItem('Recruit Map', tabName = 'map'),
            menuItem('College Charts', tabName = 'chart'),
            menuItem('Draft Questions', tabName = 'draft'),
            menuItem('247 Dataset', tabName = 'rawdata'),
            menuItem('Draft Data')
        )
    ),
    dashboardBody(
        tabItems(
            tabItem('map',
                    fluidRow(
                        leafletOutput('usmap', height = 1000)
                    )),
            tabItem('chart',
                    fluidRow(
                      splitLayout(
                        style = "border: 1px solid silver;",
                        cellWidths = 500,
                        cellArgs = list(style = "padding: 5px"),
                        plotOutput("fivestarplot"), #Count of position per rating for five star
                        plotOutput("fourstarplot"), #Count of position per rating for four star
                        plotOutput("threestarplot"), #Count of position per rating for three star
                        plotOutput('twostarplot') #Count of position per rating for two star
                      )
                    ),
                    fluidRow(
                      splitLayout(
                        style = "border: 1px solid silver;",
                        cellWidths = 850,
                        cellArgs = list(style = "padding: 5px"),
                        plotlyOutput("heightdistribution"), # Line for each rating
                        plotlyOutput("weightdistribution"),  # Line for each Rating
                        box(
                           uiOutput('distributionposition'),
                           uiOutput('checkboxrating')
                           )#pickerinput
                          ),
                        DT::dataTableOutput('Avg Rating Per State')
                      )
                    ),
            tabItem('rawdata',
                    DT::dataTableOutput('CFBFiltered'),
                    downloadButton('downloadCSVFull',"Download Full Data"),
                    downloadButton('downloadCSVFilt','Download Displayed Data')
                  )

           ) 
        )

   ) 
