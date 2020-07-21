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
options(dplyr.summarise.inform=F) 

#data import
heroes=read_csv('data/heroes.csv')
schemes=read_csv('data/schemes.csv')
villains=read_csv('data/villains.csv')
henchmen=read_csv('data/henchmen.csv')
masterminds=read_csv('data/masterminds.csv')

#format data as list
src = list(heroes,schemes,villains,henchmen,masterminds)
names(src) = c("heroes","schemes","villains","henchmen","masterminds")

#format a list of heroes with proper ids
src$heroes$uni = paste(src$heroes$Hero,src$heroes$Set,sep="_")
herolist = distinct(src$heroes,uni)
herolist = rbind(herolist,uni="")
herolist %<>% arrange(uni)
herolist$name = gsub("_"," (",herolist$uni)
herolist$name = paste0(herolist$name,")")
herolist$name[1] = ""
heroaslist = as.list(t(herolist$uni))
names(heroaslist) = herolist$name
names(heroaslist)[1] = " "

#format a list of henchmen
henchlist = distinct(src$henchmen,Name)
henchlist = rbind(henchlist,Name="")
henchlist %<>% arrange(Name)
henchaslist = as.list(t(henchlist$Name))
names(henchaslist) = henchlist$Name
names(henchaslist)[1] = " "

#format a list of villains
villist = distinct(src$villains,Group)
villist = rbind(villist,Group="")
villist %<>% arrange(Group)
vilaslist = as.list(t(villist$Group))
names(vilaslist) = villist$Group
names(vilaslist)[1] = " "

#format a list of sets
setlist = read_csv("data/sets.csv")
setlist[1,] = c(""," ")
setaslist = as.list(t(setlist$id))
names(setaslist) = setlist$label

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
            selectizeInput("fixedHM",
                           "Henchmen",
                           choices=henchaslist,
                           selected=NULL),
            selectizeInput("fixedVIL",
                           "Villains",
                           choices=vilaslist,
                           multiple=T,
                           options(list(maxItems=2))),
            selectizeInput("fixedHER",
                           "Heroes",
                           choices = heroaslist,
                           multiple=T,
                           options(list(maxItems=5))),
            checkboxInput("epic","Epic?"),
            selectizeInput("dropset","Sets excluded",choices=setaslist,multiple=T),
            actionButton("go","Start"),
            #numericInput("runs","Number of runs",value=100,min=1,max=2000,step=10),
            sliderInput("game", 
                        label = "Selected setup:",
                        min = 1, max = 100, value = 1)#,
            #br(),
            #actionButton("teamlookup","Hero's Team?")
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
                            epic = input$epic,
                            dropset=input$dropset)
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
        metrics = metricsLoop(gamelist())
        output$metrics = renderTable(metricsPrint(metrics[[input$game]]),
                                     rownames = T,
                                     colnames = T,
                                     sanitize.text.function=identity)
    })
    # observeEvent(input$teamlookup,{
    #     output$herosteam = renderText({
    #         paste0("Hero's team: ",
    #                teamlookup(isolate(input$fixedHER),
    #                           src))
    #         })
    # })
    observeEvent(input$print,{
        setupPrint(gamelist()[[input$game]])
        output$printsuccess = renderText({
            paste0("Setup ",isolate(input$game)," copied succesfully!")
        })
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
