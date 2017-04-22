#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
    popupSalesOffice <- c("Sales Office 1", "Sales Office 2", "Sales Office 3", "Sales Office 4", "Sales Office 5",
                          "Sales Office 6", "Sales Office 7", "Sales Office 8", "Sales Office 9", "Sales Office 10")
    colorSalesOffice <- c("blue", "red", "green", "yellow", "purple", 
                          "navy", "pink", "brown", "orange", "black")
    noOfSample <- 150
    set.seed(20170422)
    latraw <- c(runif(noOfSample, min = 3.0000000, max = 3.2500000))
    longraw <- runif(noOfSample, min = 101.5500000, max = 101.7000000)
    salesraw <- c(runif(noOfSample, min = 5000, max = 50000))
    colraw <- sample(colorSalesOffice, noOfSample, replace = TRUE)
    
    dfSales <- data.frame(lat = latraw, 
                          lng = longraw,
                          sales = salesraw,
                          col = colraw, stringsAsFactors = FALSE)
    #dfSales$salesText <- as.character(round(dfSales$sales,-3))
    
    output$salesMap <- renderLeaflet({
    sales_map <- 
      dfSales %>%
      leaflet() %>% 
      addTiles() %>% #plot the map and mapping data
      addCircleMarkers(color = dfSales$col, 
                       labelOptions = labelOptions(noHide = TRUE, direction = 'right', textOnly = TRUE),
                       radius = sqrt(dfSales$sales)/10,
                       clusterOptions = markerClusterOptions()
      ) %>%  #add marker on sales cluster
      #addCircles(weight = 0.5, radius = sqrt(dfSales$sales)/100) %>% #add marker on sales figure
      addLegend(labels = popupSalesOffice, colors = colorSalesOffice)
    
      #plot final map
      sales_map
    })
    
    dfSalesNew <- reactive({ dfSales[which(dfSales$col %in% colorSalesOffice[1:input$salesofficecountSlider]),]  })

    observe({
      leafletProxy("salesMap", data = dfSalesNew()) %>%
      clearShapes() %>%
      #clearControls() %>%
      clearMarkerClusters() %>%
      clearMarkers() %>%
      addCircleMarkers(color = ~col, 
                         radius = sqrt(dfSales[input$topSalesSlider,]$sales)/10,
                         clusterOptions = markerClusterOptions()
      ) #%>%
      #addLegend(labels = popupSalesOffice[1:input$salesofficecountSlider], colors = colorSalesOffice[1:input$salesofficecountSlider])
    })
    
    observe({
      proxy <- leafletProxy("salesMap", data = dfSales)
      proxy %>% clearControls()
      if (input$legend) {
        proxy %>% addLegend(labels = popupSalesOffice[1:input$salesofficecountSlider], colors = colorSalesOffice[1:input$salesofficecountSlider])
      }
    })

})
