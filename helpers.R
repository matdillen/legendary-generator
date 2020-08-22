genFun = function(src,
                  playerc=2,
                  epic=F,
                  fixedMM="",
                  fixedSCH="",
                  fixedHM="",
                  fixedHER="",
                  fixedVIL="",
                  dropset="",
                  solo=T) {
  
  
  #setup numbers depending on number of players
  heroesc = 0
  xtra = NULL
  if (playerc==2) {
    heroesc=5
    villainc=2
    henchc=1
    bystc=2
  }
  if (playerc==3) {
    heroesc=5
    villainc=3
    henchc=1
    bystc=8
  }
  if (playerc==4) {
    heroesc=5
    villainc=3
    henchc=2
    bystc=8
  }
  if (playerc==5) {
    heroesc=6
    villainc=4
    henchc=2
    bystc=12
  }
  if (epic==T) {
    epic = sample(0:1,1) #0 is still not epic!
  }
  if (heroesc==0) {
    stop("invalid player count")
  }
  
  
  ##############################################################
  ##Generate a scheme
  src$schemes %<>% filter(!Set%in%dropset)
  
  if (solo) {
    src$schemes %<>% filter(is.na(solobad))
  }
  
  #Fixed scheme given?
  if (fixedSCH!="") {
    scheme = fixedSCH
  }
  
  #Random scheme if not given or not found
  if (fixedSCH=="") {
    schnumber = sample(1:nrow(src$schemes),1)
    scheme = src$schemes$Name[schnumber]
  }
  
  #save name and scores
  schemtraits = filter(src$schemes,Name==scheme)
  
  #set NA's to 0 (can be important for metrics)
  schemtraits[is.na(schemtraits)]=0
  
  convertVarstats <- function(value,pc) {
    if (grepl(":",
              value,
              fixed=T)) {
      schemeset = strsplit(value,
                           split=":|;")
      schemeset_nrs = tibble(playerc=seq(1,(length(schemeset[[1]])/2)),
                             n=seq(1,(length(schemeset[[1]])/2)))
      j=0
      for (i in 1:dim(schemeset_nrs)[1]) {
        j = j + 1
        schemeset_nrs$playerc[i] = as.numeric(schemeset[[1]][j])
        schemeset_nrs$n[i] = schemeset[[1]][j+1]
        j = j + 1
      }
      schemeset_nrs %<>% filter(playerc<=pc)
      if (dim(schemeset_nrs)[1]==1) {
        value=schemeset_nrs$n[1]
      }
      if (dim(schemeset_nrs)[1]>1) {
        value=schemeset_nrs$n[schemeset_nrs$playerc==max(schemeset_nrs$playerc)]
      }
    }
    return(value)
  }
  
  #playerc dependent scheme settings:
  schemtraits$HC[1] %<>% convertVarstats(playerc)
  schemtraits$VC[1] %<>% convertVarstats(playerc)
  schemtraits$CH[1] %<>% convertVarstats(playerc)
  schemtraits$CT[1] %<>% convertVarstats(playerc)
  
  #modify card numbers according to scheme
  heroesc = heroesc + as.numeric(schemtraits$HC[1])
  villainc = villainc + as.numeric(schemtraits$VC[1])
  henchc = henchc + as.numeric(schemtraits$CH[1])
  
  #calculate woundcount
  if (grepl("*",
            schemtraits$WndCT[1],
            fixed=T)) {
    schemtraits$WndCT[1] = gsub("*",
                 "",
                 schemtraits$WndCT[1],
                 fixed=T)
    schemtraits$WndCT[1] = as.numeric(schemtraits$WndCT[1])*playerc
  }
  
  #calculate bystandercount
  if (schemtraits$BSCt[1]!=0) {
    bystc = schemtraits$BSCt[1]
  }
  if (schemtraits$BSCt[1]=="x") {
    bystc = 0
  }
  schemtraits$BSCt[1] = bystc
  
  #modify picklists based on scheme
  if (scheme=="Cage Villains in Power-Suppressing Cells") {
    src$henchmen %<>% filter(Name!="Cops")
  }
  
  if (scheme=="Clash of the Monsters Unleashed") {
    src$villains %<>% filter(Group!="Monsters Unleashed")
  }
  
  if (scheme=="Crown Thor King of Asgard") {
    src$villains %<>% filter(Group!="Avengers")
  }
  
  if (scheme=="Cytoplasm Spike Invasion") {
    src$henchmen %<>% filter(Name!="Cytoplasm Spikes")
  }
  
  if (scheme=="House of M") {
    src$heroes %<>% filter(Hero!="Scarlet Witch")
  }
  
  if (scheme=="The Dark Phoenix Saga"|
      scheme=="Transform Citizens Into Demons") {
    src$heroes %<>% filter(Hero!="Jean Grey")
  }
  if (scheme=="Hidden Heart of Darkness") {
    adapters = c("Hydra Super-Adaptoid",
                 "Hydra High Council")
    src$masterminds %<>% 
      filter(!MM%in%adapters,
             !Name%in%adapters)
  }
  
  ##############################################################
  ##Generate a mastermind
  
  #Only list the individual masterminds
  #not tactics (with a MM value), not epic versions, not transformed versions (T)
  mmlist=filter(src$masterminds,
                is.na(MM),
                is.na(Epic),
                is.na(T),
                !Set%in%dropset)
  
  #Fixed mm given?
  if (fixedMM!="") {
    mm = fixedMM
  }
  
  #Random mm
  if (fixedMM=="") {
    mmnumber = sample(1:nrow(mmlist),1)
    mm = mmlist$Name[mmnumber]
  }
  
  #save name and scores
  mmtraits = filter(src$masterminds,
                    MM==mm|
                      Name==mm)
  
  #set NA's to 0 (can be important for metrics)
  mmtraits[is.na(mmtraits)]=0
  
  #modify the scores for epic or not; add epic label to mm name
  if (epic!=1) {
    mmtraits = filter(mmtraits,Epic==0)
  }
  if (epic==1&
      mmtraits$Epic[2]==1) {
    mmtraits = filter(mmtraits,
                      Epic==1|
                        MM!=0)
    mm = c(mm,"epic")
  }
  
  if (scheme=="Master of Tyrants"|
      scheme=="World War Hulk") {
    mmlist %<>% filter(Name!=mm)
    mmnumber = sample(1:nrow(mmlist),3,replace=F)
    xtra = paste(mmlist$Name[mmnumber],collapse="|")
  }
  
  ##############################################################
  ##Generate villain groups
  src$villains %<>% filter(!Set%in%dropset)
  villist=distinct(src$villains,Group) #check on group, not individual card
  
  #Villain group required by scheme?
  if (schemtraits$Vill_Inc[1]!=0) {
    if (grepl(";",schemtraits$Vill_Inc[1])) {
      villnames = strsplit(schemtraits$Vill_Inc[1],split=";")[[1]]
    } else if (grepl("|",schemtraits$Vill_Inc[1],fixed=T)) {
      pick = sample(0:1,1) + 1
      villnames = strsplit(schemtraits$Vill_Inc[1],split="|",fixed=T)[[1]][pick]
    } else {
      villnames = schemtraits$Vill_Inc[1]
    }
  } else {
      villnames = NULL
  }
  
  if (scheme=="S.H.I.E.L.D. vs. HYDRA War") {
    pick = sample(0:1,1) + 1
    hydra = c("Hydra Elite","A.I.M. Hydra Offshoot")
    villnames = hydra[pick]
    villist %<>% filter(!Group%in%hydra)
  }
  if (scheme=="Symbiotic Absorption") {
    mmlist %<>% filter(Name!=mm[1])
    mmnumber = sample(1:nrow(mmlist),1)
    xtra = mmlist$Name[mmnumber]
    villnames = filter(src$masterminds,Name==xtra)$LeadsV[1]
    if (is.na(villnames)) {
      villnames = filter(src$masterminds,Name==xtra)$LeadsH[1]
    }
  }
  
  #Villain group required by mm?
  if (mmtraits$LeadsV[1]!=0) {
    villnames = c(villnames,mmtraits$LeadsV[1])
  }
  
  #fixed villain groups given as function argument?
  villnames = c(villnames,fixedVIL)
  villnames = villnames[!duplicated(villnames)]
  
  #random villain groups
  if (length(villnames)<villainc) {
    villainc2 = villainc - length(villnames)
    villist = filter(villist,!Group%in%villnames)
    vil=sample(1:nrow(villist),villainc2,replace=F)
    villnames = c(villnames,villist$Group[vil])
  }
  if (length(villnames)>villainc) {
    villnames = villnames[1:villainc]
  }
  #save scores
  viltraits = filter(src$villains,Group%in%villnames)
  viltraits[is.na(viltraits)]=0
  
  
  ##############################################################
  ##Generate henchmen groups
  #only distinct group names due to the Mandarin and his rings
  src$henchmen %<>% filter(!Set%in%dropset)
  hmlist=distinct(src$henchmen,Name)
  
  if (schemtraits$HM_Inc[1]!=0) {
    henchnames = schemtraits$HM_Inc[1]
  }
  else {
    henchnames = NULL
  }
  
  if (mmtraits$LeadsH[1]!=0) {
    henchnames = c(henchnames,mmtraits$LeadsH[1])
  }
  
  if (fixedHM=="") {
    fixedHM = NULL
  }
  
  if (mm[1]=="Deathbird") {
    shiar = c("Shi'ar Death Commandos",
              "Shi'ar Patrol Craft")
    pick = sample(0:1,1) + 1
    henchnames = c(henchnames,
                   shiar[pick])
  }
  
  henchnames = c(henchnames,fixedHM)
  henchnames = henchnames[!duplicated(henchnames)]
  
  if (length(henchnames)<henchc) {
    henchc2 = henchc - length(henchnames)
    hmlist = filter(hmlist,!Name%in%henchnames)
    hench=sample(1:nrow(hmlist),henchc2,replace=F)
    henchnames = c(henchnames,hmlist$Name[hench])
  }
  if (length(henchnames)>henchc) {
    henchnames = henchnames[1:henchc]
  }


  henchtraits = filter(src$henchmen,Name%in%henchnames)
  henchtraits[is.na(henchtraits)]=0
  
  if (scheme=="Build an Army of Annihilation"|
      scheme=="Invade the Daily Bugle News HQ") {
    hmlist %<>% filter(!Name%in%henchnames)
    hench = sample(1:nrow(hmlist),1)
    xtra = hmlist$Name[hench]
  }
  if (scheme=="Scavenge Alien Weaponry") {
    hench = sample(1:length(henchnames),1)
    xtra = henchnames[hench]
  }
  
  
  ##############################################################
  ##Generate heroes
  heronames = NULL
  
  src$heroes %<>% filter(!Set%in%dropset)
  src$heroes$uni = paste0(src$heroes$Hero," (",src$heroes$Set,")")
  
  #A few schemes have such specific needs their hero requirements are hardcoded here separately
  if (scheme=="Avengers vs. X-Men") {
    teamlist = count(src$heroes,Team)
    teamlist %<>% filter(n>12)
    teamlist %<>% sample_n(2)
    src$heroes %<>% filter(Team%in%teamlist$Team)
    herolist1 = distinct(filter(src$heroes,Team==teamlist$Team[1]),uni)
    herolist2 = distinct(filter(src$heroes,Team==teamlist$Team[2]),uni)
    heronumber1 = sample(1:nrow(herolist1),3,replace=F)
    heronumber2 = sample(1:nrow(herolist2),3,replace=F)
    heroid1 = herolist1$uni[heronumber1]
    heroid2 = herolist2$uni[heronumber2]
    heronames = c(heroid1,heroid2)
    heroesc = 6
  }
  if (scheme=="House of M") {
    herolist1 = distinct(filter(src$heroes,Team=="X-Men"),uni)
    herolist2 = distinct(filter(src$heroes,Team!="X-Men"),uni)
    heronumber1 = sample(1:nrow(herolist1),4,replace=F)
    heronumber2 = sample(1:nrow(herolist2),2,replace=F)
    heroid1 = herolist1$uni[heronumber1]
    heroid2 = herolist2$uni[heronumber2]
    heronames = c(heroid1,heroid2)
    heroesc = 6
  }
  if (scheme=="Distract the Hero") {
    herolist = distinct(filter(src$heroes,Team=="Spidermen"),uni)
    heronumber = sample(1:nrow(herolist),1)
    heronames = herolist$uni[heronumber]
  }
  if (scheme=="Everybody Hates Deadpool") {
    herolist = distinct(filter(src$heroes,Team=="Deadpool"),uni)
    heronumber = sample(1:nrow(herolist),1)
    heronames = herolist$uni[heronumber]
  }
  
  #hero required by scheme?
  if (schemtraits$Hero_Inc[1]!=0) {
    if (grepl(";",schemtraits$Hero_Inc[1])) {
      heroincs = strsplit(schemtraits$Hero_Inc[1],split=";")[[1]]
      fixn = 2
    } else if (grepl("|",schemtraits$Hero_Inc[1],fixed=T)) {
      pick = sample(0:1,1) + 1
      heroincs = strsplit(schemtraits$Hero_Inc[1],split="|",fixed=T)[[1]][pick]
      fixn = 1
    } else {
      heroincs = schemtraits$Hero_Inc[1]
      fixn = 1
    }
    herolist = filter(src$heroes,
                      Name_S%in%heroincs)
    herolist = distinct(herolist,uni)
    heroid = sample(1:nrow(herolist),fixn,replace=F)
    heronames = herolist$uni[heroid]
  }
  
  #join both the scheme hero and the fixed provided (if any)
  heronames = c(heronames,fixedHER)
  
  #disambiguate names by concatening set id
  herolist = distinct(src$heroes,uni)
  
  if (length(heronames)<heroesc) {
    heroesc2 = heroesc - length(heronames)
    herolist = filter(herolist,!uni%in%heronames)
    heroid=sample(1:nrow(herolist),heroesc2,replace=F)
    heronames = c(heronames,herolist$uni[heroid])
  }
  if (length(heronames)>heroesc) {
    heronames = heronames[1:heroesc]
  }
  
  #extra heroes for scheme purposes (not in hero deck)
  if (scheme=="Mutating Gamma Rays"|
      scheme=="Shoot Hulk into Space") {
    herolist = distinct(filter(src$heroes,
                               Name_S=="Hulk",
                               !uni%in%heronames),uni)
    heronumber = sample(1:nrow(herolist),1)
    xtra = herolist$uni[heronumber]
  }

  if (scheme%in%c("Secret Empire of Betrayal",
                  "The Mark of Khonshu",
                  "Trap Heroes in the Microverse",
                  "X-Cutioner's Song")) {
    herolist = distinct(filter(src$heroes,
                               !uni%in%heronames),uni)
    heronumber = sample(1:nrow(herolist),1)
    xtra = herolist$uni[heronumber]
  }
  
  #save scores
  herotraits = filter(src$heroes,uni%in%heronames)
  herotraits[is.na(herotraits)]=0
  
  
  #list sets
  sets = c(filter(herotraits,!duplicated(uni))$Set,
           schemtraits$Set,
           mmtraits$Set[1],
           filter(viltraits,!duplicated(Group))$Set,
           filter(henchtraits,!duplicated(Name))$Set)
  
  ##Print out results
  resu = list(
    scheme,
    mm,
    villnames,
    henchnames,
    heronames,
    xtra,
    list(schemtraits,mmtraits,viltraits,henchtraits,herotraits),
    sets)
  names(resu) = c("Scheme",
                  "Mastermind",
                  "Villains",
                  "Henchmen",
                  "Heroes",
                  "Extras",
                  "scores",
                  "sets")
  names(resu$scores) = c("scheme",
                         "mastermind",
                         "villains",
                         "henchmen",
                         "heroes")
  return(resu)
}

setupSumm <- function(game,setupid) {
  require(data.table)
  setup = c(game$Scheme,
            paste(game$Mastermind,collapse=" - "),
            "<br>",
            game$Villains,
            "<br>",
            game$Henchmen,
            "<br",
            game$Heroes)
  if (!is.null(game$Extras)) {
    setup = c(setup,
              "<br>",
              game$Extras)
  }
  setup = data.frame(data=setup)
                     
  colnames(setup) = paste0("Setup ",setupid)
  #setup = as.data.table(setup,keep.rownames=T)
  return(setup)
}

setupPrint <- function(game,ts=F) {
  if (!ts) {
    setup = c(game$Scheme,
              paste(game$Mastermind,collapse=" - "),
              paste(game$Villains,collapse="|"),
              paste(game$Henchmen,collapse="|"),
              paste(game$Heroes,collapse="|"))
    if (!is.null(game$Extras)) {
      setup = c(setup,
                game$Extras)
    }
    write.table(t(setup),"clipboard",sep="\t",col.names = F,row.names = F)
  }
  if (ts) {
    setup = c(game$Scheme,
              game$scores$scheme$CT[1],
              game$scores$scheme$BSCt[1],
              game$scores$scheme$WndCT[1],
              paste(game$Mastermind[1]),
              paste(game$Villains,collapse="|"),
              paste(game$Henchmen,collapse="|"),
              paste0(paste(game$Heroes,collapse="|"),"|"))
    if (!is.null(game$Extras)) {
      setup = c(setup,
                game$Extras,
                "empty")
    }
    writeClipboard(paste(setup,collapse="\n"))
  }
}

metricsGen = function(games,nr) {
  
  #games is a list of generated setups
  #nr is the element of that list to calculate metrics for
  
  #initialize metrics df
  metrics = c("bCount",
              "bReq",
              "rCount",
              "rReq",
              "yReq",
              "yCount",
              "sReq",
              "sCount",
              "gReq",
              "gCount")
  metrics = t(metrics)
  colnames(metrics) = metrics[1,]
  metrics[1,] = 0
  metrics = as_tibble(metrics)
  
  ##colorcounts
  #issue if t or split cards with the same color
  #does not take into account villains gained as heroes
  metrics$bCount = 
    sum(games[[nr]]$scores$heroes$B*
          games[[nr]]$scores$heroes$Ct)
  metrics$rCount = 
    sum(games[[nr]]$scores$heroes$R*
          games[[nr]]$scores$heroes$Ct)
  metrics$yCount = 
    sum(games[[nr]]$scores$heroes$Y*
          games[[nr]]$scores$heroes$Ct)
  metrics$gCount = 
    sum(games[[nr]]$scores$heroes$G*
          games[[nr]]$scores$heroes$Ct)
  metrics$sCount = 
    sum(games[[nr]]$scores$heroes$S*
          games[[nr]]$scores$heroes$Ct)
  
  ##count color requirements of heroes, villains, mm and scheme
  #does not differentiate right now for epic, so slight inflation possible
  #might also consider ignoring if both sides of transforming mm care about a certain color
  metrics$bReq = 
    sum(games[[nr]]$scores$heroes$Br*
          games[[nr]]$scores$heroes$Ct) +
    sum(games[[nr]]$scores$villains$B*
          games[[nr]]$scores$villains$Ct) +
    sum(games[[nr]]$scores$mastermind$B) +
    games[[nr]]$scores$scheme$B
  metrics$rReq = 
    sum(games[[nr]]$scores$heroes$Rr*
          games[[nr]]$scores$heroes$Ct) +
    sum(games[[nr]]$scores$villains$R*
          games[[nr]]$scores$villains$Ct) +
    sum(games[[nr]]$scores$mastermind$R) +
    games[[nr]]$scores$scheme$R
  metrics$yReq = 
    sum(games[[nr]]$scores$heroes$Yr*
          games[[nr]]$scores$heroes$Ct) +
    sum(games[[nr]]$scores$villains$Y*
          games[[nr]]$scores$villains$Ct) +
    sum(games[[nr]]$scores$mastermind$Y) +
    games[[nr]]$scores$scheme$Y
  metrics$gReq = 
    sum(games[[nr]]$scores$heroes$Gr*
          games[[nr]]$scores$heroes$Ct) +
    sum(games[[nr]]$scores$villains$G*
          games[[nr]]$scores$villains$Ct) +
    sum(games[[nr]]$scores$mastermind$G) +
    games[[nr]]$scores$scheme$G
  metrics$sReq = 
    sum(games[[nr]]$scores$heroes$Sr*
          games[[nr]]$scores$heroes$Ct) +
    sum(games[[nr]]$scores$villains$S*
          games[[nr]]$scores$villains$Ct) +
    sum(games[[nr]]$scores$mastermind$S) +
    games[[nr]]$scores$scheme$S
  
  ###cost requirements
  #C2 and C4
  metrics$C2r = sum(games[[nr]]$scores$heroes$C2*
                      games[[nr]]$scores$heroes$Ct)
  metrics$C2 = sum(filter(games[[nr]]$scores$heroes,C==2)$Ct)
  metrics$C2Def = metrics$C2 - metrics$C2r
  
  metrics$C4r = sum(games[[nr]]$scores$heroes$C4*
                      games[[nr]]$scores$heroes$Ct)
  metrics$C4 = sum(filter(games[[nr]]$scores$heroes,C==4)$Ct)
  metrics$C4Def = metrics$C4 - metrics$C4r
  
  ##cost diversity
  metrics$Cdivr = sum(games[[nr]]$scores$heroes$CD*
                        games[[nr]]$scores$heroes$Ct)
  cost_div = games[[nr]]$scores$heroes %>%
    group_by(C) %>%
    summarize(sum = sum(Ct))
  #using fractions for Shannon and evenness calculations
  cost_div$p = cost_div$sum/sum(cost_div$sum)
  metrics$Cdiv = -sum(cost_div$p*log(cost_div$p))
  metrics$CdivEV = round(metrics$Cdiv/log(dim(cost_div)[1]),2)
  
  ##spectrum
  metrics$colorDIVr = sum(games[[nr]]$scores$heroes$SP*
                            games[[nr]]$scores$heroes$Ct)
  colors = c("B","R","Y","G","S")
  n = unlist(metrics[1:5])
  color_div = tibble(colors,n)
  color_div$p = color_div$n/sum(color_div$n)
  metrics$colorDIV = -sum(color_div$p*log(color_div$p))
  metrics$colorEV = round(metrics$colorDIV/log(dim(color_div)[1]),2)
  
  ##Wounds
  metrics$wndsum = sum(games[[nr]]$scores$heroes$Wd*
                         games[[nr]]$scores$heroes$Ct) + 
    sum(games[[nr]]$scores$villains$Wnd*
          games[[nr]]$scores$villains$Ct) +
    games[[nr]]$scores$scheme$Wnd*games[[nr]]$scores$scheme$CT
  
  if (dim(games[[nr]]$scores$mastermind)[1]==5) {
    metrics$wndsum = metrics$wndsum +
      games[[nr]]$scores$mastermind$Wnd[1]*5 +
      sum(games[[nr]]$scores$mastermind$Wnd[2:5])
  }
  if (dim(games[[nr]]$scores$mastermind)[1]==6) {
    metrics$wndsum = metrics$wndsum +
      games[[nr]]$scores$mastermind$Wnd[1]*2.5 +
      games[[nr]]$scores$mastermind$Wnd[2]*2.5 +
      sum(games[[nr]]$scores$mastermind$Wnd[3:6])
  }
  
  ##KO heroes
  games[[nr]]$scores$heroes$KOng = 0
  games[[nr]]$scores$heroes$KOng[games[[nr]]$scores$heroes$KO==2] = 1
  
  games[[nr]]$scores$villains$KOng = 0
  games[[nr]]$scores$villains$KOng[games[[nr]]$scores$villains$KOH==2] = 1
  
  metrics$kohsum = sum(games[[nr]]$scores$heroes$KOng*
                         games[[nr]]$scores$heroes$Ct) + 
    sum(games[[nr]]$scores$villains$KOng*
          games[[nr]]$scores$villains$Ct) +
    games[[nr]]$scores$scheme$KOH*games[[nr]]$scores$scheme$CT
  
  if (dim(games[[nr]]$scores$mastermind)[1]==5) {
    metrics$kohsum = metrics$kohsum +
      games[[nr]]$scores$mastermind$KOH[1]*5 +
      sum(games[[nr]]$scores$mastermind$KOH[2:5])
  }
  if (dim(games[[nr]]$scores$mastermind)[1]==6) {
    metrics$kohsum = metrics$kohsum +
      games[[nr]]$scores$mastermind$KOH[1]*2.5 +
      games[[nr]]$scores$mastermind$KOH[2]*2.5 +
      sum(games[[nr]]$scores$mastermind$KOH[3:6])
  }
  
  ##crowding
  metrics$crwdsum = sum(games[[nr]]$scores$villains$CRWD*
                          games[[nr]]$scores$villains$Ct) +
    games[[nr]]$scores$scheme$CRWD*games[[nr]]$scores$scheme$CT
  
  if (dim(games[[nr]]$scores$mastermind)[1]==5) {
    metrics$crwdsum = metrics$crwdsum +
      games[[nr]]$scores$mastermind$CRWD[1]*5 +
      sum(games[[nr]]$scores$mastermind$CRWD[2:5])
  }
  if (dim(games[[nr]]$scores$mastermind)[1]==6) {
    metrics$crwdsum = metrics$crwdsum +
      games[[nr]]$scores$mastermind$CRWD[1]*2.5 +
      games[[nr]]$scores$mastermind$CRWD[2]*2.5 +
      sum(games[[nr]]$scores$mastermind$CRWD[3:6])
  }
  
  ##hencko
  #metrics$hencko = sum(games[[nr]]$scores$henchmen$KO_HERO)
  
  ##wincon
  metrics$wincon = games[[nr]]$scores$scheme$EW
  metrics$wincon = plyr::revalue(metrics$wincon,c(
    "VE" = "Villains Escaped",
    "SE" = paste0(games[[nr]]$scores$scheme$EWH," escaped"),
    "WO" = "Wound stack runs out",
    "LT" = "Last or second to last twist",
    "HK" = "Heroes KO'd",
    "O"= "Other"),warn_missing = F)
  
  #MoFi
  metrics$MoFir = sum(games[[nr]]$scores$heroes$MF)
  metrics$MoFi = sum(filter(games[[nr]]$scores$heroes,MO==1,FI==1)$Ct)
  metrics$MoFiDef = metrics$MoFi - metrics$MoFir
  
  #NoRu
  metrics$NoRur = sum(filter(games[[nr]]$scores$heroes,NR==-1)$Ct)
  metrics$NoRu = sum(filter(games[[nr]]$scores$heroes,NR==1)$Ct)
  metrics$NoRuDef = metrics$NoRu - metrics$NoRur
  
  #Lightshow
  metrics$Lightshow = sum(filter(games[[nr]]$scores$heroes,LS!=0)$Ct*filter(games[[nr]]$scores$heroes,LS!=0)$LS)
  metrics$Lightshowr = sum(filter(games[[nr]]$scores$heroes,LS!=0)$Ct)/sum(games[[nr]]$scores$heroes$Ct)
  metrics$LightshowDef = metrics$Lightshow - metrics$Lightshowr
  
  metrics$bDef = metrics$bCount - metrics$bReq
  metrics$rDef = metrics$rCount - metrics$rReq
  metrics$gDef = metrics$gCount - metrics$gReq
  metrics$yDef = metrics$yCount - metrics$yReq
  metrics$sDef = metrics$sCount - metrics$sReq
  return(metrics)
}

metricsPrint <- function(metrics) {
  wincon = metrics$wincon
  metrics %<>% select(-Lightshow,
                      -Lightshowr,
                      -NoRur,
                      -NoRu,
                      -MoFi,
                      -MoFir,
                      -C2,
                      -C2r,
                      -C4,
                      -C4r,
                      -Cdiv,
                      -colorDIV,
                      -bCount,
                      -bReq,
                      -rReq,
                      -rCount,
                      -gReq,
                      -gCount,
                      -sReq,
                      -sCount,
                      -yReq,
                      -yCount,
                      -wincon)
  metrics %<>% 
    rename(`Wound Indicator` = wndsum,
           `<font color=\"blue\">Blue Deficit</font>` = bDef,
           `<font color=\"red\">Red Deficit</font>` = rDef,
           `<font color=\"yellow\">Yellow Deficit</font>` = yDef,
           `<font color=\"gray\">Silver Deficit</font>` = sDef,
           `<font color=\"green\">Green Deficit</font>` = gDef,
           `Lightshow Deficit` = LightshowDef,
           `2 Cost Deficit` = C2Def,
           `4 Cost Deficit` = C4Def,
           `Escape Indicator` = crwdsum,
           `KO Indicator` = kohsum,
           `Money + Fight Deficit` = MoFiDef,
           `No Rules Txt Deficit` = NoRuDef,
           `Color Diversity Required` = colorDIVr,
           `Color Evenness` = colorEV,
           `Cost Div Required` = Cdivr,
           `Cost Evenness` = CdivEV) %>%
    select_if(negate(is.na)) %>%
    select_if(colSums(.)!=0)
  metrics$`Evil Wins` = wincon
  colnames(metrics) = paste0("<b>",colnames(metrics),"</b>")
  metrics = t(metrics)
  colnames(metrics) = "Metrics"
  metrics = ifelse(metrics<0,
                   str_c("<font color=\"red\"><b>",
                          metrics,
                          "</b></font>"),
                   metrics)
  #metrics$Metrics = format(metrics$Metrics,nsmall=0)
  #rounding more complex because of div irrationals
  return(metrics)
}

metricsLoop <- function(games) {
  metrics = list()
  for (j in 1:length(games)) {
    metrics[[j]] = metricsGen(games,j)
  }
  return(metrics)
}

setGames <- function(games,
                     setreq = NULL,
                     dropgames = 1) {
  if (!is.null(setreq)) {
    goodGames = tibble(setcount = seq(1,length(games)),
                       setdiv = seq(1,length(games)))
    for (i in 1:length(games)) {
      setsreqed = match(games[[i]]$sets,setreq)
      setsreqed = setsreqed[!is.na(setsreqed)]
      goodGames$setcount[i] = length(setsreqed)
      goodGames$setdiv[i] = length(setsreqed[!duplicated(setsreqed)])
    }
    games = games[goodGames$setcount>dropgames]
  }
  return(games)
}