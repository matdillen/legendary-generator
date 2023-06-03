library(tidyverse)
allg = readLines("objguids.txt")

all = tibble(guid = allg)

guidn = readLines("archive/guidnames.txt")

guidn2 = tibble(raw = guidn,
                guid = NA,
                name = NA)

tbl = ""
step = 0
for (i in 1:length(guidn)) {
  if (grepl("{",guidn[i],fixed=T)) {
    tbl = gsub("[^a-z|A-Z|_]","",guidn[i])
    step = 1
  } else if (grepl("}",guidn[i],fixed=T)) {
    tbl = ""
  } else if (tbl != "") {
    guidn2$guid[i] = gsub("\\[.*\\]","",guidn[i]) %>%
      str_extract("\".*\"") %>%
      gsub("\"","",.)
    id = str_extract(guidn[i],"\\[.*\\]")
    if (is.na(id)) {
      id = step
      step = step + 1
    }
    guidn2$name[i] = paste0(tbl,"--",id) %>%
      gsub("\"","",.)
  } else {
    guidn2$name[i] = gsub(" =.*","",guidn[i])
    guidn2$guid[i] = str_extract(guidn[i],"\".*\"") %>%
      gsub("\"","",.)
  }
}

guidn2 = guidn2 %>%
  filter(!is.na(guid))

all2 = left_join(all,guidn2,by=c("guid"="guid")) %>%
  select(-raw)

write_csv(all2,"obj_guids_info2.txt",na="")
