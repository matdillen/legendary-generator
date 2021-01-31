setwd("D:/Mathias/legendary")
library(tidyverse)
library(jsonlite)

#read the json file for the mod/save you want to edit
a = fromJSON("lua/2269377314.json",
                simplifyVector = F)

#source info on the cards, to be added as tags
heroes=read_csv2('legendary-generator/data/heroes.csv')
masterminds=read_csv2('legendary-generator/data/masterminds.csv')

#set file to add full set tags
#set names/codes can be idiosyncratic, so not play well with other code
sets = read_csv("legendary-generator/data/sets.csv")

#unique hero identifier
heroes$uni = paste0(heroes$Hero," (",heroes$Set,")")

#compile a hero cost tag
heroes$cost = paste0("cost",heroes$C)

#collapse to list of individual heroes
herolist=distinct(heroes,uni,Set)

#Generate a list of card nicknames in the json
ttsnames = a$ObjectStates[[6]]$ContainedObjects[[1]]$Nickname
for (i in 2:224) {
  ttsnames = c(ttsnames,a$ObjectStates[[6]]$ContainedObjects[[i]]$Nickname)
}

#fix incorrect nickname for base Cap Am
a$ObjectStates[[6]]$ContainedObjects[[136]]$Nickname = "Captain America (B)"
ttsnames2$name[136] = "Captain America (B)"

#add an id to indicate the location of a certain hero within the json
ttsnames2 = tibble(name=ttsnames,id=seq(1,224))

#Extract info on image files
#DeckIDs have the location within the image as their last two digits
#starting from 00 and counting row per row
ttsnames2$FaceURL = NA
ttsnames2$BackURL = NA
ttsnames2$DeckIDs = NA
for (i in 1:dim(herolist)[1]) {
  j = filter(ttsnames2,
             name==herolist$uni[i])$id
  herodata = filter(heroes,uni==herolist$uni[i])
  data = a$ObjectStates[[6]]$ContainedObjects[[j]]
  ttsnames2$DeckIDs[j] = paste(arrange(count(tibble(DeckIDs=data$DeckIDs),DeckIDs),n)$DeckIDs,collapse="|")
  for (k in 1:length(data$CustomDeck)) {
    if (k==1) {
      ttsnames2$FaceURL[j] = data$CustomDeck[[k]]$FaceURL
      ttsnames2$BackURL[j] = data$CustomDeck[[k]]$BackURL
    }
    if (k!=1) {
      ttsnames2$FaceURL[j] = paste(ttsnames2$FaceURL[j],
                                   data$CustomDeck[[k]]$FaceURL,
                                   sep="|")
      ttsnames2$BackURL[j] = paste(ttsnames2$BackURL[j],
                                   data$CustomDeck[[k]]$BackURL,
                                   sep="|")
    }
  }
}

#Remove complicating split and transforming heroes
#split info would need to be added to the same card
#transformed heroes are in another card stack
heroes2 = filter(heroes,!duplicated(Split)|is.na(Split))
ttsnames3 = left_join(ttsnames2,select(heroes2,uni,file,loc),by=c("name"="uni"))

#function to convert the ids used for the shiny app to the ids used in TTS
locConv <- function(locids) {
  for (i in 1:length(locids)) {
    if (is.na(locids[i])) {
      #missing info
      next
    }
    else if (locids[i]==1) {
      #single img for single card
      locids[i] = 0
    } else if (!grepl(" ",locids[i],fixed=T)) {
      #combination of four cards
      locids[i] = recode(locids[i],
                         "NW"=0,
                         "NE"=1,
                         "SW"=2,
                         "SE"=3)
    } else {
      #10*7 type of image
      parts = as.numeric(strsplit(locids[i],split=" ")[[1]])
      locids[i] = parts[1] + 10*(parts[2]-1) - 1
    }
  }
  return(locids)
}

ttsnames3$locid = locConv(ttsnames3$loc)

#check where the same image was used for the app as in TTS
#this is based on the exact same within-img locations being present in both
#in the future, filenames need to be harmonized
#or an interface table made (preferred)
herolist$fullmatch = NA
for (i in 1:dim(herolist)[1]) {
  sub = ttsnames3 %>%
    filter(name==herolist$uni[i]) %>%
    arrange(locid)
  deckids = strsplit(sub$DeckIDs,
                     split="|",
                     fixed=T)[[1]]
  deckids = sort(as.numeric(substr(deckids,
                                   nchar(deckids)-1,
                                   nchar(deckids))))
  if (deckids == sub$locid) {
    herolist$fullmatch[i] = 1
  }
}

#if there seems to be a match between data from the app and data in TTS
#(based on image location)
#then add tags for hero cost and team to the individual cards
ttsnames3$imgid = paste0(ttsnames3$file,ttsnames3$loc)
heroes2$imgid = paste0(heroes2$file,heroes2$loc)
for (i in 1:dim(herolist)[1]) {
  if (!is.na(herolist$fullmatch)) {
    ttsinfo = filter(ttsnames3,name == herolist$uni[i])
    data = filter(heroes2,uni==herolist$uni[i])
    data = full_join(data,ttsinfo,by=c("imgid"="imgid"))
    jsonid = as.numeric(data$id[1])
    for (j in 1:14) {
      cardid = as.numeric(substr(a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$ContainedObjects[[j]]$CardID,
                      nchar(a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$ContainedObjects[[j]]$CardID)-1,
                      nchar(a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$ContainedObjects[[j]]$CardID)))
      if (is.null(a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$ContainedObjects[[j]]$CustomDeck[[1]]$FaceURL)) {
        faceurl = a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$CustomDeck[[1]]$FaceURL
      } else {
        faceurl = a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$ContainedObjects[[j]]$CustomDeck[[1]]$FaceURL
      }
      data2 = filter(data,
                     FaceURL==faceurl,
                     locid==cardid)
      a$ObjectStates[[6]]$ContainedObjects[[jsonid]]$ContainedObjects[[j]]$Tags = list(
        paste(data2$cost,collapse="|"),
        paste(data2$Team,collapse="|")
      )
    }
  }
}

#add set as tags
ttsnames2 = left_join(ttsnames2,herolist,by=c("name"="uni"))
ttsnames2 = left_join(ttsnames2,sets,by=c("Set"="id"))
for (i in 1:dim(ttsnames2)[1]) {
  if (ttsnames2$name[i]!="") {
    for (j in 1:14) {
      a$ObjectStates[[6]]$ContainedObjects[[i]]$ContainedObjects[[j]]$Tags = list(
        ttsnames2$Set[i],
        ttsnames2$label[i]
      )
    }
  }
}

#note: location of cards in images is equal to custom deck id + nr starting from 0
#for the first card on first row

write(toJSON(a,
             digits=NA,
             pretty=T,
             flatten=T,
             auto_unbox=T),
      "tagstest2.json")
