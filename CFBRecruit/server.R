#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$CollegeChoice <- renderUI({
      selectInput(inputId = 'CollegeChoice',
                  label = 'Choose University:',
                  choices = unique(CFBData$University),
                  selected = unique(CFBData$University)[1],
                  selectize = TRUE)
    })

    output$YearChoice <- renderUI({
      selectInput(inputId = 'YearChoice',
                  label = 'Choose Year',
                  choices = unique(CFBData$Class),
                  selected = unique(CFBData$Class)[1],
                  selectize = TRUE)
    })
    
    CFBReactive <- reactive({
      df <- dplyr::filter(CFBData, CFBData$University %in% input$CollegeChoice, CFBData$Class %in% input$YearChoice)
      head(df)
      return(df)
    })
    
    output$CFBFiltered <- DT::renderDataTable({
      CFBReactive()
    })
    
    output$usmap <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap) %>%
        addMarkers(CFBReactive()$Longitude,CFBReactive()$Latitude, label = as.character(CFBReactive()$Player.Name))
    })

})
