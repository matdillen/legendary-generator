#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(tidyverse)
library(magrittr)
library(shiny)
#library(listviewer)

source("helpers.R")

heroes=read_csv('data/heroes.csv')
schemes=read_csv('data/schemes.csv')
villains=read_csv('data/villains.csv')
henchmen=read_csv('data/henchmen.csv')
masterminds=read_csv('data/masterminds.csv')
src = list(heroes,schemes,villains,henchmen,masterminds)
names(src) = c("heroes","schemes","villains","henchmen","masterminds")    

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Marvel Legendary Setup Generator"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            numericInput("playerc","Number of Players",2,2,5,1),
            textInput("fixedSCH","Scheme"),
            textInput("fixedMM","Mastermind"),
            textInput("fixedHM","Henchmen"),
            textInput("fixedVIL","Villains"),
            textInput("fixedHER","Heroes"),
            checkboxInput("epic","Epic?"),
            actionButton("go","Start"),
            #numericInput("runs","Number of runs",value=100,min=1,max=2000,step=10),
            sliderInput("game", 
                        label = "Selected setup:",
                        min = 1, max = 100, value = 1),
            br(),
            actionButton("teamlookup","Hero's Team?")
        ),
        # Show a plot of the generated distribution
        mainPanel(tableOutput("setups"),
                  actionButton("print","Copy setup"),
                  textOutput("printsuccess"),
                  br(),
                  textOutput("herosteam"),
                  tableOutput("metrics"))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    gamelist <- eventReactive(input$go,{
        games=list()
        for (i in 1:100) {
            games[[i]] = genFun(src,
                            playerc = input$playerc,
                            fixedSCH = input$fixedSCH,
                            fixedMM = input$fixedMM,
                            fixedHM = input$fixedHM,
                            fixedVIL = input$fixedVIL,
                            fixedHER = input$fixedHER,
                            epic = input$epic)
        }
        
        return(games)
    })
    observeEvent(input$go,{
        output$setups <- renderTable(setupSumm(gamelist()[[input$game]],
                                               input$game),
                                     hover=T,
                                     rownames=T,
                                     sanitize.text.function=identity)
    })
    observeEvent(input$go,{
        metrics = metricsGen(gamelist(),input$game)
        output$metrics = renderTable(metricsPrint(metrics))
    })
    observeEvent(input$teamlookup,{
        output$herosteam = renderText({
            paste0("Hero's team: ",
                   teamlookup(isolate(input$fixedHER),
                              src))
            })
    })
    observeEvent(input$print,{
        setupPrint(gamelist()[[input$game]])
        output$printsuccess = renderText({
            paste0("Setup ",isolate(input$game)," copied succesfully!")
        })
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
