# func.anno_confirm

core.species_annotation.func.anno_confirm <- function(dbpath, proj.id, file_pre, anno_threshold){
  
  file_path.up0_all = file.path(dbpath, proj.id, paste0(file_pre, '_combined.percentages.up0_all.txt'))

  if(!file.exists(file_path.up0_all) || file.size(file_path.up0_all) < 5) {return(NULL)}
    
  dt <- read.table(file_path.up0_all, comment.char="", header = T, row.names = 1)
  # find the max value and row.index
  max_row.value <- apply(dt, 2, max)
  max_row.index <- apply(dt, 2, function(x) which(x == max(x)))
  
  max_row.anno <- rownames(dt)[max_row.index]
  anno <- data.frame(Annotation = max_row.anno, Value = max_row.value)

  # anno level split
  split_strings <- strsplit(anno$Annotation, "\\|")
  split_df <- as.data.frame(lapply(split_strings, as.data.frame))

  result <- as.data.frame(cbind(anno$Annotation, t(split_df), anno$Value))
  colnames(result) <- c('Annotation', 'Kingdom','Phylum','Class','Order','Family', 'Genus', 'Species', 'Percentage')
  rownames(result) <- rownames(anno)
  result$Percentage <- as.numeric(result$Percentage)
  result <- result[order(result$Percentage, decreasing = TRUE),]
  result$Percentage <- ifelse(result$Percentage > as.numeric(anno_threshold), result$Percentage, "UnClassified")
  
  # save
  write.table(result, file = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.confirm.txt')), quote = F)
  
}
