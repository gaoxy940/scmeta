# plot groups tab

core.species_annotation.tab.groups_tab <- function(dbpath, proj.id, file_pre, anno_level){
  
  if(!basic.is_groups(dbpath, proj.id)){
    
    showModal(modalDialog(
      title = "Inappropriate Project",
      'Groups analysis is not appropriate for this project!',
      alertType = "warning"
    ))
    return(NULL)
    
  }
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  file_path.anno_groups = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.groups.txt'))
  if(!file.exists(file_path.anno_groups)) {return(NULL)}
  
  anno_groups <- read.table(file_path.anno_groups, header = T, row.names = 1)
  
  tab <- datatable(anno_groups, selection = 'none', extensions = 'Buttons',
                   options = list(scrollX=TRUE, lengthMenu = c(5,10,15),
                                  dom = 'lftipB',
                                  buttons = c('copy', 'csv', 'excel','pdf')),
                   escape = F)
  
  return(tab)
  
}
