# get_fun_anno_list()

core.function_annotation.func.get_func_anno_list <- function(dbpath, proj.id){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  file_path.humann_pathabundance = file.path(dbpath, proj.id, 'result/humann3/pathabundance_relab_unstratified.tsv')
  if(!file.exists(file_path.humann_pathabundance)) {return(NULL)}
  df <- read.csv(file_path.humann_pathabundance, row.names = 1, sep = '\t', header = T)
  df <- df[-(1:2), ]
  df <- df[order(-df[, 1]), ]

  anno_list = rownames(df)  
  return(anno_list)
  
}