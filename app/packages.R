packages <- c("DT",
              "plyr",
              "tidyverse",
              "magrittr",
              "shiny",
              "shinyjs",
              "shinythemes",
              "shinyBS",
              "conflicted")

pkgLoad <- function() {
  
  packagecheck <- match( packages, utils::installed.packages()[,1])
  packagestoinstall <- packages[is.na(packagecheck)]
  
  if(length( packagestoinstall) > 0 ) {
    utils::install.packages(packagestoinstall)
  } else {
    print("All requested packages already installed")
  }
  
  for(package in packages) {
    suppressPackageStartupMessages(
      library(package,
              character.only = T,
              quietly = T))
  }
}