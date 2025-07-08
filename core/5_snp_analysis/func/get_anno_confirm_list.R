# get_anno_confirm_list

core.snp_analysis.func.get_anno_confirm_list <- function(dbpath, proj.id, file_pre, anno_level){
  
  if(is.null(dbpath)) {return(NULL)}
  if(is.null(proj.id)) {return(NULL)}
  if(is.null(anno_level)) {return(NULL)}
  if(is.null(file_pre) || file_pre == '') {return(NULL)}
  
  file_path.anno_confirm = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.confirm.txt'))
  
  if(!file.exists(file_path.anno_confirm)) {return(NULL)}
  
  anno <- read.table(file_path.anno_confirm, header = T, row.names = 1)
  # check for reliable annotations above the threshold
  anno <- anno[anno$Percentage != "UnClassified", ]
  if(nrow(anno) == 0){return(NULL)}
  
  # anno_level
  anno_list = sub(".*__", "", unique(anno[anno_level])[,1])
  
  return(anno_list)
  
}