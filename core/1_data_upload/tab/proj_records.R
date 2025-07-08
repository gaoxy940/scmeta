# refresh tab_proj and tab_proj_info

core.data_upload.tab.proj_records <- function(dbpath, proj_id = NULL) {
  
  if (is.null(dbpath)) {return(NULL)}
  
  dt <- fromJSON(file.path(dbpath,'Projs.json'))
  dt <- dt[,1:4]
  
  # only proj_id info
  if(!is.null(proj_id)){
    dt = dt[dt$Proj.ID == proj_id,]
  }

  tab <- datatable(dt, selection = list(mode = 'single', selected = nrow(dt)), options = list(dom = 'tp'), escape = F)

  return(tab)
  
}

core.data_upload.tab.proj_info <- function(dbpath, proj.id) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  # Returns The contents of the group.txt in the appropriate folder.
  
  if(file.exists(file.path(dbpath, proj.id, 'group.txt'))){
    
    dt <- read.table(file.path(dbpath, proj.id, 'group.txt'), header = T)
    tab <- datatable(dt, selection = 'none', options = list(dom = 'tp'), escape = F)
    return(tab)
    
  }
  
  return(NULL)
  
}
