
tooltext = read_tsv("data/tooltext.txt")
herotext = filter(tooltext,type=="Heroes")
heroes=read_csv2('data/heroes.csv')

library(tidyverse)
library(magrittr)
library(jsonlite)

attack = NA
recruit = NA
herotext$summ = NA
for (i in 1:dim(herotext)[1]) {
  str = strsplit(herotext$text[i],split="\n|\r")[[1]]
  cards = ""
  j = 1
  while (j<length(str)) {
    attack = ""
    finalattack = ""
    recruit = ""
    finalrecruit = ""
    if (grepl("<br><b>",str[j],fixed=T)) {
      k = j+1
      name = gsub("(?<=\\<).+?(?=\\>)","",str[j],perl=T)
      name = gsub("<|>","",name)
      while (!grepl("<br><b>",str[k],fixed=T)&k<length(str)) {
        if (grepl("Attack.jpg",str[k],fixed=T)) {
          if (nchar(str[k])<41) {
            attack = gsub("(?<=\\<).+?(?=\\>)","",str[k],perl=T)
            attack = gsub("<|>","",attack)
            finalattack = paste(finalattack,attack,sep="$")
          }
        }
        if (grepl("Recruit.jpg",str[k],fixed=T)) {
          if (nchar(str[k])<42) {
            recruit = gsub("(?<=\\<).+?(?=\\>)","",str[k],perl=T)
            recruit = gsub("<|>","",recruit)
            finalrecruit = paste(finalrecruit,recruit,sep="$")
          }
        }
        k = k +1
      }
      cards = paste0(cards,"|",name,"{","Attack=",finalattack,",Recruit=",finalrecruit,"}")
      j=k-1
    }
    j = j + 1
  }
  herotext$summ[i] = cards
}

herotext2 = herotext %>%
  separate_rows(summ,sep="\\|") %>%
  filter(summ!="")

for (i in 1:dim(herotext2)[1]) {
  herotext2$textname[i] = strsplit(herotext2$summ[i],split=" (",fixed=T)[[1]][1]
  herotext2$copies[i] = strsplit(herotext2$summ[i],split="\\)|\\(")[[1]][2]
  herotext2$copies2[i] = ifelse(grepl("copies|copy",herotext2$copies[i]),
                                gsub(" .*","",herotext2$copies[i]),
                                NA)
  stats = strsplit(herotext2$summ[i],split="\\{")[[1]][2]
  herotext2$attack[i] = strsplit(stats,split=",",fixed=T)[[1]][1]
  herotext2$recruit[i] = strsplit(stats,split=",",fixed=T)[[1]][2]
}

herotext2$attack2 = gsub("Attack=","",herotext2$attack)
herotext2$recruit2 = gsub("Recruit=|\\}","",herotext2$recruit)

heroes$uni = paste0(heroes$Hero," (",heroes$Set,")")

data = filter(herotext2,id==herotext$id[1])
data2 = filter(heroes,uni==herotext$id[1])
data = arrange(data,copies2,textname)
data2 = arrange(data2,Ct,Name)
data2$attack = data$attack2
data2$recruit = data$recruit2
data2$verbatimName = data$textname
alldata = data2

for (i in 2:dim(herotext)[1]) {
  data = filter(herotext2,id==herotext$id[i])
  data2 = filter(heroes,uni==herotext$id[i])
  if (dim(data)[1]<5) {
    data = arrange(data,copies2,textname)
    data2 = arrange(data2,Ct,Name)
    data2$attack = data$attack2
    data2$recruit = data$recruit2
    data2$verbatimName = data$textname
  } else {
    data = arrange(data,copies2,textname)
    data2 = arrange(data2,Ct,Name)
    data %<>% filter(!grepl("/",textname,fixed=T))
    data2$attack = data$attack2
    data2$recruit = data$recruit2
    data2$verbatimName = data$textname
  }
  alldata = rbind(alldata,data2)
}

a = fromJSON("../lua/TS_Save_82.json",
             simplifyVector = F)

heroid = 10

imgconv = read_csv2("support/imgmap.csv")

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
imgconv$fullurl = urlGen(imgconv$url)
imgconv$file = gsub(".",",",imgconv$file,fixed=T)

alldata$locid = locConv(alldata$loc)
heroes_all = left_join(alldata,imgconv,by=c("file"="file"))

for (i in 1:length(a$ObjectStates[[heroid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[heroid]]$ContainedObjects[[i]]
  
  heroname = a$ObjectStates[[heroid]]$ContainedObjects[[i]]$Nickname
  
  data = heroes_all %>%
    filter(uni==heroname) %>%
    filter(is.na(Split)|!is.na(T0)|!grepl("T",Split))
  
  if (dim(data)[1]==0) {
    next
  }
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  for (j in 1:length(src$ContainedObjects)) {
    deckidloc = str_sub(src$ContainedObjects[[j]]$CardID,-2,-1)
    deckid = str_sub(src$ContainedObjects[[j]]$CardID,0,-3)
    subdata = filter(data,
                     fullurl==src$CustomDeck[[deckid]]$FaceURL,
                     locid==deckidloc)
    tags = src$ContainedObjects[[j]]$Tags
    for (k in 1:dim(subdata)[1]) {
      if (subdata$attack[k]!="") {
        tags = c(tags,paste0("Attack:",gsub("$","",subdata$attack[k],fixed=T)))
      }
      if (subdata$recruit[k]!="") {
        tags = c(tags,paste0("Recruit:",gsub("$","",subdata$recruit[k],fixed=T)))
      }
    }
    src$ContainedObjects[[j]]$Tags = tags
  }
  a$ObjectStates[[heroid]]$ContainedObjects[[i]] = src
}


masterminds=read_csv2('data/masterminds.csv')
mmid = 12

for (i in 1:length(a$ObjectStates[[mmid]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[mmid]]$ContainedObjects[[i]]
  
  mmname = a$ObjectStates[[mmid]]$ContainedObjects[[i]]$Nickname
  
  data = filter(masterminds,Name==mmname|MM==mmname)
  #extra filter to exclude tactic names that correspond to mm names (e.g. adapters)
  data = filter(data,is.na(MM)|MM==data$Name[1])
  
  if (dim(data)[1]==0) {
    next
  }
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  fixedBP = data$BP[1]
  for (j in 1:length(src$ContainedObjects)) {
    tags = src$ContainedObjects[[j]]$Tags
    subdata = data %>%
      filter(Name==src$ContainedObjects[[j]]$Nickname,
             !is.na(file))
    
    if (dim(subdata)[1]==1) {
      tags = c(tags,"Mastermind",paste0("Attack:",ifelse(is.na(subdata$BP[1]),fixedBP,subdata$BP[1])))
    }
    if (dim(subdata)[1]==2) {
      tags = c(tags,"Mastermind",paste0("Attack:",fixedBP),paste0("Epic:",subdata$BP[2]))
    }
    if (!is.na(data$T[2])&j==5) {
      tags = c(tags,paste0("Transformed:",data$BP[2]))
    }
    src$ContainedObjects[[j]]$Tags = tags
  }
  a$ObjectStates[[mmid]]$ContainedObjects[[i]] = src
}

villains = read_csv2("data/villains.csv")


for (i in 1:length(a$ObjectStates[[13]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[13]]$ContainedObjects[[i]]
  
  mmname = a$ObjectStates[[13]]$ContainedObjects[[i]]$Nickname
  
  data = filter(villains,Group==mmname)
  
  if (dim(data)[1]==0) {
    next
  }
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  for (j in 1:length(src$ContainedObjects)) {
    tags = src$ContainedObjects[[j]]$Tags
    subdata = data %>%
      filter(Name==src$ContainedObjects[[j]]$Nickname)
    
    tags = tags[!grepl("Power:",tags)]
    
    if (subdata$BP[1]=="-1") {
      tags = c(tags,"Trap")
      next
    }
    if (dim(subdata)[1]>1) {
      print(paste0(i," ",mmname," threw an error at ",j))
      break
    }
    tags = c(tags,paste0("Power:",subdata$BP[1]))
    if (grepl("LOCATION:",src$ContainedObjects[[j]]$Description,fixed=T)) {
      tags = c(tags,"Location")
    } else if (grepl("VILLAINOUS WEAPON:",src$ContainedObjects[[j]]$Description,fixed=T)) {
      tags = c(tags,"Villainous Weapon")
    } else {
      tags = c(tags,"Villain")
    }
    src$ContainedObjects[[j]]$Tags = tags
  }
  a$ObjectStates[[13]]$ContainedObjects[[i]] = src
}

#henchmen!

henchmen = read_csv2("data/henchmen.csv")



for (i in 1:length(a$ObjectStates[[11]]$ContainedObjects)) {
  #this is a temporary extract to work in to save text and for troubleshooting
  src = a$ObjectStates[[11]]$ContainedObjects[[i]]
  
  mmname = a$ObjectStates[[11]]$ContainedObjects[[i]]$Nickname
  
  data = filter(henchmen,Name==mmname)
  
  if (dim(data)[1]==0) {
    next
  }
  
  #list of cardids to be used
  #the order of this list also indicates the order of appearance in the deck in tts
  for (j in 1:length(src$ContainedObjects)) {
    tags = src$ContainedObjects[[j]]$Tags
    tags = c(tags,paste0("Power:",data$BP[1]),"Henchmen")
    if (grepl("LOCATION:",src$ContainedObjects[[j]]$Description,fixed=T)) {
      tags = c(tags,"Location")
    } else if (grepl("VILLAINOUS WEAPON:",src$ContainedObjects[[j]]$Description,fixed=T)) {
      tags = c(tags,"Villainous Weapon")
    } else {
      tags = c(tags,"Villain")
    }
    src$ContainedObjects[[j]]$Tags = tags
  }
  a$ObjectStates[[11]]$ContainedObjects[[i]] = src
}

write(toJSON(a,
             digits=NA,
             pretty=T,
             flatten=T,
             auto_unbox=T),
      "TS_Save_83.json")
