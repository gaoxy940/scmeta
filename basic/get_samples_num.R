
basic.get_samples_num <- function(dbpath, proj.id){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  dt <- fromJSON(basic.get_json_fpath(dbpath))
  return(as.numeric(dt$Sample.Count[dt$Proj.ID == proj.id]))

  
}