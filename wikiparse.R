library(tidyverse)
library(jsonlite)
library(magrittr)

#go to https://www.boardgamegeek.com/wiki/page/Legendary_Marvel_Complete_Card_Text
#login and select edit, then copy the raw wiki markdown content into a txt file

#herotext=readLines("heroes raw.txt")
wikitext=readLines("wikitext.txt")
wiki = tibble(wikitext)

names = filter(wiki,grepl("== '''",wikitext,fixed=T))
names$id = gsub("== '''","",names$wikitext,fixed=T)
names$id = gsub("''' ==","",names$id,fixed=T)

log1 = 5
j=1
textdata = list()
for (i in 1:length(wikitext)) {
  if (i==length(wikitext)) {
    textdata[[j]] = wiki$wikitext[log1:i]
    names(textdata) = names$id
    break
  }
  if (j!=dim(names)[1]) {
    if (wiki$wikitext[i]==names$wikitext[j+1]) {
      range = c(log1,i-1)
      textdata[[j]] = wiki$wikitext[range[1]:range[2]]
      log1 = i
      j = j+1
    }
  }
}

#get heronames
ht = tibble(herotext=textdata$`Heroes and Allies`)
heronames = filter(ht,grepl("size=14",herotext,fixed=T))
heronames %<>%
  mutate(herotext = gsub("[size=14]'''''","",herotext,fixed=T)) %>%
  mutate(herotext = gsub("'''''[/size]","",herotext,fixed=T))

#get hero text and (separately) set
hero = ""
k=1
j=6
heronames$text = NA
heronames$set = NA
set = "Base"
while (j!=(dim(ht)[1]+1)) {
  if (grepl("===",ht$herotext[j])) {
    heronames$set[k] = set
    set = gsub("=== | ===","",ht$herotext[j])
  } else if (!grepl("size=14",ht$herotext[j])) {
    hero = paste(hero,ht$herotext[j],sep="\n")
  }
  if (grepl("size=14",ht$herotext[j])|
      j==dim(ht)[1]) {
    if (is.na(heronames$set[k])) {
      heronames$set[k] = set
    }
    heronames$text[k] = hero
    hero = ""
    k = k +1
  }
  j = j + 1
}

#remove reprints
heronames %<>%
  filter(!set%in%c("3D","Marvel Studios Phase 1"))

sets = read_csv("sets.csv")

heronames$set = recode(heronames$set,
                       "Secret Wars Volume 2" = "Secret Wars Vol. 2",
                       "Secret Wars Volume 1" = "Secret Wars Vol. 1",
                       "Captain America 75th Anniversary" = "Captain America: 75th Aniversary",
                       "Spider-Man Homecoming" = "Spider-Man: Homecoming",
                       "S.H.I.E.L.D." = "Agents of S.H.I.E.L.D.")

heronames = left_join(heronames,sets,by=c("set"="label"))

heronames$heroname = paste0(heronames$herotext," (",heronames$id,")")

heronames$team=NA
for (i in 1:dim(heronames)[1]) {
  cut = strsplit(heronames$text[i],split="\n")[[1]]
  heronames$team[i] = cut[2]
  cut[1] = paste0("<font size='5'>",heronames$herotext[i],"</font>")
  cut[2] = paste0("<font size='3'><i>",cut[2],"</i></font>")
  cut = gsub("[size=8]''","<font size='1'><i>",cut,fixed=T)
  cut = gsub("''[/size]","</i></font>",cut,fixed=T)
  cut = gsub("[size=14]''","<font size='3'><i>",cut,fixed=T)
  for (j in 1:length(cut)) {
    cut[j] = sub("'''","<i>",cut[j],fixed=T)
    cut[j] = sub("'''","</i>",cut[j],fixed=T)
    cut[j] = sub("''","<b>",cut[j],fixed=T)
    cut[j] = sub("''","</b>",cut[j],fixed=T)
  }
  heronames$text[i] = paste(cut,collapse="\n")
}

##############masterminds##################

mt = tibble(mmtext=textdata$`Masterminds and Commanders`)
mmnames = filter(mt,
                 grepl("size=14",mmtext,fixed=T),
                 !grepl("'Epic ",mmtext,fixed=T),
                 !grepl("(Mastermind, Transformed)",mmtext,fixed=T))
mmnames %<>%
  mutate(mmtext = gsub("[size=14]'''''","",mmtext,fixed=T)) %>%
  mutate(mmtext = gsub("'''''[/size]","",mmtext,fixed=T))

#get mastermind text and (separately) set
mm = ""
k=1
j=6
mmnames$text = NA
mmnames$set = NA
set = "Base"
while (j!=(dim(mt)[1]+1)) {
  if (grepl("===",mt$mmtext[j])) {
    mmnames$set[k] = set
    set = gsub("=== | ===","",mt$mmtext[j])
  } else if (!grepl("size=14",mt$mmtext[j])|
             grepl("'Epic ",mt$mmtext[j],fixed=T)|
             grepl("(Mastermind, Transformed)",mt$mmtext[j],fixed=T)) {
    mm = paste(mm,mt$mmtext[j],sep="\n")
  }
  if (grepl("size=14",mt$mmtext[j])|
      j==dim(mt)[1]) {
    if (!grepl("'Epic",mt$mmtext[j],fixed=T)&
        !grepl("(Mastermind, Transformed)",mt$mmtext[j],fixed=T)) {
      if (is.na(mmnames$set[k])) {
        mmnames$set[k] = set
      }
      mmnames$text[k] = mm
      mm = ""
      k = k +1
    }
  }
  j = j + 1
}

#remove reprints
mmnames %<>%
  filter(!set%in%c("3D","Marvel Studios Phase 1"))

for (i in 1:dim(mmnames)[1]) {
  cut = strsplit(mmnames$text[i],split="\n")[[1]]
  cut[1] = paste0("<font size='4'>",mmnames$mmtext[i],"</font>")
  if (cut[2]=="") {
    cut = cut[-2]
  }
  cut = gsub("'''''[/size]","</font>",cut,fixed=T)
  cut = gsub("[size=14]'''''","<font size='4'>",cut,fixed=T)
  for (j in 1:length(cut)) {
    cut[j] = sub("'''","<b>",cut[j],fixed=T)
    cut[j] = sub("'''","</b>",cut[j],fixed=T)
    cut[j] = sub("''","<i>",cut[j],fixed=T)
    cut[j] = sub("''","</i>",cut[j],fixed=T)
  }
  mmnames$text[i] = paste(cut,collapse="\n")
}


#####################villains

vt = tibble(viltext=textdata$`Villains and Adversaries`)
vilnames = filter(vt,
                 grepl("size=14",viltext,fixed=T))
vilnames %<>%
  mutate(viltext = gsub("[size=14]'''''","",viltext,fixed=T)) %>%
  mutate(viltext = gsub("'''''[/size]","",viltext,fixed=T))

#get villain text and (separately) set
vil = ""
k=1
j=9
vilnames$text = NA
vilnames$set = NA
set = "Base"
while (j!=(dim(vt)[1]+1)) {
  if (grepl("===",vt$viltext[j])) {
    vilnames$set[k] = set
    set = gsub("=== | ===","",vt$viltext[j])
  } else if (!grepl("size=14",vt$viltext[j])) {
    vil = paste(vil,vt$viltext[j],sep="\n")
  }
  if (grepl("size=14",vt$viltext[j])|
      j==dim(vt)[1]) {
    if (is.na(vilnames$set[k])) {
      vilnames$set[k] = set
    }
    vilnames$text[k] = vil
    vil = ""
    k = k +1
  }
  j = j + 1
}

#remove reprints
vilnames %<>%
  filter(!set%in%c("3D","Marvel Studios Phase 1"))

for (i in 1:dim(vilnames)[1]) {
  cut = strsplit(vilnames$text[i],split="\n")[[1]]
  cut[1] = paste0("<font size='4'>",vilnames$viltext[i],"</font>")
  cut = gsub("[size=8]","<font size='1'><i>",cut,fixed=T)
  cut = gsub("[/size]","</i></font>",cut,fixed=T)
  cut = gsub("[size=14]''","<font size='3'><i>",cut,fixed=T)
  for (j in 1:length(cut)) {
    cut[j] = sub("'''","<b>",cut[j],fixed=T)
    cut[j] = sub("'''","</b>",cut[j],fixed=T)
    cut[j] = sub("''","<i>",cut[j],fixed=T)
    cut[j] = sub("''","</i>",cut[j],fixed=T)
  }
  vilnames$text[i] = paste(cut,collapse="\n")
}


##################henchmen

hct = tibble(henchtext=textdata$`Henchmen and Backup Adversaries`)
henchnames = filter(hct,
                  grepl("size=14",henchtext,fixed=T),
                  !grepl("1 copy",henchtext))
henchnames %<>%
  mutate(henchtext = gsub("[size=14]'''''","",henchtext,fixed=T)) %>%
  mutate(henchtext = gsub("'''''[/size]","",henchtext,fixed=T))

#get henchmen text and (separately) set
hench = ""
k=1
j=6
henchnames$text = NA
henchnames$set = NA
set = "Base"
while (j!=(dim(hct)[1]+1)) {
  if (grepl("===",hct$henchtext[j])) {
    henchnames$set[k] = set
    set = gsub("=== | ===","",hct$henchtext[j])
  } else if (!grepl("size=14",hct$henchtext[j])|
             grepl("1 copy",hct$henchtext[j])) {
    hench = paste(hench,hct$henchtext[j],sep="\n")
  }
  if (grepl("size=14",hct$henchtext[j])|
      j==dim(hct)[1]) {
    if (!grepl("1 copy",hct$henchtext[j])) {
      if (is.na(henchnames$set[k])) {
        henchnames$set[k] = set
      }
      henchnames$text[k] = hench
      hench = ""
      k = k +1
    }
  }
  j = j + 1
}

#remove reprints
henchnames %<>%
  filter(!set%in%c("3D","Marvel Studios Phase 1"))

for (i in 1:dim(henchnames)[1]) {
  cut = strsplit(henchnames$text[i],split="\n")[[1]]
  cut[1] = paste0("<font size='3'>",henchnames$henchtext[i],"</font>")
  cut = gsub("'''''[/size]","</font>",cut,fixed=T)
  cut = gsub("[size=14]'''''","<font size='3'>",cut,fixed=T)
  for (j in 1:length(cut)) {
    cut[j] = sub("'''","<b>",cut[j],fixed=T)
    cut[j] = sub("'''","</b>",cut[j],fixed=T)
    cut[j] = sub("''","<i>",cut[j],fixed=T)
    cut[j] = sub("''","</i>",cut[j],fixed=T)
  }
  henchnames$text[i] = paste(cut,collapse="\n")
}


###################schemes


st = tibble(schemtext=textdata$`Schemes and Plots`)

trans = grep("Scheme Transformed",st$schemtext)
transa = trans + 1

schemnames = filter(st[-transa,],
                  grepl("size=14",schemtext,fixed=T))
schemnames %<>%
  mutate(schemtext = gsub("[size=14]'''''","",schemtext,fixed=T)) %>%
  mutate(schemtext = gsub("'''''[/size]","",schemtext,fixed=T))

#get scheme text and (separately) set
schem = ""
k=1
j=6
schemnames$text = NA
schemnames$set = NA
set = "Base"
while (j!=(dim(st)[1]+1)) {
  if (grepl("===",st$schemtext[j])) {
    schemnames$set[k] = set
    set = gsub("=== | ===","",st$schemtext[j])
  } else if (!grepl("size=14",st$schemtext[j])) {
    schem = paste(schem,st$schemtext[j],sep="\n")
  }
  if (grepl("size=14",st$schemtext[j])|
      j==dim(st)[1]) {
    if (is.na(schemnames$set[k])) {
      schemnames$set[k] = set
    }
    schemnames$text[k] = schem
    schem = ""
    k = k +1
  }
  if (st$schemtext[j]=="Scheme Transformed") {
    j = j + 1
    schem = paste(schem,st$schemtext[j],sep="\n")
  }
  j = j + 1
}

#remove reprints
schemnames %<>%
  filter(!set%in%c("3D","Marvel Studios Phase 1"))

for (i in 1:dim(schemnames)[1]) {
  cut = strsplit(schemnames$text[i],split="\n")[[1]]
  cut[1] = paste0("<font size='4'>",schemnames$schemtext[i],"</font>")
  cut = gsub("'''''[/size]","</font>",cut,fixed=T)
  cut = gsub("[size=14]'''''","<font size='4'>",cut,fixed=T)
  for (j in 1:length(cut)) {
    cut[j] = sub("'''","<b>",cut[j],fixed=T)
    cut[j] = sub("'''","</b>",cut[j],fixed=T)
    cut[j] = sub("''","<i>",cut[j],fixed=T)
    cut[j] = sub("''","</i>",cut[j],fixed=T)
  }
  schemnames$text[i] = paste(cut,collapse="\n")
}

#join
heronames$type = "Heroes"
henchnames$type = "Henchmen"
mmnames$type = "Mastermind"
schemnames$type = "Scheme"
vilnames$type = "Villains"

heronames %<>% 
  select(-id,-herotext,-team) %>%
  dplyr::rename(id = heroname)
mmnames %<>% 
  dplyr::rename(id = mmtext)
schemnames %<>% 
  rename(id = schemtext)
vilnames %<>% 
  rename(id = viltext)
henchnames %<>% 
  rename(id = henchtext)

tooltext = rbind(heronames,mmnames,vilnames,schemnames,henchnames)

tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26283_0.png","<img src=\"red.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26284_0.png","<img src=\"yellow.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26285_0.png","<img src=\"blue.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26286_0.png","<img src=\"green.png\">",tooltext$text)
tooltext$text = gsub("https://cf.geekdo-static.com/mbs/mb_26287_0.png","<img src=\"silver.png\">",tooltext$text)
tooltext$text = gsub(" Attack"," <img src=\"Attack.jpg\" width=\"16\">",tooltext$text)
tooltext$text = gsub(" Recruit"," <img src=\"Recruit.jpg\" width=\"16\">",tooltext$text)
tooltext$text = gsub("X-Men","<img src=\"xmen.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Avengers","<img src=\"avengers.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("X-Force","<img src=\"xforce.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Cabal","<img src=\"cabal.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Illuminati","<img src=\"illuminati.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("New Warriors","<img src=\"newwarriors.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Warbound","<img src=\"warbound.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Champions","<img src=\"champions.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Marvel Knights","<img src=\"marvelknights.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Fantastic Four","<img src=\"fantasticfour.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Foes of Asgard","<img src=\"enemiesofasgard.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Spider Friends","<img src=\"spiderman.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("S.H.I.E.L.D.","<img src=\"shield.png\" width=\"16\">",tooltext$text,fixed=T)
tooltext$text = gsub("Brotherhood","<img src=\"brotherhood.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Mercs for Money","<img src=\"deadpool.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Crime Syndicate","<img src=\"crimesyndicate.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Guardians of the Galaxy","<img src=\"guardians.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Heroes of Asgard","<img src=\"heroesofasgard.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Venomverse","<img src=\"venompool.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("Sinister Six","<img src=\"sinistersix.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("HYDRA","<img src=\"hydra.png\" width=\"16\">",tooltext$text)
tooltext$text = gsub("1/2","½",tooltext$text,fixed=T)

#manual edits using legendary-textedit to fix remaining markdown problems
#so best not to overwrite the whole old file, but only add new ones
#filter easily with set name

write_tsv(tooltext,"tooltext.txt",na="")