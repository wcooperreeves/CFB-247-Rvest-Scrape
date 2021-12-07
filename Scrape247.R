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
# cl$ID[is.na(cl$ID)] <- cl$Name[is.na(cl$ID)]
# cl$ID <- tolower(gsub(' ', '-',cl$ID))
# xlsx::write.xlsx(cl,'./college-list.xlsx')

nebraska <- filter(cl,cl$ID == 'washington-state')
# y <- 1
# i <- 1
year <- seq(from = 2005, to = 2021, by = 1)

# cl <- filter(cl,cl$Conference == 'ACC')
 #Scraping Website using rvest

Scrape_247_Data <- function(cl,year){
  bound_data <- data.frame()
  for(y in 1:length(year)){
    print(paste0('Year:', year[y]))
    for(i in 1:length(cl$ID)){
  
    print(paste0('Scraping ',cl$Name[i]))
  
  
    CFB2021page <- paste0("https://247sports.com/college/",cl$ID[i],"/Season/",year[y],'-Football/Commits/?sortby=rank')
      # CFB2021page <- paste0("https://247sports.com/college/",nebraska$ID[1],"/Season/",year[y],'-Football/Commits/?sortby=rank') #nebraska had to be difficult
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
    
    # player_location <- gsub('(Prep)',"",player_location)
  
    
    player_location <- regmatches(player_location, gregexpr("(?<=\\()([^()]*?)(?=\\)[^()]*$)", player_location, perl=T))  # Grabbing City / State and only taking data from last parenthesis
    player_location <- unlist(player_location)
    # player_location <- player_location[!grepl('Prep',player_location)] #just in case if Prep is in parenthesis
    # player_location <- player_location[!grepl('PREP',player_location)] #just in case if Prep is in parenthesis
    if(length(which(player_location <2)) > 0){
      player_names  <- player_names[-which(player_location <2)] 
    }
    
    #removing Foreign Players that dont have a location provided
    player_location <- player_location[nchar(player_location)>2]  #only keeping locations above 2 letters, just in case if a state by itself gets through
    
    player_position <- CFB2021 %>%
      rvest::html_nodes('div.position') %>%
      rvest::html_text()
    
    player_position <- gsub(" ",'',player_position) #cleaning up info
    player_position <- gsub('\n','',player_position) #cleaning up info
    player_position <- player_position[c(1:length(player_names))]  #removing Transfer Players
    
    
    player_rating <- CFB2021 %>% 
      rvest::html_nodes('span.score') %>%
      rvest::html_text()
    
    player_rating <- player_rating[c(1:length(player_names))] 
    player_rating <- as.numeric(player_rating)
    
    
    test <- CFB2021 %>% 
      rvest::html_nodes('span.icon-starsolid yellow')
    
    star_rating <- cut(player_rating, c(0,.01,.796,.89,.983,Inf),labels = c(0,2,3,4,5))
    
    
    
    data <- data.frame(player_names,player_location,player_position,player_rating, star_rating, stringsAsFactors = F)
    
    data$University <- cl$Name[i]
    data$Conference <- cl$Conference[i]
    data$Class      <- year[y]
    head(data)
    
    bound_data <- rbind(bound_data,data)
    # print(bound_data)
    # browser()
    # head(datalist)
    # datalist[[i]] <- data
    # print(head(datalist[[i]]))
    bound_data$player_rating[is.na(bound_data$player_rating)] <- 0
    bound_data$star_rating[is.na(bound_data$star_rating)] <- 0
    Sys.sleep(3)
    }
  }
 return(bound_data)
}

data <- Scrape_247_Data(cl = cl, year = year)
## Star Ratings based on https://247sports.com/college/georgia/LongFormArticle/Georgia-Bulldogs-Recruiting-Everything-you-need-to-know-about-247Sports-Rating-Process-143324123/#143324123_3
## >=98.3 = 5 Star
## >= 89 = 4 star
## >= 79.6 = 3 star
## <= 79.59 = 2 star
## NA Does Exist. Will change to 0 Star



### Geolocation Data for US Map
geolocation_data <- tidygeocoder::geo(data$player_location)
geolocation_data$address <- NULL
final_data <- dplyr::bind_cols(data,geolocation_data)
names(final_data) <- c('Player Name','City, State','Position','Composite Rating','Star Rating','University','Conference','Class','Latitude', 'Longitude')

write.csv(final_data,'./Player_Data.csv', row.names = FALSE)
