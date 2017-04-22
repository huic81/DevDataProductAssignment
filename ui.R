#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Sales Territory by 22 April 2017"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h1("Move slider to check Sales!"),
      sliderInput("salesofficecountSlider",
                   "No of Sales Office:",
                   min = 1,
                   max = 10,
                   value = 5),
      checkboxInput("legend", "Show legend", TRUE)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("salesMap")
    )
  )
))
