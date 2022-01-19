
CFBData <- read.csv('C:/Users/wcoop/Documents/GitHub/CFB-247-Rvest-Scrape/Player_Data.csv')
CFBData$Class <- as.character(CFBData$Class)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
    #Select Inputs to be used for filtering

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
    
    # end filtering
    
    ## Reactive Data Frame used for CFB
    
    CFBReactive <- reactive({
      # browser()
      yearRange <- seq(from = input$YearChoiceBegin, to = input$YearChoiceEnd, by = 1)

      df <- dplyr::filter(CFBData, CFBData$University %in% input$CollegeChoice, CFBData$Class %in% yearRange)
      head(df)
      return(df)
    })
    
    ##
    
    ##Recruit Rating Charts Begin##
    
    output$CFBFiltered <- DT::renderDataTable({
      DT::datatable(CFBReactive(), options = list(pageLength = 30))
    })

    output$fivestarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 5)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title='# of 5 Stars at each Position')+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    output$fourstarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 4)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title='# of 4 Stars at each Position')+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    output$threestarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 3)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title='# of 3 Stars at each Position')+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    output$twostarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 2)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title='# of 2 Stars at each Position')+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    ##Recruit Rating Section End##
    
    ##Leaflet Map##
    output$usmap <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap) %>%
        addMarkers(CFBReactive()$Longitude,CFBReactive()$Latitude, label = paste0(as.character(CFBReactive()$Player.Name),", ",CFBReactive()$Position,", Star Rating:",CFBReactive()$Star.Rating))
    })
    ## Leaflet End##
    
    ## Download Section
    output$downloadCSVFilt <- downloadHandler(
      filename = 'Filtered247Data.csv',
      content = function(file){
        write.csv(CFBReactive(), file,row.names = FALSE)
      }
    )
    
    ##
    
    # output$downloadCSVFull(
    #   filename = 'Full247Data.csv',
    #   content = function(file){
    #     write.csv(CFBData, file, row.names = FALSE)
    #   }
    # )

})
