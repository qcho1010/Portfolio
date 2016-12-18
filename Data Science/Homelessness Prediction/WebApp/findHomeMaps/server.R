
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
#

library(shiny)
library(leaflet)
library(RDSTK)
library(RMySQL)


calculateAvailableResources <- function(x, y){
  result = x - y
  return(result)
}


calculateNearestShelterWithBeds <- function(currentShelterID, shelterDF){
  
  minimalDifference = 100
  nearestShelterWithBeds = NULL
  for(shelter in shelterDF){
    
    #assuming that the other shelter has some space for walkins
    if(shelter$availableResources > 5){
      next
    }
    
    #calculate difference between shelters 
    latitudeDifference = (currentShelter@latitude - shelter@latitude)^2
    longitudeDifference = (currentShelter@longitude - shelter@longitude)^2
    
    differenceVector = sqrt(latitudeDifference + longitudeDifference)
    if(differenceVector < minimalDifference){
          minimalDifference = differenceVector
          nearestShelterWithBeds = shelter
    }
  }
  
  return(nearestShelterWithBeds)
}


addNumAvailable <- function(shelterDataframe){
  as.data.frame(shelterDataframe)
  shelterDataframe$NumAvailable = 0
  
  for (variable in 1:length(shelterDataframe)) {
    shelterDataframe[i,]$NumAvailable = shelterDataframe[i,]$NumTotal - shelterDataframe[i,]$NumUsed 
 
  }
  }



calculateGPSCoordinates <- function(thing) {
#  coordinates = NULL
#  for(i in 1:length(addresses)){
#    if(is.data.frame(coordinates)){
#      coordinates = rbind(coordinates, street2coordinates(addresses[i])) 
#    } else {
#      coordinates = street2coordinates(addresses[i])
#    }
#  }
}

concatenateAddress <- function(rowData){
  stringData = c(as.character(rowData['HouseNum']), ' ', as.character(rowData['Street']), ', ', as.character(rowData['City']), ' ', as.character(rowData['State']), ', ', as.character(rowData['Zip']))
  stringData = paste(stringData, collapse = '')
  return(stringData)
  }




shinyServer(function(input, output) {
  
  
  # GET THAT DATABASE CONNECTION 
  mydb <- dbConnect(RMySQL::MySQL(), user='GHack', password='GlobalHack123!', dbname='globalhack', host='Globalhack.il1.rdbs.ctl.io', port=49424)
 
  #RESULTS
  result = dbSendQuery(mydb, "select * from Facilities f left join Resources r on f.ID = r.Facility order by f.ID")
  names <- fetch(result, n=-1)
  dbClearResult(result)
  
  dbDisconnect(mydb)
  
  #######################################
  # GET THE COORDINATES! 
  names$NumAvailable = names$NumTotal - names$NumUsed
  
  names$NumAvailable = sprintf("Available: %d/%d", names$NumAvailable, names$NumTotal)
  names$Description = sprintf("%s\n%s", names$Description, names$NumAvailable)
  
  leafletstuff = leaflet(data = names[1:length(names)]) %>% addTiles() %>%
      addMarkers(clusterOptions = markerClusterOptions(), lng = ~Longitude,lat = ~Latitude, popup = ~Description)
  print(leafletstuff)

  
  output$map <- renderLeaflet(leafletstuff)
  
})
