library(tidyverse)
#set main app directory
a=read_csv2("support/imgmap.csv")

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

a$loc = urlGen(a$url)

if (!dir.exists("www/img")) {
  dir.create("www/img")
}

for (i in 1:dim(a)[1]) {
  download.file(a$loc[i],paste0("www/img/",a$file[i]),mode="wb")
}
