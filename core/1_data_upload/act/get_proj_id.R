#get_present_proj

core.data_upload.act.get_proj_id <- function(dbpath, idx.p){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(idx.p)) {return(NULL)}
  
  dt <- fromJSON(basic.get_json_fpath(dbpath))
  id <- dt$Proj.ID[idx.p]
  
  return(id)
  
}