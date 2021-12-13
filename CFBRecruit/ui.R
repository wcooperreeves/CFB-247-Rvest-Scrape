library(shiny)
library(leaflet)
library(tidyverse)
library(DT)
CFBData <- read.csv('C:/Users/wcoop/Documents/GitHub/CFB-247-Rvest-Scrape/Player_Data.csv')
CFBData$Class <- as.character(CFBData$Class)

shinyUI(fluidPage(

    # Application title
    titlePanel("247 Recruitment Data"),
    
    
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
      uiOutput('CollegeChoice'),
      uiOutput('YearChoice'),
    ),
    mainPanel(
      leafletOutput('usmap'),
      DT::dataTableOutput('CFBFiltered')
    )
))
