genFun = function(src,
                  playerc=2,
                  epic=F,
                  fixedMM="",
                  fixedSCH="",
                  fixedHM="",
                  fixedHER="",
                  fixedVIL="",
                  dropset="") {
  
  
  #setup numbers depending on number of players
  heroesc = 0
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
  schnumber = 0
  
  src$schemes %<>% filter(!Set%in%dropset)
  #Fixed scheme given?
  if (fixedSCH!="") {
    schnumber = match(fixedSCH,src$schemes$Name)
    if (is.na(schnumber)) {
      warning("Scheme - ",fixedSCH," - not found")
    }
  }
  
  #Random scheme if not given or not found
  if (fixedSCH==""|is.na(schnumber)) {
    schnumber = sample(1:nrow(src$schemes),1)
  }
  
  #save name and scores
  schem = src$schemes$Name[schnumber]
  schemtraits = filter(src$schemes,Name==schem)
  
  #set NA's to 0 (can be important for metrics)
  schemtraits[is.na(schemtraits)]=0
  
  #playerc dependent scheme settings:
  if (grepl(":",
            src$schemes$HC[schnumber],
            fixed=T)) {
    schemeset = strsplit(src$schemes$HC[schnumber],
                         split=":|;")
    schemeset_nrs = tibble(playerc=seq(1,(length(schemeset[[1]])/2)),
                           n=seq(1,(length(schemeset[[1]])/2)))
    j=0
    for (i in dim(schemeset_nrs)[1]) {
      j = j + 1
      schemeset_nrs$playerc[i] = as.numeric(schemeset[[1]][j])
      schemeset_nrs$n[i] = schemeset[[1]][j+1]
      j = j + 1
    }
    schemeset_nrs %<>% filter(playerc<=playerc)
    if (dim(schemeset_nrs)[1]==1) {
      src$schemes$HC[schnumber]=schemeset_nrs$n[1]
    }
    if (dim(schemeset_nrs)[1]>1) {
      src$schemes$HC[schnumber]=schemeset_nrs$n[schemeset_nrs$playerc==max(schemeset_nrs$playerc)]
    }
  }
  
  #modify card numbers according to scheme
  heroesc = heroesc + ifelse(!is.na(src$schemes$HC[schnumber]),
                             as.numeric(src$schemes$HC[schnumber]),
                             0)
  villainc = villainc + ifelse(!is.na(src$schemes$VC[schnumber]),
                               src$schemes$VC[schnumber],
                               0)
  henchc = henchc + ifelse(!is.na(src$schemes$CH[schnumber]),
                           src$schemes$CH[schnumber],
                           0)
  
  
  ##############################################################
  ##Generate a mastermind
  
  #Only list the individual masterminds
  #not tactics (with a MM value), not epic versions, not transformed versions (T)
  mmlist=filter(src$masterminds,
                is.na(MM),
                is.na(Epic),
                is.na(T),
                !Set%in%dropset)
  mmnumber = 0
  
  #Fixed mm given?
  if (fixedMM!="") {
    mmnumber = match(fixedMM,mmlist$Name)
    if (is.na(mmnumber)) {
      warning("Mastermind - ",fixedMM," - not found")
    }
  }
  
  #Random mm
  if (fixedMM==""|
      is.na(mmnumber)) {
    mmnumber = sample(1:nrow(mmlist),1)
  }
  
  #save name and scores
  mm = mmlist$Name[mmnumber]
  mmtraits = filter(src$masterminds,
                    MM==mm|
                      Name==mm)
  
  #set NA's to 0 (can be important for metrics)
  mmtraits[is.na(mmtraits)]=0
  
  #modify the scores for epic or not; add epic label to mm name
  if (epic==""|epic==0) {
    mmtraits = filter(mmtraits,Epic==0)
  }
  if (epic==1&
      mmtraits$Epic[2]==1) {
    mmtraits = filter(mmtraits,
                      Epic==1|
                        MM!=0)
    mm = c(mm,"epic")
  }
  
  
  
  ##############################################################
  ##Generate villain groups
  src$villains %<>% filter(!Set%in%dropset)
  villist=distinct(src$villains,Group) #check on group, not individual card
  
  #Villain group required by scheme?
  if (!is.na(src$schemes$Vill_Inc[schnumber])) {
    villnames = src$schemes$Vill_Inc[schnumber]
  }
  else {
    villnames = NULL
  }
  
  #Villain group required by mm?
  if (!is.na(mmlist$LeadsV[mmnumber])) {
    villnames = c(villnames,mmlist$LeadsV[mmnumber])
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
  
  if (!is.na(src$schemes$HM_Inc[schnumber])) {
    henchnames = src$schemes$HM_Inc[schnumber]
  }
  else {
    henchnames = NULL
  }
  
  if (!is.na(mmlist$LeadsH[mmnumber])) {
    henchnames = c(henchnames,mmlist$LeadsH[mmnumber])
  }
  
  if (fixedHM=="") {
    fixedHM = NULL
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
  
  
  
  ##############################################################
  ##Generate heroes
  heronames = NULL
  
  src$heroes %<>% filter(!Set%in%dropset)
  src$heroes$uni = paste(src$heroes$Hero,src$heroes$Set,sep="_")
  
  #A few schemes have such specific needs their hero requirements are hardcoded here separately
  if (schemtraits$Hero_Inc[1]=="CUSTOM") {
    schemtraits$Hero_Inc[1] = 0
    if (schemtraits$Name[1]=="Avengers vs X-Men") {
      fixedHER = NULL
      teamlist = count(src$heroes,Team)
      teamlist %<>% filter(n>12)
      teamlist %<>% sample_n(2)
      src$heroes %<>% filter(Team%in%teamlist$Team)
      herolist1 = distinct(filter(src$heroes,Team==teamlist$Team[1]),uni)
      herolist2 = distinct(filter(src$heroes,Team==teamlist$Team[2]),uni)
      heronumber1 = sample(1:nrow(herolist1),heroesc/2,replace=F)
      heronumber2 = sample(1:nrow(herolist2),heroesc/2,replace=F)
      heroid1 = herolist1$uni[heronumber1]
      heroid2 = herolist2$uni[heronumber2]
      heronames = c(heroid1,heroid2)
      heroesc = 0
    }
    if (schemtraits$Name[1]=="House of M") {
      fixedHER = NULL
      herolist1 = distinct(filter(src$heroes,Team=="X-Men"),uni)
      herolist2 = distinct(filter(src$heroes,Team!="X-Men"),uni)
      heronumber1 = sample(1:nrow(herolist1),4,replace=F)
      heronumber2 = sample(1:nrow(herolist2),2,replace=F)
      heroid1 = herolist1$uni[heronumber]
      heroid2 = herolist2$uni[heronumber]
      heronames = c(heroid1,heroid2)
      heroesc = 0
    }
  }
  
  #hero required by scheme?
  if (schemtraits$Hero_Inc[1]!=0) {
    herolist = filter(src$heroes,
                      Name_S==schemtraits$Hero_Inc[1])
    herolist = distinct(herolist,uni)
    heroid = sample(1:length(herolist),1)
    heronames = herolist[heroid]
  }
  
  #join both the scheme hero and the fixed provided (if any)
  if (heroesc!=0) {
    heronames = c(heronames,fixedHER)
  }
  
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
    schem,
    mm,
    villnames,
    henchnames,
    heronames,
    list(schemtraits,mmtraits,viltraits,henchtraits,herotraits),
    sets)
  names(resu) = c("Scheme",
                  "Mastermind",
                  "Villains",
                  "Henchmen",
                  "Heroes",
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
  game$Heroes = gsub("_"," (",game$Heroes)
  game$Heroes = paste0(game$Heroes,")")
  setup = c(game$Scheme,
            paste(game$Mastermind,collapse=" - "),
            paste(game$Villains,collapse="<br>"),
            paste(game$Henchmen,collapse="<br>"),
            paste(game$Heroes,collapse="<br>"))
  setup = data.frame(data=setup, row.names=c("<b>Scheme</b>",
                                             "<b>Mastermind</b>",
                                             "<b>Villains</b>",
                                             "<b>Henchmen</b>",
                                             "<b>Heroes</b>"))
  colnames(setup) = paste0("Setup ",setupid)
  return(setup)
}

teamlookup <- function(name,src) {
  result = paste(filter(src$heroes,Hero==name,Ct==1)$Team,collapse="|")
  if (result == "") {
    result = "Team not found"
  }
  return(result)
}

mmGen <- function(not,n=1,data=src) {
  mmlist = src$masterminds %>% 
    filter(is.na(MM),
           is.na(Epic),
           is.na(T)) %>%
    filter(Name!=not)
  mmnumber = sample(1:nrow(mmlist),n,replace=F)
  return(mmlist$Name[mmnumber])
}

setupPrint <- function(game) {
  game$Heroes = gsub("_"," (",game$Heroes)
  game$Heroes = paste0(game$Heroes,")")
  setup = c(game$Scheme,
            paste(game$Mastermind,collapse=" - "),
            paste(game$Villains,collapse="|"),
            paste(game$Henchmen,collapse="|"),
            paste(game$Heroes,collapse="|"))
  write.table(t(setup),"clipboard",sep="\t",col.names = F,row.names = F)
}

metricsGen = function(games,nr) {
  
  #games is a list of generated setups
  #nr is the element of that list to calculate metrics for
  
  #initialize metrics df
  bCount = 0
  metrics = tibble(bCount)
  
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
  metrics$CdivEV = metrics$Cdiv/log(dim(cost_div)[1])
  
  ##spectrum
  metrics$colorDIVr = sum(games[[nr]]$scores$heroes$SP*
                            games[[nr]]$scores$heroes$Ct)
  colors = c("B","R","Y","G","S")
  n = unlist(metrics[1:5])
  color_div = tibble(colors,n)
  color_div$p = color_div$n/sum(color_div$n)
  metrics$colorDIV = -sum(color_div$p*log(color_div$p))
  metrics$colorEV = metrics$colorDIV /log(dim(color_div)[1])
  
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
  metrics = metrics[,-c(1:10)]
  metrics %<>% select(-Lightshow,
                      -Lightshowr,
                      -NoRur,
                      -NoRu,
                      -MoFi,
                      -MoFir,
                      -C2,
                      -C2r,
                      -C4,
                      -C4r)
  metrics %<>% select(-wincon)
  metrics %<>% select_if(negate(is.na))
  metrics %<>% select_if(colSums(.)!=0)
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