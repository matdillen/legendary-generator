pkgLoad <- function() {
    
    packages <- c("DT",
                  "plyr",
                   "tidyverse",
                   "magrittr",
                   "shiny",
                   "shinyjs",
                   "shinythemes",
                   "shinyBS")
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
library(shinyBS)

source("helpers.R")

options(dplyr.summarise.inform=F) #block obscure dplyr warning

#data import
heroes=read_csv2('data/heroes.csv',show_col_types = F)
schemes=read_csv2('data/schemes.csv',show_col_types = F)
villains=read_csv2('data/villains.csv',show_col_types = F)
henchmen=read_csv2('data/henchmen.csv',show_col_types = F)
masterminds=read_csv2('data/masterminds.csv',show_col_types = F)

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
setlist = read_csv("data/sets.csv",show_col_types = F)
setlist[1,] = list(""," ")
setaslist = as.list(t(setlist$id))
names(setaslist) = setlist$label

keywords = read_tsv("data/keywords2.txt",show_col_types = F)
keywords[is.na(keywords)] = ""

tooltext = read_tsv("data/tooltext.txt",show_col_types = F)

imgsize = read_tsv("data/sizeinfo.txt",show_col_types = F)

ui <- fluidPage(
    #tags$head(tags$style(".modal-dialog { width: auto;}")),
    #theme = shinytheme("united"),
    useShinyjs(),
    #useShinyalert(),
    # bsTooltip("playerc",
    #            paste0("Set the number of players here, from 2-5.",
    #                   " If playing solo, playing with 2 hands is recommended.",
    #                   " Solo play with one hand is not supported.")),
    # bsTooltip("presets",
    #            paste0("Press to enable setting specific cards that are",
    #                   "required to be part of the setup. It\\'s also easy",
    #                   "to visualize card text and images with the",
    #                   "preset fields this way.")),
    # bsTooltip("pastesetup",
    #           paste0("Press to paste a setup previously exported from this app.",
    #                  "This is the simple export, not the Tabletop Simulator one.")),
    # bsTooltip("fixedSCH",
    #           "Pick a scheme.",
    #           placement="right"),
    # bsTooltip("fixedSCHtxt",
    #           "See the selected scheme\\'s text."),
    # bsTooltip("fixedSCHimg",
    #           "See the selected scheme as an image."),
    # bsTooltip("fixedMM",
    #           "Pick a mastermind.",
    #           placement="right"),
    # bsTooltip("fixedMMtxt",
    #           "See the selected mastermind\\'s text, including the tactics."),
    # bsTooltip("fixedMMimg",
    #           "See the selected mastermind\\'s card images, including tactics and epic or transform backsides."),
    # bsTooltip("fixedHM",
    #           "Pick a henchmen group.",
    #           placement="right"),
    # bsTooltip("fixedHMtxt",
    #           "See the selected henchmen card text."),
    # bsTooltip("fixedHMimg",
    #           "See the selected henchmen card image."),
    # bsTooltip("fixedVIL",
    #           "Pick the villain groups.",
    #           placement="right"),
    # bsTooltip("fixedVILtxt",
    #           paste0("See the selected villain group\\'s text.",
    #           " If multiple are selected, only text for the first group will be shown.")),
    # bsTooltip("fixedVILimg",
    #           paste0("See the images for all villain cards from the selected group.",
    #                  " If multiple groups are selected, only images for the first group will be shown.")),
    # bsTooltip("fixedHER",
    #           "Pick the heroes.",
    #           placement="right"),
    # bsTooltip("fixedHERtxt",
    #           paste0("See the text of all cards of the selected hero.",
    #                  " If multiple heroes are selected, only text for the first one will be shown.")),
    # bsTooltip("fixedHERimg",
    #           paste0("See the images of all cards of the selected hero.",
    #                  " If multiple heroes are selected, only images for the first one will be shown.")),
    # bsTooltip("fixedXtra",
    #           paste0("Place the extra required cards here. Only use when pasting a previous setup",
    #                  " or if you understand the syntax!")),
    # bsTooltip("dropset",
    #           "Select the sets that are to be fully excluded from the random generator.",
    #           placement="right"),
    # bsTooltip("onlyset",
    #           "Select the only sets that are to be included by the random generator.",
    #           placement="right"),
    # bsTooltip("epic",
    #           "Tick this box to potentially select epic masterminds. If you do, there\\'s a 50% chance."),
    # bsTooltip("solo",
    #           paste0("Tick this box if you are playing solo (with multiple hands).",
    #                  " This excludes some schemes that do not work for solo play.")),
    # bsTooltip("incset",
    #           paste0("Select the sets from which you want cards to be definitely included.",
    #                  " In the next box you can indicate how many cards should be included as a minimum.",
    #                  " Do note that this is a filter post generation and too strict criteria will ",
    #                  "cause few or even 0 random setups to be returned!"),
    #           placement="top"),
    # bsTooltip("incsetThreshold",
    #           paste0("How many cards should be present in the random setup from the selected sets.",
    #                  " Minimally 1, maximum of 5. Ignored if no sets are selected.")),
    # bsTooltip("go",
    #           "Generate a set of random setups according to the specified criteria (if any)."),
    # bsTooltip("gamecount",
    #           "How many different setups should be generated?"),
    # bsTooltip("gameslider",
    #           "Select your setup here."),
    # bsTooltip("keywords",
    #           "Render a popup with rules text for the selected keyword.",
    #           placement="right"),
    # bsTooltip("print",
    #           "Copy the selected setup to the clipboard. Can be easily pasted into a spreadsheet."),
    # bsTooltip("printTS",
    #           paste0("Copy the selected setup to the clipboard, in a format that a compatible mod",
    #                  " in Tabletop Simulator may understand. See help for more info.")),
    # bsTooltip("metricsgo",
    #           "Render metrics for all generated setups. These metrics may give some indication of setup balance."),
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
                    hidden(actionButton("pastesetup",
                                        "Paste")),
                    br(),
                    hidden(actionButton("clearpresets",
                                        "Clear")),
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
                column(
                    hidden(textInput("fixedXtra",
                                          "Extra")),
                    width=8,
                    style="padding:4px;")),
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
                column(selectizeInput("onlyset",
                                      "Sets included",
                                      choices=setaslist,
                                      multiple=T),
                       width=9)),
            fluidRow(
                column(selectizeInput("incset",
                               "Sets preferred",
                               choices=setaslist,
                               multiple=T),
                       width=9),
                column(numericInput("incsetThreshold",
                             "Min:",
                             1,1,5,1),
                       width=3)),
            fluidRow(
                column(actionButton("go",
                                    "Start",
                                    style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                       width=3,
                       style = "margin-top: 25px;"),
                column(numericInput("gamecount",
                             "# runs",
                             10,
                             2,
                             1000,
                             1),
                       width=5)),
            fluidRow(
                column(uiOutput("minbutton"),
                       width=1),
                column(uiOutput("gameslider",
                                style = "margin-left: 10px;"),
                       width=9),
                column(uiOutput("plusbutton"),
                       width=1)
            ),
            fluidRow(
                column(
                    selectizeInput("keywords",
                           "Keyword Info",
                           choices = keywords$id),
            width=10)),
            fluidRow(
                column(
                    HTML(paste0("<b>For more info, see the <a href=\"https://github.com/matdillen",
                                "/legendary-generator/blob/master/README.md\">readme</a>.</b>")),
                    width=12
                )
            )
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
        toggle("pastesetup")
        toggle("clearpresets")
        toggle("fixedXtra")
    })
    
    #show images from the preset fields
    observeEvent(input$fixedSCHimg, {
        imgPopupGen(input$fixedSCH,
                    cardtype="Scheme",
                    src=src,
                    imgsize=imgsize)
    })
    
    observeEvent(input$fixedMMimg, {
        imgPopupGen(input$fixedMM,
                    cardtype="Mastermind",
                    src=src,
                    imgsize=imgsize)
    })
    
    observeEvent(input$fixedHMimg, {
        imgPopupGen(input$fixedHM,
                    cardtype="Henchmen",
                    src=src,
                    imgsize=imgsize)
    })
    observeEvent(input$fixedVILimg, {
        if (length(input$fixedVIL)>0) {
            imgPopupGen(input$fixedVIL[1],
                        cardtype="Villains",
                        src=src,
                        imgsize=imgsize)
        }
    })
    observeEvent(input$fixedHERimg, {
        if (length(input$fixedHER)>0) {
            imgPopupGen(input$fixedHER[1],
                        cardtype="Heroes",
                        src=src,
                        imgsize=imgsize)
        }
    })
    
    #paste a previously generated setup into the preset fields
    observeEvent(input$pastesetup,{
        setup = readClipboard()
        if (!is.null(setup)) {
            setup = strsplit(setup,split="\\t")[[1]]
            setup = gsub("\"","",setup,fixed=T)
            updateSelectizeInput(session,
                                 "fixedSCH",
                                 selected = setup[1])
            updateSelectizeInput(session,
                                 "fixedMM",
                                 selected = setup[2])
            updateSelectizeInput(session,
                                 "fixedVIL",
                                 selected = strsplit(setup[3],
                                                     split="|",
                                                     fixed=T)[[1]])
            updateSelectizeInput(session,
                                 "fixedHM",
                                 selected = strsplit(setup[4],
                                                     split="|",
                                                     fixed=T)[[1]])
            updateSelectizeInput(session,
                                 "fixedHER",
                                 selected = strsplit(setup[5],
                                                     split="|",
                                                     fixed=T)[[1]])
            if (length(setup) == 6) {
                updateTextInput(session,
                                "fixedXtra",
                                value=setup[6])
            }
        }
    })
    
    observeEvent(input$clearpresets,{
        updateSelectizeInput(session,
                             "fixedSCH",
                             selected = "")
        updateSelectizeInput(session,
                             "fixedMM",
                             selected = "")
        updateSelectizeInput(session,
                             "fixedVIL",
                             selected = "")
        updateSelectizeInput(session,
                             "fixedHM",
                             selected = "")
        updateSelectizeInput(session,
                             "fixedHER",
                             selected = "")
        updateTextInput(session,
                        "fixedXtra",
                        value="")
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
                            fixedXtra = input$fixedXtra,
                            epic = input$epic,
                            dropset=input$dropset,
                            onlyset=input$onlyset,
                            solo=input$solo,
                            xtra=NULL)
            incProgress(1/input$gamecount,detail = paste("Setup",i))
        }
        games = setGames(games,
                         setreq = input$incset,
                         dropgames = input$incsetThreshold)
        })
        hide("metrics")
        updateSliderInput(session,"selectgame",value=1)
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
                        value = 2,
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
                                                 mode="single",
                                                 target="cell"),
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
        if (length(input$setups_cells_selected)!=0) {
            if (input$setups_cells_selected[2]==0) {
                subj = livesetup()[input$setups_cells_selected[1],2]
                type = livesetup()$Namespace[input$setups_cells_selected[1]]
                if (length(type)==0) {
                    type = "none"
                }
                subj = gsub(" - epic",
                            "",
                            subj,
                            fixed=T)
                textpopupgen(subj,
                             type,
                             tooltext=tooltext,
                             setlist=setlist)
            }
            if (input$setups_cells_selected[2]==1) {
                subj = livesetup()[input$setups_cells_selected[1],2]
                type = livesetup()$Namespace[input$setups_cells_selected[1]]
                if (length(type)==0) {
                    type = "none"
                }
                subj = gsub(" - epic",
                            "",
                            subj,
                            fixed=T)
                imgPopupGen(subj,
                            cardtype=type,
                            src=src,
                            imgsize=imgsize)
            }
        }
    },ignoreInit = T)
    
    #render card text popup from the presets lists
    observeEvent(input$fixedSCHtxt, {
        textpopupgen(input$fixedSCH,
                     cardtype="Scheme",
                     tooltext=tooltext,
                     setlist=setlist)
    })
    observeEvent(input$fixedMMtxt, {
        textpopupgen(input$fixedMM,
                     cardtype="Mastermind",
                     tooltext=tooltext,
                     setlist=setlist)
    })
    observeEvent(input$fixedHMtxt, {
        textpopupgen(input$fixedHM,
                     cardtype="Henchmen",
                     tooltext=tooltext,
                     setlist=setlist)
    })
    observeEvent(input$fixedVILtxt, {
        textpopupgen(input$fixedVIL[1],
                     cardtype="Villains",
                     tooltext=tooltext,
                     setlist=setlist)
    })
    observeEvent(input$fixedHERtxt, {
        textpopupgen(input$fixedHER[1],
                     cardtype="Heroes",
                     tooltext=tooltext,
                     setlist=setlist)
    })
    
    #render keyword text popup
    observeEvent(input$keywords,{
        text = filter(keywords,id==input$keywords)
        if (dim(text)[1]>0) {
          if (text$id!="") {
            text %<>% mutate(text = gsub("\n","<br>",text))
            showModal(modalDialog(title = text$id,
                                  HTML(paste(text$text,collapse="<br>")),
                                  easyClose = T,
                                  footer=HTML(
                                      paste0("<p align=\"left\">",
                                             "<a href=\"",
                                             "https://marveldbg.wordpress.com/gameplay-mechanics\"",
                                             ">Keyword text adapted from marveldbg blog.</a></p>"))))
        }}
    },ignoreInit = T)
    
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
