library(tidyverse)
library(jsonlite)
library(conflicted)
setwd("D:/Mathias/legendary/legendary-generator/lua-backup")

autodeploy = T

file = list.files("currentmod",
                  pattern="*.json",
                  full.names = T)
conflict_prefer("validate","jsonlite")
conflict_prefer("filter","dplyr")
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

tacticfiles = list.files("masterminds/tactics")
tactics = list()

for (i in 1:length(tacticfiles)) {
  tactics[[i]] = list()
  tacticscripts = list.files(paste0("masterminds/tactics/",
                                    tacticfiles[i]),
                             pattern = "*.lua",
                             full.names = T)
  for (j in 1:length(tacticscripts)) {
    tactics[[i]][[j]] = readLines(tacticscripts[j],warn = F)
  }
  names(tactics[[i]]) = tacticscripts %>%
    gsub(".*/","",.) %>%
    gsub("\\.lua","",.) %>%
    tolower()
}
names(tactics) = tacticfiles %>%
  tolower() %>%
  gsub("[^a-z]","",.)

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
    if (!is.null(tactics[[name]])) {
      for (j in 1:length(js$ObjectStates[[mm_id]]$ContainedObjects[[i]]$ContainedObjects)) {
        tname = tolower(js$ObjectStates[[mm_id]]$ContainedObjects[[i]]$ContainedObjects[[j]]$Nickname)
        if (!is.null(tactics[[name]][tname])) {
          js$ObjectStates[[mm_id]]$ContainedObjects[[i]]$ContainedObjects[[j]]$LuaScript =
            tactics[[name]][[tname]] %>%
            paste(.,collapse="\r\n")
        }
      }
      #print(i)
    }
  }
}

toexport = toJSON(js,
                  digits=NA,
                  pretty=T,
                  flatten=T,
                  auto_unbox=T)

filename = paste0(gsub("currentmod",
                       "output",
                       file[1]),
                  "_",
                  gsub("[[:punct:]]","",
                       Sys.time()),
                  ".json")

write(toexport,
      filename)

if (autodeploy) {
  tspath = paste0("C:/Users/mdill/Documents/My Games/",
                  "Tabletop Simulator/Saves/atom2/workingnewexp/")
  
  newname = paste0(tspath,
                   gsub("output/","",filename))
  
  file.copy(filename,
            newname)
  file.remove(paste0(tspath,gsub("currentmod/","",file)))
  file.rename(newname,
              gsub("json_.*","json",newname))
}