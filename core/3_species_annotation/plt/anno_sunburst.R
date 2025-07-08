# plt_anno_sunburst

core.species_annotation.plt.anno_sunburst <- function(dbpath, proj.id, file_pre){
  
  progress <- Progress$new(max = 5)
  on.exit(progress$close())
  progress$set(4, message = 'Sunburst Ploting...')
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  file_path.anno_confirm = file.path(dbpath, proj.id, paste0(file_pre,'_annotation.confirm.txt'))
  
  if(!file.exists(file_path.anno_confirm)) {return(NULL)}
  
  anno <- read.table(file_path.anno_confirm, header = T, row.names = 1)
  # check for reliable annotations above the threshold
  anno <- anno[anno$Percentage != "UnClassified", ]
  if(nrow(anno) == 0){
    showModal(modalDialog(
      title = "Warning",
      "No reliable annotation were found, please set a lower threshold",
      alertType = "warning"
    ))
    return(NULL)
  }
  
  freq = as.data.frame(table(anno$Annotation))
  freq$Var1 <- gsub("\\|", "-", freq$Var1)
  colnames(freq) <- c('VAR','Value')
  
  plt <- sund2b(freq, colors = htmlwidgets::JS("d3.scaleOrdinal(d3.schemeCategory20b)"), showLabels = TRUE)

  # save
  sunburst(freq)
  
  progress$set(value = 5, message = 'Finished')
  
  return(plt)
  
}
