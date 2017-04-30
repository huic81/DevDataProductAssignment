#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
#install.packages("Quandl")
#install.packages("caret")
#install.packages("dplyr")
#install.packages("nloptr", repos='http://cran.rstudio.com/')
#library(nloptr)
library(Quandl)
library(dplyr)
library(plotly)
library(shiny)

# Retrieve source data
# Perform data exploratory & Cleaning
stockdata <- Quandl("MYX/FKLIU2017", api_key="cwsM4nx544ZcQkhDngzn")
newStockdata <- stockdata[order(as.Date(stockdata$Date, format="%Y-%m-%d")),]
newStockdata["OpenInterestPrev"] <- lag(newStockdata$`Open Interest`)
newStockdata["OpenInterest"] <- newStockdata$`Open Interest`
newStockdata[1, "OpenInterestPrev"] <- 0
newStockdata["SettlePredict"] <- NA
newStockdata["OpenInterestPredict"] <- NA
orderStockdata <- newStockdata[,c("Date","Previous","Settle","OpenInterest","OpenInterestPrev", "SettlePredict", "OpenInterestPredict", "Volume")]

# Set Model
set.seed(12345) 
#1st redict Open Interest based on past records
initial_model <- lm(OpenInterest ~ Date + OpenInterestPrev, data = orderStockdata)
#summary(initial_model)
#97.86%

#Then predict settle
best_model <- lm(Settle ~ Previous + OpenInterest + Date, data = orderStockdata)
#summary(best_model)
#84.86%

lastrow <- nrow(orderStockdata)
setPrev <- orderStockdata$Settle[lastrow]
setOIPrev <- orderStockdata$OpenInterest[lastrow]

predictData <- data.frame("Date" = as.Date(character()),
                          "Previous" = numeric(),
                          "Settle" = numeric(),
                          "OpenInterest" = numeric(), 
                          "OpenInterestPrev" = numeric(), 
                          "SettlePredict" = numeric(),
                          "OpenInterestPredict" = numeric(),
                          "Volume" = numeric())

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

output$opredictDate <- renderPrint({input$predictDate})

# Set Prediction Data
# set open interest predict data and predict OI
getPredictOI <- function(initialmodel, predictDate) {
  predictData <- rbind(predictData, data.frame(Date = predictDate, 
                                                          Previous = setPrev,
                                                          Settle = 0,
                                                          OpenInterest = 0,
                                                          OpenInterestPrev = setOIPrev,
                                                          SettlePredict = 0,
                                                          OpenInterestPredict = 0,
                                                          Volume = 0))
  predictOI <- predict(initialmodel, newdata=predictData)
  names(predictOI) <- NULL
  predictOI
}

# set settle predict data and predict settle
getPredictSettle <- function(bestmodel, predictDate, openInterestPred) {
  predictData <- rbind(predictData, data.frame(Date = predictDate,
                                               Previous = setPrev,
                                               Settle = 0,
                                               OpenInterest = openInterestPred,
                                               OpenInterestPrev = setOIPrev,
                                               SettlePredict = 0,
                                               OpenInterestPredict = openInterestPred,
                                               Volume = 0))
  predictSettle <- predict(bestmodel, newdata=predictData)
  names(predictSettle) <- NULL
  predictSettle
}

# Add the predicted line to the data frame
addPredictedValue <- function(predictDate, openInterestPred, SettlePred) {
  if (predictDate > orderStockdata$Date[nrow(orderStockdata)])
  {  orderStockdata <- rbind(orderStockdata, data.frame(Date = predictDate,
                                                  Previous = NA,#setPrev,
                                                  Settle = NA,
                                                  OpenInterest = NA,
                                                  OpenInterestPrev = setOIPrev,
                                                  SettlePredict = SettlePred,
                                                  OpenInterestPredict = openInterestPred,
                                                  Volume = NA))
  }
  orderStockdata
}

# Add the predicted value to the data frame
addFittedValue <- function(predictDate, openInterestPred, SettlePred) {
  if (predictDate > orderStockdata$Date[nrow(orderStockdata)])
  {  orderStockdata <- rbind(orderStockdata, data.frame(Date = predictDate,
                                                     Previous = setPrev,
                                                     Settle = SettlePred,
                                                     OpenInterest = openInterestPred,
                                                     OpenInterestPrev = setOIPrev,
                                                     SettlePredict = SettlePred,
                                                     OpenInterestPredict = openInterestPred,
                                                     Volume = NA))
  }
  orderStockdata
}

# Print the predicted OI to screen
output$opredictOI <- renderPrint({
  #class(predictData)
  resultOI <- getPredictOI(initial_model, input$predictDate)
  predictData[1,"OpenInterest"] <- resultOI
  if (input$predictDate > orderStockdata$Date[nrow(orderStockdata)])
  {  resultOI
  } else {"Please select future Date! You can check historical price by mouse hover the graph!"}
})

# Print the predicted settle to screen
output$opredictSettle <- renderPrint({
  resultOI <- getPredictOI(initial_model, input$predictDate)
  resultSettle <- getPredictSettle(best_model,input$predictDate, resultOI)
  if (input$predictDate > orderStockdata$Date[nrow(orderStockdata)])
  {  resultSettle
  } else {"Please select future Date! You can check historical price by mouse hover the graph!"}
})

# print the plot
output$plotlyplot <- renderPlotly({
  
  resultOI <- getPredictOI(initial_model, input$predictDate)
  resultSettle <- getPredictSettle(best_model,input$predictDate, resultOI)
  
  orderStockdata <- addPredictedValue(input$predictDate, resultOI, resultSettle)
  fittedorderStockdata <- addFittedValue(input$predictDate, resultOI, resultSettle)
  new_best_model <- lm(Settle ~ Previous + OpenInterest + Date, data = fittedorderStockdata)
  
  customMargin <- list(
    l = 80,
    r = 80,
    b = 50,
    t = 50,
    pad = 5
  )
  
  myplot <- plot_ly(orderStockdata) %>%
    add_trace(x = ~Date, y = ~OpenInterest, type = 'bar', name = 'Actual Open Interest', 
              marker = list(color = '#C9EFF9'),
              hoverinfo = "text",
              text = ~OpenInterest) %>%
    
    add_trace(x = ~Date, y = ~OpenInterestPredict, name = 'Predicted Open Interest', type = 'bar', marker = list(color = '#154360'),
              hoverinfo = "text", text = ~OpenInterestPredict, yaxis = 'y') %>%  
    
    add_trace(x = ~Date, y = ~Settle, name = 'Actual Settle', type = 'scatter', mode = 'lines+markers', yaxis = 'y2') %>%
    add_trace(x = ~Date, y = ~SettlePredict, name = 'Predicted Settle', type = 'scatter', mode = 'markers', yaxis = 'y2') %>%
    add_trace(x = ~Date, y = ~fitted(new_best_model), name = 'Settle Trend', mode = 'lines', yaxis = 'y2') %>%
    
    layout(title = 'Kuala Lumpur Composite Index Futures (FKLI)',
           xaxis = list(title = "Date"),
           yaxis = list(side = 'left', title = 'Open Interest', showgrid = FALSE, zeroline = FALSE),
           yaxis2 = list(side = 'right', title = 'Market Price', overlaying = "y", 
                         showgrid = FALSE, zeroline = FALSE),
           margin = customMargin
    )
  
  if (input$legend) {
    myplot <- myplot  %>%
    layout(legend = list(x = 1.1, y = 0.9)) %>%
    layout(showlegend = TRUE)
  } else {
    myplot <- myplot %>%
      layout(showlegend = FALSE)
  }
  
  myplot
})

# print the selected point ont he plot
output$event <- renderPrint({
  d <- event_data("plotly_hover")
  if (is.null(d)) "Hover on a point on the graphs!" 
  else d
})

})
