# Determine if the proj.id is duplicated

basic.is_repeat_proj <- function(dbpath, proj.id, proj.name){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  dt <- fromJSON(basic.get_json_fpath(dbpath))
  
  if(proj.id %in% dt$Proj.ID)
    return(TRUE)
  # if(proj.name %in% dt$Proj.Name)
  #   return(TRUE)
  return(FALSE)
  
}