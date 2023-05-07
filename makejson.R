library(tidyverse)

data = read_tsv("data/tooltext.txt",show_col_types = F)

data_heroes = filter(data,type=="Heroes")
data_herocards = tibble(cardname = NA,
                        heroname = NA,
                        team = NA,
                        heroclass = NA,
                        copies = NA,
                        attack = NA,
                        recruit = NA,
                        cost = NA,
                        split = NA,
                        effect = NA,
                        flavor = NA,
                        labels = NA,
                        transforms_from = NA)
herocard_init = data_herocards

data_herosplit = tibble(cardname = NA,
                        name = NA,
                        team = NA,
                        heroclass = NA,
                        attack = NA,
                        recruit = NA,
                        effect = NA,
                        flavor = NA,
                        labels = NA)

herosplit_init = data_herosplit

#ignore flavor and label for guns for now
#split and transf to do

for (i in 1:dim(data_heroes)[1]) {
  sub = strsplit(data_heroes$text[i],split="\r<br>")[[1]]
  j = 0
  team = NA
  card = herocard_init
  id = 0
  pump = 0
  while (j<length(sub)+1) {
    j = j + 1
    if (grepl("<font size='3'><i>",sub[j],fixed=T)) {
      team = gsub("<.*?>","",sub[j])
    }
    if (grepl("<b>",sub[j],fixed=T)) {
      id = id + 1
      if (id > 1) {
        card = rbind(card,herocard_init)
      }
      card$cardname[id] = str_extract(sub[j],"<b>.*</b>") %>%
        gsub("<.*?>","",.)
      card$copies[id] = gsub(".*</b> \\(","",sub[j]) %>%
        gsub(" copies)","",.,fixed=T) %>%
        gsub(" copy)","",.,fixed=T)
      card$heroclass[id] = str_extract_all(sub[j+1],"\".*?\"") %>%
        gsub("\"","",.) %>%
        gsub(".png","",.,fixed = T) %>%
        paste(.,collapse="|")
      if (grepl("^[0-9].* Recruit",sub[j+2])) {
        card$recruit[id] = gsub(" Recruit","",sub[j+2])
        pump = pump + 1
      }
      if (grepl("^[0-9].* Attack",sub[j+2])) {
        card$attack[id] = gsub(" Attack","",sub[j+2])
        pump = pump + 1
      } else if (grepl("^[0-9].* Attack",sub[j+3])) {
        card$attack[id] = gsub(" Attack","",sub[j+3])
        pump = pump + 1
      }
      costf = F
      j = j + pump + 1
      pump = 0
      while (!costf) {
        j = j + 1
        if (grepl("Cost: ",sub[j])) {
          card$cost[id] = gsub("Cost: ","",sub[j])
          costf = T
        } else {
          card$effect[id] = ifelse(is.na(card$effect[id]),
                                   sub[j],
                                   paste(card$effect[id],sub[j],sep="\r"))
        }
      }
      card$team[id] = team
    }
  }
  card$heroname = data_heroes$id[i]
  data_herocards = rbind(data_herocards,card)
}
data_herocards = data_herocards[-1,]