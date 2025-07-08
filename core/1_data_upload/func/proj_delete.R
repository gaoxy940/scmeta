# proj.delete


core.data_upload.func.proj_delete <- function(dbpath, proj.id) {

  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}

  # delete the project folder
  unlink(file.path(dbpath, proj.id), recursive = TRUE)

  # delete www/snp.files
  dirs <- list.dirs("www/snp.files", full.names = FALSE, recursive = FALSE)
  dirs <- dirs[grepl(proj.id, dirs)]
  if(length(dirs) > 0) {
    for(dir in dirs) {
      unlink(file.path("www/snp.files", dir), recursive = TRUE)
    }
  }

  # refresh json
  Projs <- fromJSON(file.path(dbpath, "Projs.json"))
  Projs <- Projs[-which(Projs$Proj.ID == proj.id),]
  Projs <- toJSON(Projs, pretty = T)
  cat(Projs, file = (con <- file(file.path(dbpath, "Projs.json"), 'w', encoding = 'UTF-8')))
  close(con)
         
}
