# refresh tab_anno_confirm & levels

core.species_annotation.tab.anno_confirm <- function(dbpath, proj.id, file_pre) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  # Returns The contents of the anno_file.
  file_path.anno_confirm = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.confirm.txt'))
  if(!file.exists(file_path.anno_confirm)) {return(NULL)}
  
  anno <- read.table(file_path.anno_confirm, header = T, row.names = 1)
  
  tab <- datatable(anno, selection = 'none', extensions = 'Buttons',
                     options = list(scrollX=TRUE, lengthMenu = c(5,10,15),
                                    dom = 'lftipB',
                                    buttons = c('copy', 'csv', 'excel','pdf')),
                     escape = F)
    #tab <- datatable(dt, options = list(dom = 'lftip',scrollX = TRUE), escape = F)
  
  return(tab)
  
}


core.species_annotation.tab.anno_levels <- function(dbpath, proj.id, file_pre, anno_level) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  # Returns The contents of the anno_file.
  file_path = file.path(dbpath, proj.id, paste0(file_pre, '_combined.percentages.up0_', tolower(anno_level), '.txt'))
  
  if(file.exists(file_path)){
    
    dt <- read.table(file_path, comment.char="", header = T, row.names = 1)
    dt <- dt[order(rowSums(dt),decreasing = TRUE),]
    tab <- datatable(dt, selection = 'none', extensions = 'Buttons',
                     options = list(scrollX=TRUE, lengthMenu = c(5,10,15),
                                    dom = 'lftipB',
                                    buttons = c('copy', 'csv', 'excel','pdf')),
                     escape = F)
    #tab <- datatable(dt, options = list(dom = 'lftip',scrollX = TRUE), escape = F)
    return(tab)
    
  }
  
  return(NULL)
  
}
