# func.anno_groups

core.species_annotation.func.anno_groups <- function(dbpath, proj.id, file_pre, anno_level){
  
  if(!basic.is_groups(dbpath, proj.id)) return(NULL)
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  file_path.group_filtered = file.path(dbpath, proj.id, 'group_filtered.txt')
  file_path.group = file.path(dbpath, proj.id, 'group.txt')
  if (file.exists(file_path.group_filtered)) {
    group_list <- read.table(file_path.group_filtered, header = T, row.names = 1)
  } else if (file.exists(file_path.group)) {
    group_list <- read.table(file_path.group, header = T, row.names = 1)
  }else {return(NULL)}
  
  file_path.anno_confirm = file.path(dbpath, proj.id, paste0(file_pre,'_annotation.confirm.txt'))
  if(!file.exists(file_path.anno_confirm)) {return(NULL)}
  
  anno <- read.table(file_path.anno_confirm, header = T, row.names = 1)
  # check for reliable annotations above the threshold
  anno <- anno[anno$Percentage != "UnClassified", ]
  if(nrow(anno) == 0){
    
    df <- data.frame(Group = character(),
                 Annotation = character(),
                 Frequency = numeric(),
                 stringsAsFactors = FALSE)

  } else {

    group_list <- group_list[rownames(anno),]
    anno$Group <- group_list
    
    #anno_level = 'Family'
    dt <- data.frame(anno[anno_level],anno['Group'])
    df <- as.data.frame(table(dt[,2],dt[,1]))
    colnames(df) <- c('Group', 'Annotation', 'Frequency')

  }
  
  # save
  write.table(df, file = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.groups.txt')), quote = F)
  
}
