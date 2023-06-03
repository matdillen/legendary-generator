library(tidyverse)
library(jsonlite)
setwd("D:/Mathias/legendary/legendary-generator/lua-backup")

file = list.files("currentmod",
                  pattern="*.json",
                  full.names = T)

js = fromJSON(file[1],
              simplifyVector = F)

# for (i in 1:length(js$ObjectStates)) {
#   if (i == 1) {
#     allg = js$ObjectStates[[i]]$GUID
#   } else {
#     allg = c(allg,js$ObjectStates[[i]]$GUID)
#   }
# }

info = read_csv("obj_guids_info.txt") %>%
  filter(!duplicated(guid))

#add object scripts
for (i in 1:length(js$ObjectStates)) {
  if (!is.na(info$scripting[i])) {
    scrip = readLines(info$scripting[i]) %>%
      paste(.,collapse="\r\n")
    js$ObjectStates[[i]]$LuaScript = scrip
  }
}

#add global script
scrip = readLines("global.lua") %>%
  paste(.,collapse="\r\n")
js$LuaScript = scrip

#schemes scripts
luas = list.files("schemes",
                  all.files=T,
                  pattern=".lua")
lual = list()

scheme_id = grep("schemePileGUID",info$name)

for (i in 1:length(luas)) {
  lual[[i]] = readLines(paste0("schemes/",luas[i]))
}

luas = luas %>%
  tolower() %>%
  gsub(".lua","",.,fixed=T) %>%
  gsub("[^a-z]","",.)
names(lual) = luas

for (i in 1:length(js$ObjectStates[[scheme_id]]$ContainedObjects)) {
  name = js$ObjectStates[[scheme_id]]$ContainedObjects[[i]]$Nickname %>%
    tolower() %>%
    gsub("[^a-z]","",.)
  
  if (!is.null(lual[[name]])) {
    js$ObjectStates[[scheme_id]]$ContainedObjects[[i]]$LuaScript = 
      paste(lual[[name]],
            collapse="\r\n")
  }
}

#mm

luam = list.files("masterminds",
                  all.files = T,
                  pattern=".lua")
lual = list()
mm_id = grep("mmPileGUID",info$name)

for (i in 1:length(luam)) {
  lual[[i]] = readLines(paste0("masterminds/",luam[i]))
}

luam = luam %>%
  tolower() %>%
  gsub(".lua","",.,fixed=T) %>%
  gsub("[^a-z]","",.)
names(lual) = luam

for (i in 1:length(js$ObjectStates[[mm_id]]$ContainedObjects)) {
  name = js$ObjectStates[[mm_id]]$ContainedObjects[[i]]$Nickname %>%
    tolower() %>%
    gsub("[^a-z]","",.)
  
  if (!is.null(lual[[name]])) {
    js$ObjectStates[[mm_id]]$ContainedObjects[[i]]$LuaScript = 
      paste(lual[[name]],
            collapse="\r\n")
  }
}

toexport = toJSON(js,
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