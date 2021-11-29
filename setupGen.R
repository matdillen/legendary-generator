library(tidyverse)
library(magrittr)

#data import
heroes=read_csv2('data/heroes.csv')
schemes=read_csv2('data/schemes.csv')
villains=read_csv2('data/villains.csv')
henchmen=read_csv2('data/henchmen.csv')
masterminds=read_csv2('data/masterminds.csv')

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
setlist = read_csv("data/sets.csv")
setlist[1,] = list(""," ")
setaslist = as.list(t(setlist$id))
names(setaslist) = setlist$label

source("helpers.R")

setupPrint2 <- function(game,ts=F) {
  if (!ts) {
    setup = c(game$Scheme,
              paste(game$Mastermind,collapse=" - "),
              paste(game$Villains,collapse="|"),
              paste(game$Henchmen,collapse="|"),
              paste(game$Heroes,collapse="|"))
    if (!is.null(game$Extras)) {
      setup = c(setup,
                game$Extras)
    }
    write.table(t(setup),"clipboard",sep="\t",col.names = F,row.names = F)
  }
  if (ts) {
    setup = c(game$Scheme,
              game$scores$scheme$CT[1],
              game$scores$scheme$BSCt[1],
              game$scores$scheme$WndCT[1],
              paste(game$Mastermind,collapse=" - "),
              paste(game$Villains,collapse="|"),
              paste(game$Henchmen,collapse="|"),
              paste(game$Heroes,collapse="|"))
    if (!is.null(game$Extras)) {
      setup = c(setup,
                game$Extras)
    }
    return(paste(setup,collapse="\r\n"))
  }
}

games = tibble(id=seq(1,10000))
games$setup = NA
for (i in 1:10000) {
  game = genFun(src,
                playerc=2,
                epic=T,
                fixedMM="",
                fixedSCH="",
                fixedHM="",
                fixedHER=NULL,
                fixedVIL=NULL,
                fixedXtra="",
                dropset="",
                solo=T,
                xtra=NULL)
  games$setup[i] = setupPrint2(game,ts=T)
  if (i %% 100 == 0) {
    print(i)
  }
}

write_tsv(select(games,-id),"setups/10krandomgames.txt",na="")

text = "{"
for (i in 1:10000) {
  text = paste0(text,
                "[[",
                games$setup[i],
                "]]",
                ",\r\n")
}
#need to remove the last comma still!!!
text = paste0(text,"}")
writeClipboard(text)