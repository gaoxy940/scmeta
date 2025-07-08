# fastp summary filter tab

core.quality_control.tab.fastp_summary_filter <- function(dbpath, proj.id, Total_thr, Clean_thr, Cut_thr, Q30_thr, GC_thr, Duplication_thr){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}

  dir_path = file.path(dbpath, proj.id, 'result/fastp')
  file_path.fastp_summary = file.path(dir_path, 'fastp_summary.txt')
  if(!file.exists(file_path.fastp_summary) || file.size(file_path.fastp_summary) == 0) {return(NULL)}
  
  fastp_summary <- read.table(file_path.fastp_summary, header = T, row.names = 1)

  if(Total_thr[1]==Total_thr[2] | Clean_thr[1]==Clean_thr[2] | Cut_thr[1] == Cut_thr[2] | Q30_thr[1] == Q30_thr[2] | GC_thr[1] == GC_thr[2] | Duplication_thr[1] == Duplication_thr[2]){

    showModal(modalDialog(
      title = "Invalid Act",
      "No Sample were chosen!"
    ))
    return(NULL)

  }
  
  fastp_summary <- fastp_summary %>%
    filter(Total_reads >= Total_thr[1] & Total_reads <= Total_thr[2]) %>%
    filter(Clean_reads >= Clean_thr[1] & Clean_reads <= Clean_thr[2]) %>%
    filter(Cut_reads >= Cut_thr[1] & Cut_reads <= Cut_thr[2]) %>%
    mutate(Q30_rates = as.numeric(sub("%", "", Q30_rates))) %>%
    filter(Q30_rates >= Q30_thr[1] & Q30_rates <= Q30_thr[2]) %>%
    mutate(Q30_rates = paste0(Q30_rates, "%")) %>%
    mutate(GC_connects = as.numeric(sub("%", "", GC_connects))) %>%
    filter(GC_connects >= GC_thr[1] & GC_connects <= GC_thr[2]) %>%
    mutate(GC_connects = paste0(GC_connects, "%")) %>%
    mutate(Duplication = as.numeric(sub("%", "", Duplication))) %>%
    filter(Duplication >= Duplication_thr[1] & Duplication <= Duplication_thr[2]) %>%
    mutate(Duplication = paste0(Duplication, "%"))
  
  write.table(fastp_summary, file = file.path(dir_path, 'fastp_summary_filtered.txt'), row.names = F, quote = F, sep = '\t')

  # group_filtered.txt
  file_path.groups = file.path(dbpath, proj.id, 'group.txt')
  if(file.exists(file_path.groups)) {

    group_list <- read.table(file_path.groups, header = T)
    rownames(group_list) = group_list[,1]
    group_list <- as.data.frame(group_list[rownames(fastp_summary),])
    colnames(group_list)[1] = 'Sample'
    write.table(group_list, file = file.path(dbpath, proj.id, 'group_filtered.txt'), row.names = F, quote = F, sep = '\t')

  }
  
  tab <- datatable(fastp_summary, selection = 'none', extensions = 'Buttons',
                   options = list(scrollX=TRUE, lengthMenu = c(20,30,50),
                                  dom = 'lftipB',
                                  buttons = c('copy', 'csv', 'excel','pdf')),
                   escape = F)
  
  return(tab)
  
}
