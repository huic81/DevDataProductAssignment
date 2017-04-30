#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(Quandl)
library(dplyr)
library(plotly)
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Kuala Lumpur Composite Index (FKLI)"),
  h3("Select a Date under the input section and this app will provide predicted Settle Market Price on the selected date!"),
  h4("Please wait while data and graph is loading! Thanks!"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h2("Input:"),
      dateInput("predictDate", "Select Future Date to Predict:"),
      checkboxInput("legend", "Show legend", TRUE),

      tags$hr(),
      h2("Prediction Result:"),
      h4("Prediction Date: "),
      verbatimTextOutput("opredictDate"),
      h4("Predicted Open Interest: "),
      verbatimTextOutput("opredictOI"),
      h4("Predicted Settle Price: "),
      verbatimTextOutput("opredictSettle"),
      
      h4("Detail of Selected Point on the Graph: "),
      verbatimTextOutput("event")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h2("Kuala Lumpur Composite Index (FKLI) Plot"),
      plotlyOutput("plotlyplot"),
      
      tags$hr(),
      h2("About this App:"),
      h3("Input Section accepts:"),
      tags$ol(
        tags$li("A future date selected by user (Date Picker) - the app will predict price on the selected date."), 
        tags$li("Whether to show or to hide the legend (Check box) - the app with show/hide legend.")
        ),
      h3("Prediction Result Section displays:"),
      tags$ol(
        tags$li("Prediction Date - the date which application estimate prediction on."), 
        tags$li("Predicted Open Interest - Predicted Open Interest count on the selected date."), 
        tags$li("Predicted Settle Price - Predicted settle price on the selected date."), 
        tags$li("Detail of Selected Point on the Graph - details of the selected point by mouse hover on the graph.")
      ),
      
      tags$hr(),
      h2("About The Data:"),
      tags$ol(
        tags$li("This app use live dataset that refreshed daily which consists of market history for Kuala Lumpur Composite Index Futures (FKLI) in year 2017."), 
        tags$li("The data is provided by an exchange holding company in Malaysia, BURSA Malaysia."), 
        tags$li("The data retrieval API was privided by Quandl API."), 
        tags$li("The data can be validated against the historical data provided at the link below")
      ),
      h3("Link to Data:"),
      tags$a(href="http://www.bursamalaysia.com/market/derivatives/market-statistics/historical-data/", "Historical Data in BURSA Market Statistics"),
      h3("The code (server.R and ui.R) is avilable at:"),
      tags$a(href="https://github.com/huic81/DevDataProductAssignment/tree/master/DevDataProductAssignmentShiny", "The GitHub Repository"),
      tags$br(),
      tags$br()
    )
  )
))