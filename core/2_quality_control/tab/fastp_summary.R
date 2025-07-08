# fastp summary tab

core.quality_control.tab.fastp_summary <- function(dbpath, proj.id){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  file_path.fastp_summary = file.path(dbpath, proj.id, 'result/fastp/fastp_summary.txt')
  if(!file.exists(file_path.fastp_summary)) {return(NULL)}
  
  fastp_summary <- read.table(file_path.fastp_summary, header = T, row.names = 1)

  # group_filtered.txt
  file_path.groups = file.path(dbpath, proj.id, 'group.txt')
  if(file.exists(file_path.groups)) {

    file.copy(from = file_path.groups, to = file.path(dbpath, proj.id, 'group_filtered.txt'), overwrite = T)

  }
  
  tab <- datatable(fastp_summary, selection = 'none', extensions = 'Buttons',
                   options = list(scrollX=TRUE, lengthMenu = c(20,30,50),
                                  dom = 'lftipB',
                                  buttons = c('copy', 'csv', 'excel','pdf')),
                   escape = F)
  
  return(tab)
  
}
