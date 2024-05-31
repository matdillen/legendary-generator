library(RInno)

setwd("app")

source("packages.R")

#fix bad R version numbers in two functions
#loads updated functions in current environment only

body(code_section)[[4]][[3]][[2]][[2]][[2]] <- substitute(
  stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/",
                                 warn = F), "[1-4]\\.[0-9]+\\.[0-9]+")
)
body(code_section)[[4]][[3]][[3]][[2]] <- substitute(
  stringr::str_extract(readLines("https://cran.rstudio.com/bin/windows/base/old/", 
                                 warn = F), "[1-4]\\.[0-9]+\\.[0-9]+")
)
body(get_R)[[4]][[3]][[2]][[2]][[3]] <- substitute(
  stringr::str_extract("[1-4]\\.[0-9]+\\.[0-9]+")
)
body(get_R)[[6]][[2]] <- substitute(
  latest_R_version[1] == R_version
)
body(get_R)[[5]][[3]][[2]][[3]] <- substitute(
  stringr::str_extract("[1-4]\\.[0-9]+\\.[0-9]+")
)

#set the app name
name = "LegendaryGenerator"

#copy installer default and required files to app's directory
copy_installation(overwrite=F)
file.remove("default.ico")
file.remove("setup.ico")

#download R installer if not already present in app's directory
get_R()

#create a BAT file that will launch the shiny app
create_bat(app_name = name,
           app_dir = getwd())

#create a config file for the app
create_config(app_name = name,
              pkgs = packages,
              pkgs_path = "bin",
              user_browser = "firefox")

#create an ISS file that declares how the installer should be built
start_iss(app_name = name) %>%
  
  # C-like directives
  directives_section(include_R = T,
                     app_version = "0.6",
                     publisher = "Mathias Dillen", 
                     main_url = "https://github.com/matdillen/legendary-generator") %>%
  
  # Setup Section
  setup_section(app_dir = getwd(),
                setup_icon  = "www/hydra.ico",
                dir_out = "RInno_installer",
                pub_url = "https://github.com/matdillen/legendary-generator", 
                sup_url = "https://github.com/matdillen/legendary-generator/issues",
                upd_url = "https://github.com/matdillen/legendary-generator",
                privilege = "lowest",
                info_before = "infobefore.txt",
                info_after = "infoafter.txt") %>%
  
  # Languages Section
  languages_section() %>%
  
  # Tasks Section
  tasks_section(desktop_icon = T) %>%
  
  # Files Section
  files_section(app_dir = getwd(),
                user_browser = "chrome") %>%
  
  # Icons Section
  icons_section(app_desc = paste0("The Legendary Generator app allows to brows",
                                  "e most cards of the Marvel Legendary game and",
                                  " generate setups compatible with a Tabletop",
                                  " Simulator mod."),
                app_dir = getwd(),
                app_icon = "www/hydra.ico",
                prog_menu_icon = T,
                desktop_icon   = T) %>%
  gsub("commonprograms","autoprograms",.) %>%
  gsub("commondesktop","autodesktop",.) %>%
  
  # Execution & Pascal code to check registry during installation
  # If the user has R, don't give them an extra copy
  # If the user needs R, give it to them
  run_section() %>%
  code_section() %>%
  
  # Write the Inno Setup script
  writeLines(paste0(name,".iss"))

#read it back to fix a few issues
issfile = readLines("LegendaryGenerator.iss")

#exclude any card images from the installer (otherwise it grows into >1GB)
issfile = issfile[-grep("www/img",issfile)]

#add the sizeinfo.txt file which gets cut due to some loose regex in
#the files_section()
ln = grep("[Icons]",issfile,fixed=T)-2
issfile1 = issfile[1:ln]
issfile2 = issfile[(ln+1):length(issfile)]
issfile1 = c(issfile1,
             "Source: \"data/sizeinfo.txt\"; DestDir: \"{app}\\data\"; Flags: ignoreversion;",
             "")
issfile = c(issfile1,
            issfile2)
writeLines(issfile,"LegendaryGenerator.iss")

#bizarre error when run from .bat

#compile the installer based on the ISS file
compile_iss()
