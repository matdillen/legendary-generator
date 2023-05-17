library(stringr)
tc = readLines("archive/tocutup2.txt")

scheme_base = readLines("archive/mm_base.lua")
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
