# Determines whether a project is multi-grouped

basic.is_groups <- function(dbpath, proj.id){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  dt <- fromJSON(basic.get_json_fpath(dbpath))
  
  if(dt$Proj.Group[dt$Proj.ID == proj.id] == 'Single')
    return(FALSE)
  return(TRUE)
  
}