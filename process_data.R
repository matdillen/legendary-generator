library(tidyverse)
library(magrittr)

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

tooltext = rbind(select(heroestext,text,id),mmtext,viltext,schemtext,henchtext)

#duplicate ids are possible in theory
#in practice one occurs: maximum carnage
#now captured by difference in casing, but needs a more reliable fix
#probably work with card type namespace somehow, but this requires quite some changes

#HTML formatting of card text
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

###########################
#KEYWORDS

keywords = rbind(keywords,tibble(name="",text="",id=""))
keywords %<>% arrange(id)
keywords$text = gsub("[Attack]",
                     "<img src=\"Attack.jpg\" width=\"16\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[+Attack]",
                     "+<img src=\"Attack.jpg\" width=\"16\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[Recruit]",
                     "<img src=\"Recruit.jpg\" width=\"16\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[+Recruit]",
                     "+<img src=\"Recruit.jpg\" width=\"16\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("Attack ",
                     "<img src=\"Attack.jpg\" width=\"16\"> ",
                     keywords$text)
keywords$text = gsub("Recruit ",
                     "<img src=\"Recruit.jpg\" width=\"16\"> ",
                     keywords$text)
keywords$text = gsub("[Ranged]",
                     "<img src=\"blue.png\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[Strength]",
                     "<img src=\"green.png\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[Tech]",
                     "<img src=\"silver.png\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[Covert]",
                     "<img src=\"red.png\">",
                     keywords$text,
                     fixed=T)
keywords$text = gsub("[Instinct]",
                     "<img src=\"yellow.png\">",
                     keywords$text,
                     fixed=T)