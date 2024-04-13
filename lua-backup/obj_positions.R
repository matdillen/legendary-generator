library(tidyverse)
library(jsonlite)
library(magrittr)
library(conflicted)
setwd("D:/Mathias/legendary/legendary-generator/lua-backup")

file = list.files("currentmod",
                  pattern="*.json",
                  full.names = T)
conflict_prefer("validate","jsonlite")
conflict_prefer("filter","dplyr")
js = fromJSON(file[1],
              simplifyVector = F)

get_pos <- function(data,guids=NULL) {
  pos = tibble(guid="init",posX=0,posY=0,posZ=0)
  for (i in 1:length(data$ObjectStates)) {
    if (!is.null(data$ObjectStates[[i]]$Transform)) {
      if (is.null(guids)|data$ObjectStates[[i]]$GUID%in%guids) {
        pos = rbind(pos,tibble(guid=data$ObjectStates[[i]]$GUID,
                               posX=data$ObjectStates[[i]]$Transform$posX,
                               posY=data$ObjectStates[[i]]$Transform$posY,
                               posZ=data$ObjectStates[[i]]$Transform$posZ))
      }
    }
  }
  return(pos[-1,])
}
allp = get_pos(js)

info = read_csv("obj_guids_info.txt")
allp %<>%
  left_join(select(info,guid,name),by=c("guid"="guid")) %>%
  filter(!duplicated(guid))

write_tsv(allp,"obj_positions.txt")

update_pos <- function(data,newpos) {
  for (i in 1:length(data$ObjectStates)) {
    if (!is.null(data$ObjectStates[[i]]$Transform)) {
      temp = filter(newpos,guid == data$ObjectStates[[i]]$GUID)
      if (dim(temp)[1]==1) {
        data$ObjectStates[[i]]$Transform$posX = as.numeric(temp$posX[1])
        data$ObjectStates[[i]]$Transform$posY = as.numeric(temp$posY[1])
        data$ObjectStates[[i]]$Transform$posZ = as.numeric(temp$posZ[1])
      }
    }
  }
  return(data)
}

new_pos = read_tsv("obj_positions.txt",col_types = cols(.default = "c"))

js2 = update_pos(js,new_pos)

toexport = toJSON(js2,
                  digits=NA,
                  pretty=T,
                  flatten=T,
                  auto_unbox=T)
write(toexport,
      paste0(gsub("currentmod",
                  "output",
                  file[1]),
             "_",
             gsub("[[:punct:]]","",
                  Sys.time()),
             ".json"))
