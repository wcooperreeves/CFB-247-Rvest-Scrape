#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

CFBData <- read.csv('C:/Users/wcoop/Documents/GitHub/CFB-247-Rvest-Scrape/Player_Data.csv')
CFBData$Class <- as.character(CFBData$Class)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  

    output$CollegeChoice <- renderUI({
      selectInput(inputId = 'CollegeChoice',
                  label = 'Choose University:',
                  choices = unique(CFBData$University),
                  selected = unique(CFBData$University)[1],
                  selectize = TRUE)
    })

    output$YearChoiceBegin <- renderUI({
      selectInput(inputId = 'YearChoiceBegin',
                  label = 'Choose Start Year',
                  choices = unique(CFBData$Class),
                  selected = unique(CFBData$Class)[1],
                  selectize = TRUE)
    })
    
    
    output$YearChoiceEnd <- renderUI({
      selectInput(inputId = 'YearChoiceEnd',
                  label = 'Choose End Year',
                  choices = unique(CFBData$Class),
                  selected = unique(CFBData$Class)[1],
                  selectize = TRUE)
    })
    
    CFBReactive <- reactive({
      # browser()
      yearRange <- seq(from = input$YearChoiceBegin, to = input$YearChoiceEnd, by = 1)

      df <- dplyr::filter(CFBData, CFBData$University %in% input$CollegeChoice, CFBData$Class %in% yearRange)
      head(df)
      return(df)
    })
    
    output$CFBFiltered <- DT::renderDataTable({
      DT::datatable(CFBReactive(), options = list(pageLength = 30))
    })
    
    output$usmap <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap) %>%
        addMarkers(CFBReactive()$Longitude,CFBReactive()$Latitude, label = paste0(as.character(CFBReactive()$Player.Name),", ",CFBReactive()$Position,", Star Rating:",CFBReactive()$Star.Rating))
    })
    
    output$downloadCSVFilt <- downloadHandler(
      filename = 'Filtered247Data.csv',
      content = function(file){
        write.csv(CFBReactive(), file,row.names = FALSE)
      }
    )

})
