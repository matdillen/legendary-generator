pkgLoad <- function() {
    
    packages <- c("DT",
                  "plyr",
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
heroes=read_csv2('data/heroes.csv')
schemes=read_csv2('data/schemes.csv')
villains=read_csv2('data/villains.csv')
henchmen=read_csv2('data/henchmen.csv')
masterminds=read_csv2('data/masterminds.csv')

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
setlist[1,] = list(""," ")
setaslist = as.list(t(setlist$id))
names(setaslist) = setlist$label

keywords = read_tsv("data/keywords2.txt")
keywords[is.na(keywords)] = ""

tooltext = read_tsv("data/tooltext.txt")

imgsize = read_tsv("data/sizeinfo.txt", col_names = F)

ui <- fluidPage(
    #tags$head(tags$style(".modal-dialog { width: auto;}")),
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
                    width=8,
                    style="padding:4px;"),
                column(
                    hidden(actionButton("fixedSCHtxt",
                                        "txt",
                                        style = "margin-top: 29px;")),
                    width=1,
                    style="padding:0px;"),
                column(
                    hidden(actionButton("fixedSCHimg",
                                        "img",
                                        style = "margin-top: 29px;")),
                    width=1)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedMM",
                                          "Mastermind",
                                          choices=mmaslist)),
                    width=8,
                    style="padding:4px;"),
                column(
                    hidden(actionButton("fixedMMtxt",
                                        "txt",
                                        style = "margin-top: 29px;")),
                    width=1,
                    style="padding:0px;"),
                column(
                    hidden(actionButton("fixedMMimg",
                                        "img",
                                        style = "margin-top: 29px;")),
                    width=1)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedHM",
                                          "Henchmen",
                                          choices=henchaslist)),
                    width=8,
                    style="padding:4px;"),
                column(
                    hidden(actionButton("fixedHMtxt",
                                        "txt",
                                        style = "margin-top: 29px;")),
                    width=1,
                    style="padding:0px;"),
                column(
                    hidden(actionButton("fixedHMimg",
                                        "img",
                                        style = "margin-top: 29px;")),
                    width=1)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedVIL",
                                          "Villains",
                                          choices=vilaslist,
                                          multiple=T,
                                          options = list(maxItems=6))),
                    width=8,
                    style="padding:4px;"),
                column(
                    hidden(actionButton("fixedVILtxt",
                                        "txt",
                                        style = "margin-top: 29px;")),
                    width=1,
                    style="padding:0px;"),
                column(
                    hidden(actionButton("fixedVILimg",
                                        "img",
                                        style = "margin-top: 29px;")),
                    width=1)),
            fluidRow(
                column(
                    hidden(selectizeInput("fixedHER",
                                          "Heroes",
                                          choices=heroaslist,
                                          multiple=T,
                                          options = list(maxItems=8))),
                    width=8,
                    style="padding:4px;"),
                column(
                    hidden(actionButton("fixedHERtxt",
                                        "txt",
                                        style = "margin-top: 29px;")),
                    width=1,
                    style="padding:0px;"),
                column(
                    hidden(actionButton("fixedHERimg",
                                        "img",
                                        style = "margin-top: 29px;")),
                    width=1)),
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
            actionButton("imgen","Img Test"),
            htmlOutput("cardimg"),
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
    textpopupgen <- function(txt,cardtype="none") {
        if (cardtype=="none") {
            text = filter(tooltext,
                          id%in%txt)
        }
        if (cardtype!="none") {
            text = filter(tooltext,
                          id%in%txt,
                          type%in%cardtype)
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
        toggle("fixedSCHimg")
        toggle("fixedMMimg")
        toggle("fixedHMimg")
        toggle("fixedVILimg")
        toggle("fixedHERimg")
    })
    
    imgPopupGen <- function(id,cardtype) {
        if (cardtype == "henchmen") {
            vals = filter(src$henchmen,
                          Name==id)
        }
        if (cardtype == "hero") {
            vals = filter(src$heroes,
                          uni==id,
                          !duplicated(Split)|is.na(Split))
        }
        if (cardtype == "mastermind") {
            vals = filter(src$masterminds,
                          Name==id|MM==id)
        }
        if (cardtype == "villain") {
            vals = filter(src$villains,
                          Group==id)
        }
        if (cardtype == "scheme") {
            vals = filter(src$schemes,
                          Name==id)
        }
        n = dim(vals)[1]
        if (n>0) {
            vals$file = gsub(",",".",vals$file,fixed=T)
            imgcode = "<head><style>"
            vals$sz1 = 0
            vals$sz2 = 0
            for (i in 1:n) {
                loc = strsplit(vals$loc[i],split=" ")[[1]]
                if (length(loc)==1) {
                    bg = 100
                }
                if (length(loc)==2) {
                    vals$sz1[i] = (as.numeric(loc[1])-1)*11.15
                    vals$sz2[i] = (as.numeric(loc[2])-1)*16.75
                    bg = 1000
                }
                if (!is.na(vals$file[i])) {
                    line = paste0("#home",
                                  i,
                                  " {width: 106%; height: 106%; background: url(img/",
                                  vals$file[i],
                                  ") ",
                                  vals$sz1[i],
                                  "% ",
                                  vals$sz2[i],
                                  "%; background-size:",
                                  bg,
                                  "%;}")
                    imgcode = paste0(imgcode,
                                     line)
                }
            }
            imgcode = paste0(imgcode,
                             "</style></head><body>")
            for (i in 1:n) {
                if (!is.na(vals$file[i])) {
                    imgcode = paste0(imgcode,
                                     "<div style=\"width:50%;float:left;\"><img id=\"home",
                                     i,
                                     "\" src=\"empty.png\"></div>")
                }
            }
            imgcode = paste0(imgcode,
                             "</body>")
            showModal(modalDialog(title=NULL,
                                  HTML(imgcode),
                                  easyClose = T,
                                  footer=NULL))
        }
    }
    
    observeEvent(input$fixedSCHimg, {
        imgPopupGen(input$fixedSCH,cardtype="scheme")
    })
    
    observeEvent(input$fixedMMimg, {
        imgPopupGen(input$fixedMM,cardtype="mastermind")
    })
    
    observeEvent(input$fixedHMimg, {
        imgPopupGen(input$fixedHM,cardtype="henchmen")
    })
    observeEvent(input$fixedVILimg, {
        imgPopupGen(input$fixedVIL,cardtype="villain")
    })
    
    observeEvent(input$fixedHERimg, {
        imgPopupGen(input$fixedHER,cardtype="hero")
    })
    
    observeEvent(input$imgen, {
        showModal(modalDialog(title="test",
                              HTML(paste0("<head><style>",
                                          "#home {width: 106%; height: 106%; background: url(img/emma.png) 0 0; background-size:100%;}",
                                          "#home2 {width: 106%; height: 106%; background: url(img/dp.jpg) 22.30% 16.7%; background-size:1000%;}",
                                          "#home3 {width: 106%; height: 106%; background: url(img/hulk.jpg) 22.30% 16.7%; background-size:1000%;}",
                                          "#home4 {width: 106%; height: 106%; background: url(img/champions.jpg) 22.30% 16.7%; background-size:1000%;}",
                                          "</style></head><body>",
                                          "<div style=\"width:50%;float:left;\"><img id=\"home\" src=\"empty.png\"></div>",
                                          "<div style=\"width:50%;float:left;\"><img id=\"home2\" src=\"empty.png\"></div>",
                                          "<div style=\"width:50%;float:left;\"><img id=\"home3\" src=\"empty.png\"></div>",
                                          "<div style=\"width:50%;float:left;\"><img id=\"home4\" src=\"empty.png\"></div>",
                                          "</body>")),
                              easyClose=T,
                              size="m",
                              footer=NULL))
        # output$cardimg <- renderUI({
        #     HTML(paste0("<head><style>",
        #                      "#home {width: 106%; height: 106%; background: url(img/dp.jpg) 11.15% 16.7%;}",
        #                      "</style></head><body>",
        #                      "<img id=\"home\" src=\"empty.png\">",
        #                      "</body>"))
        #     })
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
        if (length(type)==0) {
            type = "none"
        }
        subj = gsub(" - epic",
                    "",
                    subj,
                    fixed=T)
        textpopupgen(subj,type)
    })
    
    #render card text popup from the presets lists
    observeEvent(input$fixedSCHtxt, {
        textpopupgen(input$fixedSCH,cardtype="Scheme")
    })
    observeEvent(input$fixedMMtxt, {
        textpopupgen(input$fixedMM,cardtype="Mastermind")
    })
    observeEvent(input$fixedHMtxt, {
        textpopupgen(input$fixedHM,cardtype="Henchmen")
    })
    observeEvent(input$fixedVILtxt, {
        textpopupgen(input$fixedVIL[1],cardtype="Villains")
    })
    observeEvent(input$fixedHERtxt, {
        textpopupgen(input$fixedHER[1],cardtype="Heroes")
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
