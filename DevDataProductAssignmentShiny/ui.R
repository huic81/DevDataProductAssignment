#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
#library(leaflet)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Kuala Lumpur Composite Index (FKLI)"),
  h3("Select a Date under the input section and this app will provide predicted Settle Market Price on the selected date!"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h2("Input:"),
      h3("Select Date to predict!"),
      dateInput("predictDate", "Date:"),
      checkboxInput("legend", "Show legend", TRUE),

      tags$hr(),
      h2("Prediction Result:"),
      h3("Prediction Date: "),
      verbatimTextOutput("opredictDate"),
      h3("Predicted Open Interest: "),
      verbatimTextOutput("opredictOI"),
      h3("Predicted Settle Price: "),
      verbatimTextOutput("opredictSettle"),
      
      h3("Detail of Selected Point on the Graph: "),
      verbatimTextOutput("event")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h2("Kuala Lumpur Composite Index (FKLI) Plot"),
      plotlyOutput("plotlyplot"),
      
      tags$hr(),
      h2("About this App:"),
      h3("Input:"),
      h4("Input Section accept a Date selected by user."),
      
      h3("Prediction Result:"),
      h4("Prediction Result Section returned estimated value on the selected date."),
      
      tags$hr(),
      h2("About The Data:"),
      tags$ol(
        tags$li("This app use live dataset that refreshed daily which consists of market history for Kuala Lumpur Composite Index Futures (FKLI) in year 2017."), 
        tags$li("The data is provided by an exchange holding company in Malaysia, BURSA Malaysia."), 
        tags$li("The data retrieval API was privided by Quandl API."), 
        tags$li("The data can be validated against the historical data provided at the link below")
      ),
      h3("Link to Data:"),
      tags$a(href="http://www.bursamalaysia.com/market/derivatives/market-statistics/historical-data/", "Historical Data in BURSA Market Statistics")
      
    )
  )
))