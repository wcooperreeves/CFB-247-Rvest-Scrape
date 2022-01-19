library(shiny)
library(leaflet)
library(tidyverse)
library(DT)
library(shinydashboard)
CFBData <- read.csv('C:/Users/wcoop/Documents/GitHub/CFB-247-Rvest-Scrape/Player_Data.csv')
CFBData$Class <- as.character(CFBData$Class)

# shinyUI(fluidPage(
# 
#     
#     header <- dashboardHeader(
#         title = '247 Recruitment Data'
#     ),
#     body <- dashboardBody()
# 
#     navbarPage
#     navbarPage("247 Recruitment Data",
# 
#         sidebarPanel(
# 
#             uiOutput('CollegeChoice'),
#             uiOutput('YearChoiceBegin'),
#             uiOutput('YearChoiceEnd')
# 
#         ),
#         tabPanel("Map",
# 
# 
#                    leafletOutput('usmap')
# 
#                  ),
#         tabPanel("Charts"),
#         tabPanel("Raw Data",
#                  DT::dataTableOutput('CFBFiltered')
# 
#                  )
#     )
#     
# ))


dashboardPage(
    dashboardHeader(title = "247 Recruitment Data"),
    dashboardSidebar(
        uiOutput('CollegeChoice'),
        uiOutput('YearChoiceBegin'),
        uiOutput('YearChoiceEnd'),
        sidebarMenu(
            menuItem('Recruit Map', tabName = 'map'),
            menuItem('Charts', tabName = 'chart'),
            menuItem('Dataset', tabName = 'rawdata')
        )
    ),
    dashboardBody(
        tabItems(
            tabItem('map',
                    fluidRow(
                        leafletOutput('usmap', height = 1000)
                    )),
            tabItem('chart'),
            tabItem('rawdata',
                    DT::dataTableOutput('CFBFiltered'),
                    downloadButton('downloadCSVFull',"Download Full Data"),
                    downloadButton('downloadCSVFilt','Download Displayed Data')
            )
        ),

    )
)