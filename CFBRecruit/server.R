
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
        labs(title=paste('# of 5 Stars at each Position for ',input$CollegeChoice))+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    output$fourstarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 4)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title=paste('# of 4 Stars at each Position for ',input$CollegeChoice))+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    output$threestarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 3)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title=paste('# of 3 Stars at each Position for ',input$CollegeChoice))+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    output$twostarplot <- renderPlot({
      df <- filter(CFBReactive(), Star.Rating == 2)
      ggplot(df, aes(x=Position))+
        geom_bar(color = 'black')+
        labs(title=paste('# of 2 Stars at each Position for ',input$CollegeChoice))+
        geom_text(stat = 'count', aes(label =..count..), vjust = -1)
    })
    
    ##Recruit Rating Section End##
    
    ### Distribution Plots ###
    
    output$distributionposition <- renderUI({
      selectizeInput( inputId = 'distributionposition',
                      label = 'Pick Position',
                      choices = unique(CFBData$Position),
                      selected = unique(CFBData$Position[1])
                      )
    })
    
    output$checkboxrating <- renderUI({
      choice <- unique(CFBData$Star.Rating)
      choice <- sort(choice, decreasing = TRUE)
      checkboxGroupInput( inputId = 'checkboxrating',
                          label = 'Pick Star Rating',
                          choices = choice,
                          selected = choice)
    })
    
    output$heightdistribution <- renderPlotly({
      df <- filter(CFBData, CFBData$Position == input$distributionposition, CFBData$Star.Rating %in% input$checkboxrating)
      pos <- input$distributionposition
      print(pos)
      df$Star.Rating <- factor(df$Star.Rating, levels = c(5,4,3,2,0))
      Stars <- df$Star.Rating
      df$Height <- as.factor(df$Height) 
      # print(head(df))
      ggplotly(ggplot(df,  aes(x = Height, color = Star.Rating, group = Stars)) +
                     geom_line(stat = 'count', size = 1.05) +
                     labs(title = paste0("Number of Total ", input$distributionposition, " at Given Height:")),
               tooltip = c('count','Stars'))
                     #
 
    })
    
    output$weightdistribution <- renderPlotly({
      df <- filter(CFBData, CFBData$Position == input$distributionposition, CFBData$Star.Rating %in% input$checkboxrating)
      pos <- input$distributionposition
      print(pos)
      df$Weight <- as.numeric(df$Weight)
      Stars <- df$Star.Rating
      df$Star.Rating <- factor(df$Star.Rating, levels = c(5,4,3,2,0))
      # print(head(df))
      ggplotly(ggplot(df,  aes(x = Weight, color = Star.Rating, group = Stars)) +
                    geom_line(stat = 'count', size = 1.05)+
                    labs(title = paste0("Number of Total ",  input$distributionposition, " at Given Weight:")),
               tooltip = c('count','Stars'))
                 
                 
      
    })
    
    ### Distribution Plots End ###
    
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
