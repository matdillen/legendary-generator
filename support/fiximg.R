library(tidyverse)
library(jsonlite)
library(conflicted)
setwd("lua-backup")

autodeploy = T

file = list.files("currentmod",
                  pattern="*.json",
                  full.names = T)
conflict_prefer("validate","jsonlite")
conflict_prefer("filter","dplyr")
js = fromJSON(file[1],
              simplifyVector = F)

resu= list()
filenames = ""
backnames = ""
for (i in 1:length(js$ObjectStates)) {
  if (i!=72) {
    if (!is.null(js$ObjectStates[[i]]$ContainedObjects)) {
      deckname = js$ObjectStates[[i]]$Nickname
      if (deckname != "") {
        resu[[deckname]] = list()
        for (j in 1:length(js$ObjectStates[[i]]$ContainedObjects)) {
          cardname = js$ObjectStates[[i]]$ContainedObjects[[j]]$Nickname
          resu[[deckname]][[cardname]] = list()
          resu[[deckname]][[cardname]]$CustomDeck = js$ObjectStates[[i]]$ContainedObjects[[j]]$CustomDeck
          for (k in 1:length(js$ObjectStates[[i]]$ContainedObjects[[j]]$CustomDeck)) {
            filenames = c(filenames,js$ObjectStates[[i]]$ContainedObjects[[j]]$CustomDeck[[k]]$FaceURL)
            backnames = c(backnames,js$ObjectStates[[i]]$ContainedObjects[[j]]$CustomDeck[[k]]$BackURL)
          }
          if (!is.null(js$ObjectStates[[i]]$ContainedObjects[[j]]$ContainedObjects)) {
            for (k in 1:length(js$ObjectStates[[i]]$ContainedObjects[[j]]$ContainedObjects)) {
              scardname = js$ObjectStates[[i]]$ContainedObjects[[j]]$ContainedObjects[[k]]$Nickname
              resu[[deckname]][[cardname]][[scardname]] = list()
              resu[[deckname]][[cardname]][[scardname]]$CardID = js$ObjectStates[[i]]$ContainedObjects[[j]]$ContainedObjects[[k]]$CardID
            }  
          }
        }
      }
    }
  }
}
backnames = backnames[-1]
filenames = filenames[-1]
backnames = tibble(names=backnames)
backnames2 = count(backnames,names)
filenames = tibble(names=filenames)
filenames2 = count(filenames,names)
filenames2$files = gsub("[^a-zA-Z0-9]","",filenames2$names)
filenames2$jpg = paste0(filenames2$files,".jpg")
filenames2$png = paste0(filenames2$files,".png")

z=list.files("C:/Users/mdill/Documents/My Games/Tabletop Simulator/Mods/Images")
filter(filenames2,!jpg%in%z,!png%in%z)

jpginfo = filenames2 %>%
  filter(jpg%in%z) %>%
  pull(jpg) %>%
  paste0("C:/Users/mdill/Documents/My Games/Tabletop Simulator/Mods/Images/",.) %>%
  file.info()

jpginfo$mb = jpginfo$size/1000000

pnginfo = filenames2 %>%
  filter(png%in%z) %>%
  pull(png) %>%
  paste0("C:/Users/mdill/Documents/My Games/Tabletop Simulator/Mods/Images/",.) %>%
  file.info()

pnginfo$mb = pnginfo$size/1000000
