# plot groups bar

core.species_annotation.plt.groups_bar <- function(dbpath, proj.id, file_pre, anno_level){
  
  if(!basic.is_groups(dbpath, proj.id)){
    
    showModal(modalDialog(
      title = "Inappropriate Project",
      'Groups analysis is not appropriate for this project!',
      alertType = "warning"
    ))
    return(NULL)
    
  }
  
  progress <- Progress$new(max = 5)
  on.exit(progress$close())
  progress$set(2, message = 'Bar Running...')
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  file_path.anno_groups = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.groups.txt'))
  if(!file.exists(file_path.anno_groups)) {return(NULL)}
  
  anno_groups <- read.table(file_path.anno_groups, header = T, row.names = 1)
  # check for reliable annotations above the threshold
  if(nrow(anno_groups) == 0){
    showModal(modalDialog(
      title = "Warning",
      "No reliable annotation were found, please set a lower threshold",
      alertType = "warning"
    ))
    return(NULL)
  }
  
  progress$set(4, message = 'Bar Ploting...')
  
  fig <- plot_ly(data = anno_groups, 
                 x = ~Group, 
                 y = ~Frequency,
                 color = ~Annotation,
                 type = 'bar',
                 # barmode = 'stack',
                 sizes = 0.8,
                 alpha = 0.7,
                 showlegend = T,
                 hoverinfo = 'text',
                 hovertext = ~paste('</br> Species: ', anno_groups$Annotation,
                                    '</br> Frequency: ', anno_groups$Frequency)) %>%
    layout(yaxis = list(title = 'Cell Count'),
           # title="Student Statistics",
           barmode = 'stack')
  
  progress$set(value = 5, message = 'Finished')
  
  return(fig)
    
}
