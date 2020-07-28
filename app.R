library(tidyverse)
library(magrittr)
library(shiny)
library(shinyjs) #needed for hiding and showing things
#library(data.table)
library(DT)
#library(shinyalert) #use to make popups, maybe showing card image or info

source("helpers.R")
options(dplyr.summarise.inform=F) #block obscure dplyr warning

#data import
heroes=read_csv('data/heroes.csv')
schemes=read_csv('data/schemes.csv')
villains=read_csv('data/villains.csv')
henchmen=read_csv('data/henchmen.csv')
masterminds=read_csv('data/masterminds.csv')

heroestext = read_tsv('data/heroestext.csv')
heroestext %<>% 
    select(-id) %>%
    rename(id = heroname)
mmtext = read_tsv('data/mmtext.csv')
mmtext %<>% rename(id = mmtext)

tooltext = rbind(select(heroestext,text,id),mmtext)

#format data as list
src = list(heroes,schemes,villains,henchmen,masterminds)
names(src) = c("heroes","schemes","villains","henchmen","masterminds")

#format a list of heroes with proper ids
#arrange by abc and add an empty initial value
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

#format a list of masterminds
mmlist = distinct(filter(src$masterminds,!is.na(MM)),MM)
mmlist = rbind(mmlist,MM="")
mmlist %<>% arrange(MM)
mmaslist = as.list(t(mmlist$MM))
names(mmaslist) = mmlist$MM
names(mmaslist)[1] = " "

#format a list of schemes
schlist = distinct(src$schemes,Name)
schlist = rbind(schlist,Name="")
schlist %<>% arrange(Name)
schemaslist = as.list(t(schlist$Name))
names(schemaslist) = schlist$Name
names(schemaslist)[1] = " "

#format a list of sets
setlist = read_csv("data/sets.csv")
setlist[1,] = c(""," ")
setaslist = as.list(t(setlist$id))
names(setaslist) = setlist$label

ui <- fluidPage(
    useShinyjs(),
    #useShinyalert(),
    titlePanel("Marvel Legendary Setup Generator"),
    sidebarLayout(
        sidebarPanel(
            fluidRow(
            column(
                numericInput("playerc",
                                "Number of Players",
                                2,2,5,1),
                width=6
                ),
            column(
                actionButton("presets",
                             "Presets?"),
                width=5,
                offset=1,
                style = "margin-top: 20px;"
                )),
            hidden(selectizeInput("fixedSCH",
                           "Scheme",
                           choices=schemaslist)),
            hidden(selectizeInput("fixedMM",
                           "Mastermind",
                           choices=mmaslist)),
            hidden(selectizeInput("fixedHM",
                           "Henchmen",
                           choices=henchaslist)),
            hidden(selectizeInput("fixedVIL",
                           "Villains",
                           choices=vilaslist,
                           multiple=T,
                           options = list(maxItems=6))),
            hidden(selectizeInput("fixedHER",
                           "Heroes",
                           choices = heroaslist,
                           multiple=T,
                           options = list(maxItems=8))),
            fluidRow(
            column(selectizeInput("dropset",
                           "Sets excluded",
                           choices=setaslist,
                           multiple=T),
                   width=8),
            column(checkboxInput("epic","Epic?"),
                   width=4,
                   style = "margin-top: 20px;")),
            fluidRow(
                column(selectizeInput("incset",
                               "Sets included",
                               choices=setaslist,
                               multiple=T),
                       width=9),
                column(numericInput("incsetThreshold",
                             "Min:",
                             1,1,5,1),
                       width=3)),
            actionButton("go",
                         "Start"),
            uiOutput("gameslider"),
            width=5
        ),
        mainPanel(dataTableOutput("setups"),
                  br(),
                  hidden(actionButton("print","Copy setup")),
                  textOutput("printsuccess"),
                  br(),
                  hidden(actionButton("metricsgo","Get Metrics")),
                  tableOutput("metrics"),
                  width=7)
    )
)

server <- function(input, output) {
    
    observeEvent(input$presets, {
        toggle("fixedSCH")
        toggle("fixedMM")
        toggle("fixedHM")
        toggle("fixedVIL")
        toggle("fixedHER")
    })
    gamelist <- eventReactive(input$go,{
        withProgress(message = "Processing",value = 0, {
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
            incProgress(0.01,detail = paste("Setup",i))
        }
        games = setGames(games,
                         setreq = input$incset,
                         dropgames = input$incsetThreshold)
        })
        hide("metrics")
        return(games)
    })
    observeEvent(input$go,{
        output$gameslider <- renderUI({
            sliderInput("selectgame", 
                        label = "Selected setup:",
                        min = 1,
                        max = length(gamelist()),
                        value = 1,
                        step = 1)
        })
    })
    livesetup <- eventReactive(input$selectgame,{
        summ = setupSumm(gamelist()[[input$selectgame]],
                         input$selectgame)
        return(summ)
    })
    observeEvent(input$selectgame,{
        output$setups <- DT::renderDataTable(livesetup(),
                                             escape=F,
                                             rownames=F,
                                             selection=list(
                                                 mode="single"),
                                             options = list(
                                                 paging = F,
                                                 searching = F,
                                                 ordering = F,
                                                 info = F))
        show("print")
        show("metricsgo")
    })
    observeEvent(input$setups_cell_clicked, {
        text = filter(tooltext,id%in%livesetup()[input$setups_rows_selected,1])
        if (dim(text)[1]>0) {
            text %<>% mutate(text = gsub("\n","<br>",text))
        showModal(modalDialog(title = paste0(text$id," Card Text"),
                  HTML(paste(text$text,collapse="<br><br>")),
                  easyClose = T,
                  footer=NULL))
        }
    })
    observeEvent(input$metricsgo,{
        metrics = metricsLoop(gamelist())
        output$metrics = renderTable(metricsPrint(metrics[[input$selectgame]]),
                                     rownames = T,
                                     colnames = T,
                                     sanitize.text.function=identity)
        show("metrics")
    })
    observeEvent(input$print,{
        setupPrint(gamelist()[[input$selectgame]])
        output$printsuccess = renderText({
            paste0("Setup ",isolate(input$selectgame)," copied succesfully!")
        })
    })
}

shinyApp(ui = ui, server = server)
