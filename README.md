# CFB-247-Rvest-Scrape
Project Goal: Create a RShiny application that will use scraped data using rvest from 247's Recruitment Website for all Power 5 Universities.

Files Used (in Order you should use)
./Scrape247.R
- Scrapes data from 247 using Rvest and combines the data together
- If you are running for the first time please make the first_run variable TRUE as it will grab all years you want. By turning first_run = FALSE the script only attmepts to grab the singular year provided and binds it to the previous existing file.

./CFBRecruit/ ui & server
- ui and server script for Shiny App
