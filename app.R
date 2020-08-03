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
schemtext = read_tsv('data/schemtext.csv')
schemtext %<>% rename(id = schemtext)
viltext = read_tsv('data/viltext.csv')
viltext %<>% rename(id = viltext)
henchtext = read_tsv('data/henchtext.csv')
henchtext %<>% rename(id = henchtext)
#duplicate ids are possible in theory
#in practice one occurs: maximum carnage
#now captured by difference in casing, but needs a more reliable fix
#probably work with card type namespace somehow, but this requires quite some changes
tooltext = rbind(select(heroestext,text,id),mmtext,viltext,schemtext,henchtext)

#find a way to render color symbols
#and later team icons and fight/money icons
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26283_0.png","<img src=\"red.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26284_0.png","<img src=\"yellow.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26285_0.png","<img src=\"blue.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26286_0.png","<img src=\"green.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26287_0.png","<img src=\"silver.png\">",tooltext$text)
tooltext$text = gsub(" Attack"," <img src=\"Attack.jpg\" width=\"16\">",tooltext$text)
tooltext$text = gsub(" Recruit"," <img src=\"Recruit.jpg\" width=\"16\">",tooltext$text)

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

keywords = read_tsv("data/keywords.txt")
keywords = rbind(keywords,tibble(name="",text="",id=""))
keywords %<>% arrange(id)
keywords$text = gsub("[Attack]","<img src=\"Attack.jpg\" width=\"16\">",keywords$text,fixed=T)
keywords$text = gsub("[+Attack]","+<img src=\"Attack.jpg\" width=\"16\">",keywords$text,fixed=T)
keywords$text = gsub("[Recruit]","<img src=\"Recruit.jpg\" width=\"16\">",keywords$text,fixed=T)
keywords$text = gsub("[+Recruit]","+<img src=\"Recruit.jpg\" width=\"16\">",keywords$text,fixed=T)
keywords$text = gsub("Attack ","<img src=\"Attack.jpg\" width=\"16\"> ",keywords$text)
keywords$text = gsub("Recruit ","<img src=\"Recruit.jpg\" width=\"16\"> ",keywords$text)
keywords$text = gsub("[Ranged]","<img src=\"blue.png\">",keywords$text,fixed=T)
keywords$text = gsub("[Strength]","<img src=\"green.png\">",keywords$text,fixed=T)
keywords$text = gsub("[Tech]","<img src=\"silver.png\">",keywords$text,fixed=T)
keywords$text = gsub("[Covert]","<img src=\"red.png\">",keywords$text,fixed=T)
keywords$text = gsub("[Instinct]","<img src=\"yellow.png\">",keywords$text,fixed=T)

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
            uiOutput("gameslider"),
            selectizeInput("keywords",
                           "Keyword Info",
                           choices = keywords$id),
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
        for (i in 1:input$gamecount) {
            games[[i]] = genFun(src,
                            playerc = input$playerc,
                            fixedSCH = input$fixedSCH,
                            fixedMM = input$fixedMM,
                            fixedHM = input$fixedHM,
                            fixedVIL = input$fixedVIL,
                            fixedHER = input$fixedHER,
                            epic = input$epic,
                            dropset=input$dropset)
            incProgress(1/input$gamecount,detail = paste("Setup",i))
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
            showModal(modalDialog(title = NULL,
                                  HTML(paste(text$text,collapse="<br><br>")),
                                  easyClose = T,
                                  footer=HTML("<p align=\"left\"><a href=\"https://www.boardgamegeek.com/wiki/page/Legendary_Marvel_Complete_Card_Text\">Text transcriptions adapted from boardgamegeek wiki</a></p>")))
        }
    })
    observeEvent(input$keywords,{
        text = filter(keywords,id==input$keywords)
        if (dim(text)[1]>0&
            text$id!="") {
            text %<>% mutate(text = gsub("\n","<br>",text))
            showModal(modalDialog(title = text$id,
                                  HTML(paste(text$text,collapse="<br>")),
                                  easyClose = T,
                                  footer=HTML("<p align=\"left\"><a href=\"https://marveldbg.wordpress.com/gameplay-mechanics\">Keyword text adapted from marveldbg blog.</a></p>")))
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
