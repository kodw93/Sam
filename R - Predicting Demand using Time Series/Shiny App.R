#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(zoo)
library(dplyr)
library(forecast)
library(ggplot2)
options(warn=-1)
options(scipen=999)

# make sure to set your WD to a source file destination

# daily data
data.new = read.csv('Daily.csv')
data.new$Date = seq(from = as.POSIXct("2011-01-28"), to = as.POSIXct("2016-05-22"), by = 'day')
data.new$CA_total = data.new$CA_FOODS+data.new$CA_HOBBIES+data.new$CA_HOUSEHOLD
data.new$Frequency = 365.25

# weekly data
data.weekly = read.csv("Weekly.csv")
data.new1 = data.weekly[1:277,]
data.new1$Date = seq(from = as.POSIXct("2011-01-01"), to = as.POSIXct("2016-04-22"), by = 'week')
data.new1$CA_total = data.new1$CA_FOODS+data.new1$CA_HOBBIES+data.new1$CA_HOUSEHOLD
data.new1$Frequency = 52

# monthly data
data.new2 = read.csv("Monthly.csv")
data.new2$Date = seq(from = as.POSIXct("2011-01-01"), to = as.POSIXct("2016-05-21"), by = 'month')
data.new2$CA_total = data.new2$CA_FOODS+data.new2$CA_HOBBIES+data.new2$CA_HOUSEHOLD
data.new2$Frequency = 12

freq = c('Daily', 'Weekly', 'Monthly')

ui <- fluidPage(theme = shinytheme("lumen"),
                titlePanel("Walmart Sales in California Over Time"),
                sidebarLayout(
                    sidebarPanel(
                        # frequency
                        selectInput(inputId = "freq", label = strong("Data Frequency"),
                                    choices = freq,
                                    selected = "Daily"),
                        # date
                        dateRangeInput("date", strong("Date range"), start = "2011-02-01", end = "2016-05-21",
                                       min = "2011-02-01", max = "2016-05-21"),
                        # smoothing
                        checkboxInput(inputId = "smoother", label = strong("Smooth Out Trend"), value = TRUE),
                        
                        conditionalPanel(condition = "input.smoother == true",
                                         sliderInput(inputId = "f", label = "Span (alpha):",
                                                     min = 0.01, max = 1, value = 0.2, step = 0.01,
                                                     animate = animationOptions(interval = 100)),
                                         HTML("Higher values give more smoothness.")),
                        
                        conditionalPanel(condition = "input.freq == 'Daily'",
                                         sliderInput(inputId = "d", label = "Forecasting Horizon:",
                                                     min = 1, max = 365, value = 30, step = 30,
                                                     animate = animationOptions()),
                                         HTML("Longer horizon results in less reliable forecasts")),
                        
                        conditionalPanel(condition = "input.freq == 'Weekly'",
                                         sliderInput(inputId = "w", label = "Forecasting Horizon:",
                                                     min = 1, max = 52, value = 16, step = 5,
                                                     animate = animationOptions()),
                                         HTML("Longer horizon results in less reliable forecasts")),
                        
                        conditionalPanel(condition = "input.freq == 'Monthly'",
                                         sliderInput(inputId = "m", label = "Forecasting Horizon:",
                                                     min = 1, max = 12, value = 4, step = 1,
                                                     animate = animationOptions()),
                                         HTML("Longer horizon results in less reliable forecasts"))
                        ),
                    mainPanel(
                        plotOutput(outputId = "timeplot", height = "300px"),
                        plotOutput(outputId = "forecasts", height = "300px"),
                        textOutput(outputId = "accuracy"),
                        plotOutput(outputId = "errors", height = "300px")
                    )
                )
)

server <- function(input, output) {

    selected_trends <- reactive({
        req(input$date)
        validate(need(!is.na(input$date[1]) & !is.na(input$date[2]), "Error: Please provide both a start and an end date."))
        validate(need(input$date[1] < input$date[2], "Error: Start date should be earlier than end date."))
        if(input$freq=='Daily'){
            data.new %>%
                filter(
                    Date > as.POSIXct(input$date[1]) & Date < as.POSIXct(input$date[2]
                    ))
        } else if(input$freq=='Weekly'){
            data.new1 %>%
                filter(
                    Date > as.POSIXct(input$date[1]) & Date < as.POSIXct(input$date[2]
                    ))
        } else{
            data.new2 %>%
                filter(
                    Date > as.POSIXct(input$date[1]) & Date < as.POSIXct(input$date[2]
                    ))
        }
    })
    
    output$timeplot <- renderPlot({
        color = "#434343"
        plot(x = selected_trends()$Date, y = selected_trends()$CA_total, type = "l",
             xlab = "Time", ylab = "USD", main = "Historical Walmart Sales in California",
             col = color, fg = color, col.lab = color, col.axis = color)
        
        if(input$smoother){
            smooth_curve <- lowess(x = as.numeric(selected_trends()$Date), y = selected_trends()$CA_total, f = input$f)
            lines(smooth_curve, col = "#E6553A", lwd = 3)
        }
    })
    
    output$forecasts <- renderPlot({ # models selected based on best test performance
        temp = ts(selected_trends()$CA_total, frequency = selected_trends()$Frequency[1])
        if(input$freq=='Monthly'){ # SARIMA(1,1,2)x(1,1,0)12
            mod = Arima(temp, order = c(1, 1, 2),
                        seasonal=list(order=c(1,1,0), period=12))
            pred = forecast(mod, h = input$m)
        } else if(input$freq=='Weekly'){ # SARIMA(1,1,0)x(1,1,0)52
            mod = Arima(temp, order=c(1, 1, 0), 
                        seasonal=list(order=c(1,1,0), period=52))
            pred = forecast(mod, h = input$w)
        } else { # sNaive for Daily data (for demo purposes)
            mod = snaive(temp, h = round(frequency(temp)))
            pred = forecast(mod, h = input$d)
        }
        
        autoplot(temp, ylab = 'USD', main = 'Observed & Fitted', series = 'Observed')+
            autolayer(pred, series = 'Fitted')+
            theme(axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank())
    })
    
    output$accuracy <- renderText({
        temp = ts(selected_trends()$CA_total, frequency = selected_trends()$Frequency[1])
        if(input$freq=='Monthly'){
            mod =  Arima(temp, order = c(1, 1, 2),
                        seasonal=list(order=c(1,1,0), period=12))
        } else if(input$freq=='Weekly'){
            mod = Arima(temp, order=c(1, 1, 0), 
                        seasonal=list(order=c(1,1,0), period=52))
        } else {
            mod = snaive(temp, h = round(frequency(temp)))
        }
        paste("\t", "On average, the model is expected to be", round(accuracy(mod)[2],2), 
        "$ or equivalently", round(accuracy(mod)[5],2), "% off.")
    })
    
    output$errors <- renderPlot({
        temp = ts(selected_trends()$CA_total, frequency = selected_trends()$Frequency[1])
        if(input$freq=='Monthly'){
            mod = Arima(temp, order = c(1, 1, 2),
                        seasonal=list(order=c(1,1,0), period=12))
        } else if(input$freq=='Weekly'){
            mod = Arima(temp, order=c(1, 1, 0), 
                        seasonal=list(order=c(1,1,0), period=52))
        } else {
            mod = snaive(temp, h = round(frequency(temp)))
        }
        checkresiduals(mod$residuals)
        })
}

# Run the application 
shinyApp(ui = ui, server = server)
