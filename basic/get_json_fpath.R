#get json filepath

basic.get_json_fpath <- function(dbpath){
  
  if (is.null(dbpath)) {return(NULL)}
  
  return(file.path(dbpath,'Projs.json'))
  
}