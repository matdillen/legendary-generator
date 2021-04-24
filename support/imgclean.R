setwd("D:/Mathias/legendary")
library(tidyverse)
library(jsonlite)

#read the json file for the mod/save you want to edit
a = fromJSON("lua/TS_Save_72.json",
             simplifyVector = F)

#fix nickname that doesn't match
#a$ObjectStates[[mmid]]$ContainedObjects[[74]]$Nickname = "Emperor Vulcan of the Shi'ar"
#a$ObjectStates[[vilid]]$ContainedObjects[[90]]$Nickname = "Shi'ar Imperial Elite"

#map filenames from data to urls
imgconv = read_csv2("legendary-generator/support/imgmap.csv")
fixdfc = read_tsv("fixdfc.txt",col_names = F)

#function to construct url from tts saved filename
urlGen <- function(str) {
  str2 = str
  for (i in 1:length(str)) {
    if (grepl("iimgur",str[i])) {
      str2[i] = paste0("http://i.imgur.com/",
                       gsub("httpiimgurcom","",str[i]))
      str2[i] = gsub("jpg.jpg",".jpg",str2[i],fixed=T)
    }
    if (grepl("steamuser",str[i])) {
      check = nchar(str[i])
      str2[i] = paste0("http://cloud-3.steamusercontent.com/ugc/",
                       substr(str[i],33,check-44),
                       "/",
                       substr(str[i],check-43,check-4),
                       "/")
    }
  }
  return(str2)
}
fixdfc$url = urlGen(fixdfc$X2)

#add urls and sync dumb comma filenames that originated due to initial entry in excel
imgconv$fullurl = urlGen(imgconv$url)
imgconv$file = gsub(".",",",imgconv$file,fixed=T)

#raw card data
heroes=read_csv2('legendary-generator/data/heroes.csv')
schemes=read_csv2('legendary-generator/data/schemes.csv')
villains=read_csv2('legendary-generator/data/villains.csv')
henchmen=read_csv2('legendary-generator/data/henchmen.csv')
masterminds=read_csv2('legendary-generator/data/masterminds.csv')

#convert location within img to format used by tts
#if givedim is set true, it will return the dimensions
#of the source image rather than the converted coordinates
locConv <- function(locids,givedim=F) {
  for (i in 1:length(locids)) {
    if (is.na(locids[i])) {
      #missing info
      next
    }
    else if (locids[i]==1) {
      #single img for single card
      locids[i] = "00"
      dims = "1 1"
    } else if (!grepl(" ",locids[i],fixed=T)) {
      #combination of four cards
      locids[i] = recode(locids[i],
                         "NW"="00",
                         "NE"="01",
                         "SW"="02",
                         "SE"="03")
      dims = "2 2"
    } else {
      #10*7 type of image
      parts = as.numeric(strsplit(locids[i],split=" ")[[1]])
      locids[i] = sprintf("%02d",parts[1] + 10*(parts[2]-1) - 1)
      dims = "10 7"
    }
  }
  if (!givedim) {
    return(locids)
  }
  if (givedim) {
    return(dims)
  }
}

#use this to find the location in the json of certain decks
bags = tibble(id=seq(1,length(a$ObjectStates)),name=NA)
bags$content = NA
for (i in 1:length(a$ObjectStates)) {
  bags$name[i] = a$ObjectState[[i]]$Nickname
  try(bags$content[i] <- length(a$ObjectState[[i]]$ContainedObjects),silent=T)
}

mmid = 14
henchid = 13
heroid = 11
vilid = 17
schid = 97

#convert data coordinates to tts format and convert filenames to urls
masterminds$locid = locConv(masterminds$loc)
masterminds = left_join(masterminds,imgconv,by=c("file"="file"))

#script to harmonize mastermind src images and add card names, vp tags:
for (i in 1:length(a$ObjectStates[[mmid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[mmid]]$ContainedObjects[[i]]
  
  #the name of the mm
  mmname = a$ObjectStates[[mmid]]$ContainedObjects[[i]]$Nickname
  
  #data associated with the mm
  data = filter(masterminds,Name==mmname|MM==mmname)
  #extra filter to exclude tactic names that correspond to mm names (e.g. adapters)
  data = filter(data,is.na(MM)|MM==data$Name[1])
  
  #list of all filenames for this mastermind
  #filters: transforming or epic backsides are added differently
  #filters: placeholder names for adapters are excluded (no file value)
  filenames = data %>%
    filter(is.na(`T`),is.na(Epic)) %>%
    count(file,fullurl) %>%
    filter(!is.na(file))
  
  backsidename = data %>%
    filter(!is.na(T)|!is.na(Epic)) %>%
    pull(fullurl)
  
  if (mmname%in%fixdfc$X1) {
    backsidename = filter(fixdfc,X1==mmname)$url
  }
  
  #deckids are only locally relevant, so keep the ones already there
  #store in filenames to connect them to the cards inside the mastermind's deck
  filenames$deckid = NA
  
  cdsize = dim(filenames)[1] + length(backsidename)
  #construct CustomDeck
  ##this contains info for all images used by this mastermind
  if (length(src$CustomDeck)<cdsize) {
    over = cdsize-length(src$CustomDeck)
    for (k in 1:over) {
      cid = as.numeric(names(src$CustomDeck)[k])+23
      src$CustomDeck$cid = src$CustomDeck[[k]]
      names(src$CustomDeck) = gsub("cid",cid,names(src$CustomDeck))
    }
  }
  for (j in 1:cdsize) {
    #there may be more filenames after the harmonization than before
    #if so, add a random extra entry with a random identifier
    #identifiers are not properly checked, so it's possible this could create a duplicate!
    
    if (length(backsidename)!=0&j==cdsize) {
      src$CustomDeck[[j]]$FaceURL = data$fullurl[1]
      src$CustomDeck[[j]]$BackURL = backsidename
      dims = strsplit(locConv(data$loc[1],
                              givedim=T),
                      split=" ")[[1]]
      src$CustomDeck[[j]]$NumWidth = dims[1]
      src$CustomDeck[[j]]$NumHeight = dims[2]
      next
    }
    #set the front url
    src$CustomDeck[[j]]$FaceURL = filenames$fullurl[j]
    
    #set the default legendary card back
    src$CustomDeck[[j]]$BackURL = "http://cloud-3.steamusercontent.com/ugc/1693876947372983484/86017C1961652127E362E1DD3D6B78B3B383104B/"
    
    #retrieve the dimensions for the src image and set them
    dims = strsplit(locConv(filter(data,
                                   file==filenames$file[j])$loc,
                            givedim=T)[1],
                    split=" ")[[1]]
    src$CustomDeck[[j]]$NumWidth = dims[1]
    src$CustomDeck[[j]]$NumHeight = dims[2]
    
    #store the id for this image
    filenames$deckid[j] = names(src$CustomDeck)[j]
  }
  #remove unnecessary additional entries after harmonization in CustomDeck
  #if (dim(filenames)[1]<length(src$CustomDeck)) {
  #  src$CustomDeck = src$CustomDeck[-c(dim(filenames2)[1]+1:length(src$CustomDeck))]
  #}
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  cardids = ""
  
  #set vp, which is always the same for a mastermind's tactics
  vp = data$VP[1]
  
  #nr of cards, which may not match dimensions of data due to epic/transfo
  cardnr = 1
  
  
  for (l in 1:dim(data)[1]) {
    #if placeholder for adapter, vp will be NA, so fix that and skip
    if (is.na(data$url[l])) {
      vp = data$VP[2]
      next
    }
    
    #if not a backside, add card name, vp tag, CardId and store CardID
    if (is.na(data$T[l])&is.na(data$Epic[l])) {
      src$ContainedObjects[[cardnr]]$CustomDeck = NULL
      
      #set card's name
      src$ContainedObjects[[cardnr]]$Nickname = data$Name[l]
      
      #get the deckid for the filename and build the CardID
      #which is DeckID + coordinates, with padded zeros if < 10
      init = filter(filenames,file==data$file[l])$deckid
      src$ContainedObjects[[cardnr]]$CardID = paste0(init,
                                                data$locid[l])
      
      #Store cardid
      cardids = paste(cardids,src$ContainedObjects[[cardnr]]$CardID,sep="|")
      
      #set a tag for VP
      src$ContainedObjects[[cardnr]]$Tags = list(paste0("VP",vp))
      
      #step var for next card (as j may not correspond if t/epic)
      cardnr = cardnr + 1
    } else {
      src$ContainedObjects[[1]]$CardID = paste0(names(src$CustomDeck)[cdsize],
                                                data$locid[1])
      cardids = sub("\\|.*",paste0("|",src$ContainedObjects[[1]]$CardID),cardids)
    }
  }
  
  #reorder the cards and card ids so the front card is on top
  temp = src$ContainedObjects[[1]]
  src$ContainedObjects[[1]] = src$ContainedObjects[[cardnr-1]]
  src$ContainedObjects[[cardnr-1]] = temp
  cardids = strsplit(cardids,split="\\|")[[1]][-1]
  temp = cardids[1]
  cardids[1] = cardids[cardnr-1]
  cardids[cardnr-1] = temp
  
  #add the cardids
  src$DeckIDs = as.list(cardids)
  
  #readd the modified record to the save file
  a$ObjectStates[[mmid]]$ContainedObjects[[i]] = src
}

#analytics to look through the save file's values
# 
# mminfo = tibble(id=seq(1,74))
# mminfo$deckids = NA
# mminfo$fname = ""
# mminfo$bname = ""
# for (i in 1:74) {
#   mminfo$deckids[i] = paste(names(a$ObjectStates[[mmid]]$ContainedObjects[[i]]$CustomDeck),collapse="|")
#   for (j in 1:length(a$ObjectStates[[mmid]]$ContainedObjects[[i]]$CustomDeck)) {
#     mminfo$fname[i] = paste(mminfo$fname[i],
#                             a$ObjectStates[[mmid]]$ContainedObjects[[i]]$CustomDeck[[j]]$FaceURL,sep="|")
#     mminfo$bname[i] = paste(mminfo$bname[i],
#                             a$ObjectStates[[mmid]]$ContainedObjects[[i]]$CustomDeck[[j]]$BackURL,sep="|")
#   }
# }
# mminfo2 = mminfo %>%
#   mutate(fname = sub("|","",fname,fixed=T),
#          bname = sub("|","",bname,fixed=T)) %>%
#   separate_rows(deckids,fname,bname,sep="\\|")

#fix villains

villains$locid = locConv(villains$loc)
villains = left_join(villains,imgconv,by=c("file"="file"))

#script to harmonize villains src images and add card names, vp tags:
for (i in 1:length(a$ObjectStates[[vilid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[vilid]]$ContainedObjects[[i]]
  
  #the name of the villain group
  vilname = a$ObjectStates[[vilid]]$ContainedObjects[[i]]$Nickname
  
  #data associated with the villain group
  data = filter(villains,Group==vilname)
  
  #list of all filenames for this villain group
  filenames = data %>%
    count(file,fullurl)
  
  #deckids are only locally relevant, so keep the ones already there
  #store in filenames to connect them to the cards inside the villain group deck
  filenames$deckid = NA
  
  #construct CustomDeck
  ##this contains info for all images used by this villain group
  for (j in 1:dim(filenames)[1]) {
    #there may be more filenames after the harmonization than before
    #if so, add a random extra entry with a random identifier
    #identifiers are not properly checked, so it's possible this could create a duplicate!
    if (length(src$CustomDeck)<j) {
      cid = as.numeric(names(src$CustomDeck)[j-1])+23
      src$CustomDeck$cid = src$CustomDeck[[j-1]]
      names(src$CustomDeck)[j] = cid
    }
    
    #set the front url
    src$CustomDeck[[j]]$FaceURL = filenames$fullurl[j]
    
    #set the default legendary card back
    src$CustomDeck[[j]]$BackURL = "http://cloud-3.steamusercontent.com/ugc/1693876947372983484/86017C1961652127E362E1DD3D6B78B3B383104B/"
    
    #retrieve the dimensions for the src image and set them
    dims = strsplit(locConv(filter(data,
                                   file==filenames$file[j])$loc,
                            givedim=T)[1],
                    split=" ")[[1]]
    src$CustomDeck[[j]]$NumWidth = dims[1]
    src$CustomDeck[[j]]$NumHeight = dims[2]
    
    #store the id for this image
    filenames$deckid[j] = names(src$CustomDeck)[j]
  }
  
  #remove unnecessary additional entries after harmonization in CustomDeck
  if (dim(filenames)[1]>length(src$CustomDeck)) {
    src$CustomDeck = src$CustomDeck[-c(dim(filenames)[1]+1:length(src$CustomDeck))]
  }
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  cardids = ""
  cardnr = 1
  
  for (j in 1:dim(data)[1]) {
    #add card name, vp tag, CardId and store CardID
    for (k in 1:data$Ct[j]) {
      #set card's name
      src$ContainedObjects[[cardnr]]$Nickname = data$Name[j]
      
      #get the deckid for the filename and build the CardID
      #which is DeckID + coordinates, with padded zeros if < 10
      init = filter(filenames,file==data$file[j])$deckid
      src$ContainedObjects[[cardnr]]$CardID = paste0(init,
                                                     data$locid[j])
      
      #Store cardid
      cardids = paste(cardids,src$ContainedObjects[[cardnr]]$CardID,sep="|")
      
      #set a tag for VP
      src$ContainedObjects[[cardnr]]$Tags = list(paste0("VP",data$VP[j]))
      
      #step var for next card (as j may not correspond if t/epic)
      cardnr = cardnr + 1
    }
  }
  
  #add the cardids
  cardids = strsplit(cardids,split="\\|")[[1]][-1]
  src$DeckIDs = as.list(cardids)
  
  #readd the modified record to the save file
  a$ObjectStates[[vilid]]$ContainedObjects[[i]] = src
}

#fix henchmen

henchmen$locid = locConv(henchmen$loc)
henchmen = left_join(henchmen,imgconv,by=c("file"="file"))

#script to harmonize villains src images and add card names, vp tags:
for (i in 1:length(a$ObjectStates[[henchid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[henchid]]$ContainedObjects[[i]]
  
  #the name of the villain group
  henchname = a$ObjectStates[[henchid]]$ContainedObjects[[i]]$Nickname
  
  #data associated with the villain group
  data = filter(henchmen,Name==henchname)
  
  if (dim(data)[1]==0) {
    next
  }
  
  #list of all filenames for this villain group
  filenames = data %>%
    count(file,fullurl)
  
  #deckids are only locally relevant, so keep the ones already there
  #store in filenames to connect them to the cards inside the villain group deck
  filenames$deckid = NA
  
  #construct CustomDeck
  ##this contains info for all images used by this villain group
  for (j in 1:dim(filenames)[1]) {
    #there may be more filenames after the harmonization than before
    #if so, add a random extra entry with a random identifier
    #identifiers are not properly checked, so it's possible this could create a duplicate!
    if (length(src$CustomDeck)<j) {
      cid = as.numeric(names(src$CustomDeck)[j-1])+23
      src$CustomDeck$cid = src$CustomDeck[[j-1]]
      names(src$CustomDeck)[j] = cid
    }
    
    #set the front url
    src$CustomDeck[[j]]$FaceURL = filenames$fullurl[j]
    
    #set the default legendary card back
    src$CustomDeck[[j]]$BackURL = "http://cloud-3.steamusercontent.com/ugc/1693876947372983484/86017C1961652127E362E1DD3D6B78B3B383104B/"
    
    #retrieve the dimensions for the src image and set them
    dims = strsplit(locConv(filter(data,
                                   file==filenames$file[j])$loc,
                            givedim=T)[1],
                    split=" ")[[1]]
    src$CustomDeck[[j]]$NumWidth = dims[1]
    src$CustomDeck[[j]]$NumHeight = dims[2]
    
    #store the id for this image
    filenames$deckid[j] = names(src$CustomDeck)[j]
  }
  
  #remove unnecessary additional entries after harmonization in CustomDeck
  if (dim(filenames)[1]>length(src$CustomDeck)) {
    src$CustomDeck = src$CustomDeck[-c(dim(filenames)[1]+1:length(src$CustomDeck))]
  }
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  cardids = ""
  cardnr = 1
  
  for (j in 1:dim(data)[1]) {
    #add card name, vp tag, CardId and store CardID
    for (k in 1:data$Ct[j]) {
      #set card's name
      if (is.na(data$NameSpecific[j])) {
        src$ContainedObjects[[cardnr]]$Nickname = data$Name[j]
      } else{
        src$ContainedObjects[[cardnr]]$Nickname = data$NameSpecific[j]
      }
      
      #get the deckid for the filename and build the CardID
      #which is DeckID + coordinates, with padded zeros if < 10
      init = filter(filenames,file==data$file[j])$deckid
      src$ContainedObjects[[cardnr]]$CardID = paste0(init,
                                                     data$locid[j])
      
      #Store cardid
      cardids = paste(cardids,src$ContainedObjects[[cardnr]]$CardID,sep="|")
      
      #set a tag for VP
      src$ContainedObjects[[cardnr]]$Tags = list(paste0("VP","1"))
      
      #step var for next card (as j may not correspond if t/epic)
      cardnr = cardnr + 1
    }
  }
  
  #add the cardids
  cardids = strsplit(cardids,split="\\|")[[1]][-1]
  src$DeckIDs = as.list(cardids)
  
  #readd the modified record to the save file
  a$ObjectStates[[henchid]]$ContainedObjects[[i]] = src
}

#fix heroes

heroes$locid = locConv(heroes$loc)
heroes = left_join(heroes,imgconv,by=c("file"="file"))

heroes$uni = paste0(heroes$Hero," (",heroes$Set,")")

heroClassTag <- function(card) {
  classes = ""
  for (i in 1:dim(card)[1]) {
    if (!is.na(card$B[i])) {
      classes = c(classes,"HC:Blue")
    }
    if (!is.na(card$R[i])) {
      classes = c(classes,"HC:Red")
    }
    if (!is.na(card$G[i])) {
      classes = c(classes,"HC:Green")
    }
    if (!is.na(card$Y[i])) {
      classes = c(classes,"HC:Yellow")
    }
    if (!is.na(card$S[i])) {
      classes = c(classes,"HC:Silver")
    }
  }
  classes = classes[-1]
  classes = classes[!duplicated(classes)]
  return(classes)
}

#script to harmonize heroes src images and add card names, card properties:
for (i in 1:length(a$ObjectStates[[heroid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[heroid]]$ContainedObjects[[i]]
  
  #the name of the villain group
  heroname = a$ObjectStates[[heroid]]$ContainedObjects[[i]]$Nickname
  
  # if (heroname=="No-Name, Brood Queen (WW)") {
  #   print(i)
  # }
  
  #data associated with the villain group
  data = heroes %>%
    filter(uni==heroname) %>%
    filter(is.na(Split)|!grepl("T",Split)|!duplicated(Split))
  
  if (dim(data)[1]==0) {
    next
  }
  
  #list of all filenames for this villain group
  filenames = data %>%
    count(file,fullurl)
  
  #deckids are only locally relevant, so keep the ones already there
  #store in filenames to connect them to the cards inside the villain group deck
  filenames$deckid = NA
  
  #construct CustomDeck
  ##this contains info for all images used by this villain group
  for (j in 1:dim(filenames)[1]) {
    #there may be more filenames after the harmonization than before
    #if so, add a random extra entry with a random identifier
    #identifiers are not properly checked, so it's possible this could create a duplicate!
    if (length(src$CustomDeck)<j) {
      cid = as.numeric(names(src$CustomDeck)[j-1])+23
      src$CustomDeck$cid = src$CustomDeck[[j-1]]
      names(src$CustomDeck)[j] = cid
    }
    
    #set the front url
    src$CustomDeck[[j]]$FaceURL = filenames$fullurl[j]
    
    #set the default legendary card back
    src$CustomDeck[[j]]$BackURL = "http://cloud-3.steamusercontent.com/ugc/1693876947372983484/86017C1961652127E362E1DD3D6B78B3B383104B/"
    
    #retrieve the dimensions for the src image and set them
    dims = strsplit(locConv(filter(data,
                                   file==filenames$file[j])$loc,
                            givedim=T)[1],
                    split=" ")[[1]]
    src$CustomDeck[[j]]$NumWidth = dims[1]
    src$CustomDeck[[j]]$NumHeight = dims[2]
    
    #store the id for this image
    filenames$deckid[j] = names(src$CustomDeck)[j]
  }
  
  #remove unnecessary additional entries after harmonization in CustomDeck
  #if (dim(filenames)[1]>length(src$CustomDeck)) {
  #  src$CustomDeck = src$CustomDeck[-c(dim(filenames)[1]+1:length(src$CustomDeck))]
  #}
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  cardids = ""
  cardnr = 1
  data2 = filter(data,is.na(Split)|!duplicated(Split))
  for (j in 1:dim(data2)[1]) {
    #add card name, vp tag, CardId and store CardID
    dataCard = data2[j,]
    if (!is.na(data2$Split[j])&!grepl("T",data2$Split[j])) {
      dataCard = filter(data,Split==data2$Split[j])
    }
    for (k in 1:data2$Ct[j]) {
      #set card's name
      src$ContainedObjects[[cardnr]]$Nickname = heroname
      
      #get the deckid for the filename and build the CardID
      #which is DeckID + coordinates, with padded zeros if < 10
      init = filter(filenames,file==data2$file[j])$deckid
      src$ContainedObjects[[cardnr]]$CardID = paste0(init,
                                                     data2$locid[j])
      
      #Store cardid
      cardids = paste(cardids,src$ContainedObjects[[cardnr]]$CardID,sep="|")
      
      #set a tag for VP
      class = heroClassTag(dataCard)
      team = c(dataCard$Team)
      team = paste0("Team:",team)
      cost = paste0("Cost:",dataCard$C[1])
      tags = c(class,team,cost)
      src$ContainedObjects[[cardnr]]$Tags = as.list(tags)
      
      #step var for next card (as j may not correspond if t/epic)
      cardnr = cardnr + 1
    }
  }
  
  #add the cardids
  cardids = strsplit(cardids,split="\\|")[[1]][-1]
  src$DeckIDs = as.list(cardids)
  
  #readd the modified record to the save file
  a$ObjectStates[[heroid]]$ContainedObjects[[i]] = src
}

#bystander vp
bsid = 113

for (i in 1:length(a$ObjectStates[[bsid]]$ContainedObjects)) {
  a$ObjectStates[[bsid]]$ContainedObjects[[i]]$Tags = list("VP1","Bystander")
}

#export
write(toJSON(a,
             digits=NA,
             pretty=T,
             flatten=T,
             auto_unbox=T),
      "fixmm.json")

#after export, add to saves and then edit the SaveFileInfos.json correctly