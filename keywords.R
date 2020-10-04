swd()
library(tidyverse)
library(textutils)

raw = readLines("https://marveldbg.wordpress.com/gameplay-mechanics/",encoding="UTF-8")
raw2 = raw[911:1769]
rawt = raw2[grep("<span style=\"color:#ff0000;",raw2,fixed=T)]
#rawt = rawt[-c(20,21)]
raw3 = raw2#[3:814]

rawt = tibble(rawt)
rawt$text = NA
rawt$name = NA
j = 0
text = ""
for (i in 1:length(raw3)) {
  if (grepl("<span style=\"color:#ff0000;",raw3[i],fixed=T)) {
    if (j!=0) {
      rawt$text[j] = text
      text = ""
    }
    j = j +1
    rawt$name[j] = raw3[i]
  } else {
    text = paste(text,raw3[i],sep="\n")
  }
  if (i==length(raw3)) {
    rawt$text[j] = text
  }
}
rawt = select(rawt,-rawt)
rawt$id = gsub("(<.*?>)","",rawt$name)

rawt$text[19] = paste0(rawt$text[19],
                       rawt$name[20],
                       rawt$name[21],
                       rawt$text[21])
rawt = rawt[-c(20,21),]

rawt$text = HTMLdecode(rawt$text)
rawt$name = HTMLdecode(rawt$name)
rawt$id = HTMLdecode(rawt$id)

rawt = rbind(c("","",""),rawt)
rawt$text = gsub("[Attack]",
                 "<img src=\"Attack.jpg\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[+Attack]",
                 "+<img src=\"Attack.jpg\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[Recruit]",
                 "<img src=\"Recruit.jpg\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[S.H.I.E.L.D.]",
                 "<img src=\"shield.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[HYDRA]",
                 "<img src=\"hydra.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[Instinct]",
                 "<img src=\"yellow.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[Ranged]",
                 "<img src=\"blue.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[Tech]",
                 "<img src=\"silver.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[Strength]",
                 "<img src=\"green.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[Covert]",
                 "<img src=\"red.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[INSTINCT]",
                 "<img src=\"yellow.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[RANGED]",
                 "<img src=\"blue.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[TECH]",
                 "<img src=\"silver.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
rawt$text = gsub("[STRENGTH]",
                 "<img src=\"green.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)
  rawt$text = gsub("[COVERT]",
                 "<img src=\"red.png\" width=\"16\">",
                 rawt$text,
                 fixed=T)


write_tsv(rawt,"keywords.txt")
