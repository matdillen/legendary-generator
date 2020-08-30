pkgLoad <- function() {
    
    packages <- c("DT",
                   "tidyverse",
                   "magrittr",
                   "shiny",
                   "shinyjs",
                   "shinythemes")
    packagecheck <- match( packages, utils::installed.packages()[,1])
    packagestoinstall <- packages[is.na(packagecheck)]
    
    if(length( packagestoinstall) > 0 ) {
        utils::install.packages(packagestoinstall)
    } else {
        print("All requested packages already installed")
    }
    
    for(package in packages) {
        suppressPackageStartupMessages(
            library(package,
                    character.only = T,
                    quietly = T))
    }
}

pkgLoad()

library(tidyverse)
library(magrittr)
library(shiny)
library(shinyjs)
library(DT)
library(shinythemes)

source("helpers.R")

options(dplyr.summarise.inform=F) #block obscure dplyr warning

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
#arrange by abc and add an empty initial value
src$heroes$uni = paste0(src$heroes$Hero," (",src$heroes$Set,")")
herolist = distinct(src$heroes,uni)
herolist = rbind(herolist,uni="")
herolist %<>% arrange(uni)
heroaslist = as.list(t(herolist$uni))
names(heroaslist) = herolist$uni
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

keywords = read_tsv("data/keywords2.txt")
keywords[is.na(keywords)] = ""

tooltext = read_tsv("data/tooltext.txt")

ui <- fluidPage(
    #theme = shinytheme("united"),
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
                    br(),
                    actionButton("pastesetup",
                                 "Paste"),
                    width=5,
                    offset=1
                )),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedSCH",
                                          "Scheme",
                                          choices=schemaslist)),
                    width=9),
                column(
                    hidden(actionButton("fixedSCHtxt",
                                        "Text",
                                        style = "margin-top: 25px;")),
                    width=2)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedMM",
                                          "Mastermind",
                                          choices=mmaslist)),
                    width=9),
                column(
                    hidden(actionButton("fixedMMtxt",
                                        "Text",
                                        style = "margin-top: 25px;")),
                    width=2)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedHM",
                                          "Henchmen",
                                          choices=henchaslist)),
                    width=9),
                column(
                    hidden(actionButton("fixedHMtxt",
                                        "Text",
                                        style = "margin-top: 25px;")),
                    width=2)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedVIL",
                                          "Villains",
                                          choices=vilaslist,
                                          multiple=T,
                                          options = list(maxItems=6))),
                    width=9),
                column(
                    hidden(actionButton("fixedVILtxt",
                                        "Text",
                                        style = "margin-top: 25px;")),
                    width=2)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedHER",
                                          "Heroes",
                                          choices=heroaslist,
                                          multiple=T,
                                          options = list(maxItems=8))),
                    width=9),
                column(
                    hidden(actionButton("fixedHERtxt",
                                        "Text",
                                        style = "margin-top: 25px;")),
                    width=2)),
            fluidRow(
                column(selectizeInput("dropset",
                                      "Sets excluded",
                                      choices=setaslist,
                                      multiple=T),
                       width=8),
                column(checkboxInput("epic",
                                     "Epic?"),
                       checkboxInput("solo",
                                     "Solo?",
                                     value=T),
                       width=4)),
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
            fluidRow(
                column(actionButton("go",
                                    "Start"),
                       width=3,
                       style = "margin-top: 25px;"),
                column(numericInput("gamecount",
                             "# runs",
                             100,
                             1,
                             1000,
                             1),
                       width=4)),
            fluidRow(
                column(uiOutput("minbutton"),
                       width=1),
                column(uiOutput("gameslider",
                                style = "margin-left: 10px;"),
                       width=9),
                column(uiOutput("plusbutton"),
                       width=1)
            ),
            selectizeInput("keywords",
                           "Keyword Info",
                           choices = keywords$id),
            width=5
        ),
        mainPanel(dataTableOutput("setups"),
                  br(),
                  fluidRow(
                      column(
                        hidden(actionButton("print","Copy setup")),
                        width=3
                        ),
                      column(
                        hidden(actionButton("printTS","Copy to TS")),
                        width=3
                      )),
                  textOutput("printsuccess"),
                  textOutput("printsuccessTS"),
                  br(),
                  hidden(actionButton("metricsgo","Get Metrics")),
                  tableOutput("metrics"),
                  width=7)
    )
)

server <- function(input, output, session) {

    #render a popup with card text
    textpopupgen <- function(txt,type="none") {
        if (length(type)==0) {
            type = "none"
        }
        if (type=="none") {
            text = filter(tooltext,
                          id%in%txt)
        }
        if (type!="none") {
            text = filter(tooltext,
                          id%in%txt,
                          type==type)
        }
        if (dim(text)[1]>0) {
            title = filter(setlist,id==text$set)$label
            text %<>% mutate(text = gsub("\n","<br>",text))
            showModal(modalDialog(title = title,
                                  HTML(paste(text$text,collapse="<br><br>")),
                                  easyClose = T,
                                  footer=HTML(
                                      paste0("<p align=\"left\">",
                                             "<a href=\"",
                                             "https://www.boardgamegeek.com/wiki/page/Legendary_Marvel_Complete_Card_Text\"",
                                             ">Text transcriptions adapted from boardgamegeek wiki</a></p>"))))
        }
    }
    
    ###triggers and reactives###
    
    #make preset forms visible or not
    observeEvent(input$presets, {
        toggle("fixedSCH")
        toggle("fixedMM")
        toggle("fixedHM")
        toggle("fixedVIL")
        toggle("fixedHER")
        toggle("fixedSCHtxt")
        toggle("fixedMMtxt")
        toggle("fixedHMtxt")
        toggle("fixedVILtxt")
        toggle("fixedHERtxt")
    })
    
    observeEvent(input$pastesetup,{
        setup = readClipboard()
        if (!is.null(setup)) {
            setup = strsplit(setup,split="\\t")[[1]]
            updateSelectizeInput(session,
                                 "fixedSCH",
                                 selected = setup[2])
            updateSelectizeInput(session,
                                 "fixedMM",
                                 selected = setup[3])
            updateSelectizeInput(session,
                                 "fixedVIL",
                                 selected = strsplit(setup[4],
                                                     split="|",
                                                     fixed=T)[[1]])
            updateSelectizeInput(session,
                                 "fixedHM",
                                 selected = strsplit(setup[5],
                                                     split="|",
                                                     fixed=T)[[1]])
            updateSelectizeInput(session,
                                 "fixedHER",
                                 selected = strsplit(setup[6],
                                                     split="|",
                                                     fixed=T)[[1]])
        }
    })
    
    #Generate a list of setups based on the set parameters
    gamelist <- eventReactive(input$go,{
        withProgress(message = "Processing",value = 0, {
        games=list()
        for (i in 1:input$gamecount) {
            games[[i]] = genFun(src,
                            playerc = input$playerc,
                            fixedSCH = input$fixedSCH,
                            fixedMM = input$fixedMM,
                            fixedHM = input$fixedHM,
                            fixedVIL = input$fixedVIL,
                            fixedHER = input$fixedHER,
                            epic = input$epic,
                            dropset=input$dropset,
                            solo=input$solo,
                            xtra=NULL)
            incProgress(1/input$gamecount,detail = paste("Setup",i))
        }
        games = setGames(games,
                         setreq = input$incset,
                         dropgames = input$incsetThreshold)
        })
        hide("metrics")
        return(games)
    })
    
    #Render the slidebar and buttons to jump between setups
    observeEvent(input$go,{
        output$minbutton <- renderUI({
            actionButton("gamemin",
                         "-",
                         style = "margin-top: 40px;")
        })
        output$gameslider <- renderUI({
            sliderInput("selectgame", 
                        label = "Selected setup:",
                        min = 1,
                        max = length(gamelist()),
                        value = 1,
                        step = 1)
        })
        output$plusbutton <- renderUI({
            actionButton("gameplus",
                         "+",
                         style = "margin-top: 40px;")
        })
    })
    
    #Export a specific setup requested by the slide bar (or the first by default)
    livesetup <- eventReactive(input$selectgame,{
        summ = setupSumm(gamelist()[[input$selectgame]],
                         input$selectgame)
        return(summ)
    })
    
    #Render the specific requested setup in a table
    #also show the export and print metrics buttons
    observeEvent(input$selectgame,{
        setupToShow = livesetup() %>%
            select(-Namespace)
        output$setups <- DT::renderDataTable(setupToShow,
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
        show("printTS")
        show("metricsgo")
    })
    
    #jump to the previous setup
    observeEvent(input$gamemin,{
        updateSliderInput(session,
                          "selectgame",
                          value = input$selectgame - 1)
    })
    
    #jump to the next setup
    observeEvent(input$gameplus,{
        updateSliderInput(session,
                          "selectgame",
                          value = input$selectgame + 1)
    })
    
    #render card text popup from the table
    observeEvent(input$setups_cell_clicked, {
        subj = livesetup()[input$setups_rows_selected,2]
        type = livesetup()$Namespace[input$setups_rows_selected]
        subj = gsub(" - epic",
                    "",
                    subj,
                    fixed=T)
        textpopupgen(subj,type)
    })
    
    #render card text popup from the presets lists
    observeEvent(input$fixedSCHtxt, {
        textpopupgen(input$fixedSCH,type="Scheme")
    })
    observeEvent(input$fixedMMtxt, {
        textpopupgen(input$fixedMM,type="Mastermind")
    })
    observeEvent(input$fixedHMtxt, {
        textpopupgen(input$fixedHM,type="Henchmen")
    })
    observeEvent(input$fixedVILtxt, {
        textpopupgen(input$fixedVIL[1],type="Villains")
    })
    observeEvent(input$fixedHERtxt, {
        textpopupgen(input$fixedHER[1],type="Heroes")
    })
    
    #render keyword text popup
    observeEvent(input$keywords,{
        text = filter(keywords,id==input$keywords)
        if (dim(text)[1]>0&
            text$id!="") {
            text %<>% mutate(text = gsub("\n","<br>",text))
            showModal(modalDialog(title = text$id,
                                  HTML(paste(text$text,collapse="<br>")),
                                  easyClose = T,
                                  footer=HTML(
                                      paste0("<p align=\"left\">",
                                             "<a href=\"",
                                             "https://marveldbg.wordpress.com/gameplay-mechanics\"",
                                             ">Keyword text adapted from marveldbg blog.</a></p>"))))
        }
    })
    
    #render the metrics for a setup
    #changes if setup changes
    observeEvent(input$metricsgo,{
        metrics = metricsLoop(gamelist())
        output$metrics = renderTable(metricsPrint(metrics[[input$selectgame]]),
                                     rownames = T,
                                     colnames = T,
                                     sanitize.text.function=identity)
        show("metrics")
    })
    
    #export to log in spreadsheet
    observeEvent(input$print,{
        setupPrint(gamelist()[[input$selectgame]])
        output$printsuccess = renderText({
            paste0("Setup ",isolate(input$selectgame)," copied succesfully!")
        })
    })
    
    #export in format fit for tabletop simulator mod
    observeEvent(input$printTS,{
        setupPrint(gamelist()[[input$selectgame]],ts=T)
        output$printsuccessTS = renderText({
            paste0("Setup ",isolate(input$selectgame)," copied succesfully in TS format!")
        })
    })
}

shinyApp(ui = ui, server = server)
