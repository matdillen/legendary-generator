setwd("D:/Mathias/legendary")
library(tidyverse)
library(jsonlite)

#read the json file for the mod/save you want to edit
a = fromJSON("lua/TS_Save_72.json",
             simplifyVector = F)

heroes=read_tsv('kw bc/heroes-keywords.txt')
schemes=read_tsv('kw bc/schemes-keywords.txt')
villains=read_tsv('kw bc/villains-keywords.txt')
henchmen=read_tsv('kw bc/henchmen-keywords.txt')
masterminds=read_tsv('kw bc/masterminds-keywords.txt')

ttstext = read_tsv("legendary-generator/support/keywords-tts.txt",col_names = F)
ttstext$caps = toupper(ttstext$X1)

addDescription <- function(data) {
  data$ttsdescription = ""
  for (i in 1:dim(data)[1]) {
    if (is.na(data$keywords[i])) {
      next
    }
    words = toupper(strsplit(data$keywords[i],split="\\|")[[1]])
    text = ttstext$X2[ttstext$caps%in%words]
    text = paste(words,text,sep=": ")
    data$ttsdescription[i] = paste(text,collapse="\n")
  }
  return(data)
}

masterminds %<>% addDescription()
heroes %<>% addDescription()
villains %<>% addDescription()
schemes %<>% addDescription()
henchmen %<>% addDescription()

mmid = 14
henchid = 13
heroid = 11
vilid = 17
schid = 96 #it changed!!!

#masterminds

for (i in 1:length(a$ObjectStates[[mmid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[mmid]]$ContainedObjects[[i]]
  
  #the name of the mm
  mmname = src$Nickname
  
  #data associated with the mm
  data = filter(masterminds,Name==mmname|MM==mmname)
  
  #extra filter to exclude tactic names that correspond to mm names (e.g. adapters)
  #backsides have no separate description
  data %<>%
    filter(is.na(MM)|MM==data$Name[1]) %>%
    filter(is.na(Epic),
           is.na(T),
           !is.na(file))
  
  #adapters have no front card
  #easiest to match based on name
  if (src$Nickname%in%c("Hydra High Council",
                        "Hydra Super-Adaptoid")) {
    for (j in 1:4) {
      src$ContainedObjects[[j]]$Description = data$ttsdescription[data$Name==src$ContainedObjects[[j]]$Nickname]
    }
  } else {
    #front card is always the last in the list
    src$ContainedObjects[[5]]$Description = data$ttsdescription[1]
    for (l in 2:dim(data)[1]) {
      #set a tag for VP
      src$ContainedObjects[[l-1]]$Description = data$ttsdescription[l]
    }
  }
  a$ObjectStates[[mmid]]$ContainedObjects[[i]] = src
}

#heroes

for (i in 1:length(a$ObjectStates[[heroid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[heroid]]$ContainedObjects[[i]]
  
  #the name of the mm
  heroname = src$Nickname
  
  #data associated with the mm
  data = heroes %>%
    filter(uni==heroname) %>%
    filter(is.na(Split)|!duplicated(Split))
  
  if (dim(data)[1]==0) {
    next
  }
  
  cardnr = 1
  for (j in 1:dim(data)[1]) {
    for (k in 1:data$Ct[j]) {
      src$ContainedObjects[[cardnr]]$Description = data$ttsdescription[j]
      cardnr = cardnr + 1
    }
  }
  a$ObjectStates[[heroid]]$ContainedObjects[[i]] = src
}

#villains

for (i in 1:length(a$ObjectStates[[vilid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[vilid]]$ContainedObjects[[i]]
  
  #the name of the mm
  vilname = src$Nickname
  
  #data associated with the mm
  data = filter(villains,Group==vilname)
  
  if (dim(data)[1]==0) {
    next
  }
  
  cardnr = 1
  for (j in 1:dim(data)[1]) {
    for (k in 1:data$Ct[j]) {
      src$ContainedObjects[[cardnr]]$Description = data$ttsdescription[j]
      cardnr = cardnr + 1
    }
  }
  a$ObjectStates[[vilid]]$ContainedObjects[[i]] = src
}

#henchmen

for (i in 1:length(a$ObjectStates[[henchid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[henchid]]$ContainedObjects[[i]]
  
  #the name of the mm
  henchname = src$Nickname
  
  #data associated with the mm
  data = filter(henchmen,Name==henchname)
  
  if (dim(data)[1]==0) {
    next
  }
  
  cardnr = 1
  for (j in 1:dim(data)[1]) {
    for (k in 1:data$Ct[j]) {
      src$ContainedObjects[[cardnr]]$Description = data$ttsdescription[j]
      cardnr = cardnr + 1
    }
  }
  a$ObjectStates[[henchid]]$ContainedObjects[[i]] = src
}

#schemes

for (i in 1:length(a$ObjectStates[[schid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[schid]]$ContainedObjects[[i]]
  
  #the name of the mm
  schemename = src$Nickname
  
  #data associated with the mm
  data = filter(schemes,Name==schemename)
  
  if (dim(data)[1]==0) {
    next
  }
  src$Description = data$ttsdescription[1]
  a$ObjectStates[[schid]]$ContainedObjects[[i]] = src
}

write(toJSON(a,
             digits=NA,
             pretty=T,
             flatten=T,
             auto_unbox=T),
      "keywordsAdded.json")
