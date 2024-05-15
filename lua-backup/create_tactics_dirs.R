mm = js$ObjectStates[[10]]$ContainedObjects
mm=NULL #don't accidentally run and overwrite everything
for (i in 1:length(mm)) {
  if (mm[[i]]$Nickname%in%mmdone) {
    dir.create(mm[[i]]$Nickname)
    for (j in 1:length(mm[[i]]$ContainedObjects)) {
      if (mm[[i]]$ContainedObjects[[j]]$Nickname!=mm[[i]]$Nickname) {
        file.create(paste0(mm[[i]]$Nickname,"/",mm[[i]]$ContainedObjects[[j]]$Nickname,".lua"))
      }
    }
  }
}
