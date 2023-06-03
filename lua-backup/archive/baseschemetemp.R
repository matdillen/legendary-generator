library(tidyverse)
library(jsonlite)
tc = readLines("archive/tocutup2.txt")

scheme_base = readLines("archive/vil_base.lua")
scheme_base = paste(scheme_base,collapse = "\n")

filename = ""
scrip = ""
for (i in 1:length(tc)) {
  if (grepl("if mmname == ",tc[i],fixed=T)) {
    if (filename != "") {
      scrip = sub("\nend$","",scrip)
      scrip = gsub("\n    ","\n",scrip)
      scrip = paste(scheme_base,scrip,sep="\n")
      writeLines(scrip,paste0("masterminds/",filename,".lua"))
    }
    scrip = ""
    filename = str_extract(tc[i],"\".*\"") %>%
      gsub("\"","",.)
  } else {
    scrip = paste(scrip,tc[i],sep="\n")
  }
}

file = list.files("currentmod",
                  pattern="*.json",
                  full.names = T)

js = fromJSON(file[1],
              simplifyVector = F)

info = read_csv("obj_guids_info.txt") %>%
  filter(!duplicated(guid))

for (i in 45:length(js$ObjectStates[[13]]$ContainedObjects)) {
  name = js$ObjectStates[[13]]$ContainedObjects[[i]]$Nickname %>%
    gsub("\"","",.)
  thedir = paste0("villains/",
                  name)
  if (!dir.exists(thedir)) {
    dir.create(thedir)
  }
  for (j in 1:length(js$ObjectStates[[13]]$ContainedObjects[[i]]$ContainedObjects)) {
    lname = js$ObjectStates[[13]]$ContainedObjects[[i]]$ContainedObjects[[j]]$Nickname %>%
      gsub("\"","",.)
    if (!file.exists(paste0("villains/",
                           lname))) {
      writeLines(scheme_base,paste0(thedir,
                                    "/",
                                    lname,
                                    ".lua"))
    }
  }
}
