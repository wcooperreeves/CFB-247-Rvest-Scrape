rm(list=ls())

library(rvest)
library(tidyverse)
library(dplyr)
library(stringr)
library(xlsx)
library(tidygeocoder)

# REading in and setting up college file
setwd('C:\\Users\\wcoop\\Documents\\GitHub\\CFB-247-Rvest-Scrape')
cl <- readxl::read_excel('./college-list.xlsx')


first_run <- FALSE  #Always set to false, change to true so it will pick up all years provided. 


# nebraska <- dplyr::filter(cl,cl$ID == 'washington-state')


if(first_run == TRUE){
  year <- seq(from = 2005, to = 2021, by = 1)
} else {
  year <- 2021
}


# cl <- filter(cl,cl$Conference == 'ACC')
 #Scraping Website using rvest

Scrape_247_Data <- function(cl,year){
  # Scrapes data from 247 Recruitment website for looped years w/ looped universities
  # Args: 
  #   cl: Dataframe of all colleges to be reviewed. 3 Columns: 
  #       - ID: Id of university. Matches the naming convention for looping through each website.
  #       - Name: Generally Accepted Name of each University. 
  #       - Conference: Conference each University.
  #   year: Vector of years to be looped thru, chosen by the user. 
  # Returns:
  #   Returns a data.frame of all the data scraped that has been cleaned by the end.
  
  
  bound_data <- data.frame()
  for(y in 1:length(year)){
    print(paste0('Year:', year[y]))
    for(i in 1:length(cl$ID)){
  
    print(paste0('Scraping ',cl$Name[i]))
  
  
    CFB2021page <- paste0("https://247sports.com/college/",cl$ID[i],"/Season/",year[y],'-Football/Commits/?sortby=rank')
      # CFB2021page <- paste0("https://247sports.com/college/",nebraska$ID[1],"/Season/",2005,'-Football/Commits/?sortby=rank') #nebraska had to be difficult
    CFB2021 <- rvest::read_html(CFB2021page)
    
    # data <- CFB2021 %>%
    #   rvest::html_nodes('ul.recruit-list') %>%
    #   rvest::html_text()
    
    player_names <- CFB2021 %>%
      rvest::html_nodes('a.ri-page__name-link') %>%
      rvest::html_text()
    
    player_location <- CFB2021 %>%
      rvest::html_nodes('span.meta') %>%
      rvest::html_text()
    
    player_attributes <- CFB2021 %>%
      rvest::html_nodes('div.metrics') %>%
      rvest::html_text()
    
    
    player_location <- regmatches(player_location, gregexpr("(?<=\\()([^()]*?)(?=\\)[^()]*$)", player_location, perl=T))  # Grabbing City / State and only taking data from last parenthesis
    player_location <- unlist(player_location)
    if(length(which(player_location <2)) > 0){
      player_names  <- player_names[-which(player_location <2)] 
    }
    
    player_attributes <- str_extract(player_attributes, pattern = "(?<=\n).*(?=\n)") # grab everything between line breaks \n
    player_attributes <- gsub(" ",'', player_attributes, fixed = TRUE)
    player_attributes <- player_attributes[c(1:length(player_names))]
    player_height <- sub("/.*","", player_attributes)
    player_weight <- sub(".*/","", player_attributes)
    
    #removing Foreign Players that dont have a location provided
    player_location <- player_location[nchar(player_location)>2]  #only keeping locations above 2 letters, just in case if a state by itself gets through
    player_location <- player_location[c(1:length(player_names))]
    player_city  <- sub(",.*", "", player_location)
    player_state <- sub('.*, ', '', player_location)

    
    player_position <- CFB2021 %>%
      rvest::html_nodes('div.position') %>%
      rvest::html_text()
    
    player_position <- gsub(" ", '', player_position) #cleaning up info
    player_position <- gsub('\n', '', player_position) #cleaning up info
    player_position <- player_position[c(1:length(player_names))]  #removing Transfer Players
    
    
    player_rating <- CFB2021 %>% 
      rvest::html_nodes('span.score') %>%
      rvest::html_text()
    
    player_rating <- player_rating[c(1:length(player_names))] 
    player_rating <- as.numeric(player_rating)
    
    
    ## Star Ratings based on https://247sports.com/college/georgia/LongFormArticle/Georgia-Bulldogs-Recruiting-Everything-you-need-to-know-about-247Sports-Rating-Process-143324123/#143324123_3
    ## >=98.3 = 5 Star
    ## >= 89 = 4 star
    ## >= 79.6 = 3 star
    ## <= 79.59 = 2 star
    ## NA Does Exist. Will change to 0 Star
    star_rating <- cut(player_rating, c(0,.01,.796,.89,.983,Inf),labels = c(0,2,3,4,5))

    data <- data.frame(player_names, player_city, player_state, player_position, player_height, player_weight, player_rating, star_rating, stringsAsFactors = F)
    # browser()
    data$University <- cl$Name[i]
    data$Conference <- cl$Conference[i]
    data$Class      <- year[y]
    head(data)
    
    bound_data <- rbind(bound_data,data)
    bound_data$player_rating[is.na(bound_data$player_rating)] <- 0
    bound_data$star_rating[is.na(bound_data$star_rating)] <- 0
    Sys.sleep(1.5)
    }
  }
 return(bound_data)
}

data <- Scrape_247_Data(cl = cl, year = year)

geolocation_data <- tidygeocoder::geo(city = data$player_city, state = data$player_state)
geolocation_data$city <- NULL
geolocation_data$state <- NULL
# geolocation_data$address <- NULL
final_data <- dplyr::bind_cols(data,geolocation_data)
names(final_data) <- c('Player Name', 'City', 'State', 'Position', 'Height', 'Weight', 'Composite Rating', 'Star Rating', 'University',
                       'Conference', 'Class', 'Latitude', 'Longitude')
if(first_run == TRUE){
  write.csv(final_data,'./Player_Data.csv', row.names = FALSE)
} else {
  original_data <- read.csv('./Player_Data.csv')
  final_data <- rbind(original_data, final_data)
  write.csv(final_data, './Player_data.csv', row.names = FALSE)
}

### Geolocation Data for US Map




