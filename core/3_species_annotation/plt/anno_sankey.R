# plt_anno_tree

core.species_annotation.plt.anno_sankey <- function(dbpath, proj.id, file_pre){
  
  progress <- Progress$new(max = 5)
  on.exit(progress$close())
  progress$set(4, message = 'Tree Ploting...')
  
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
  split_strings <- strsplit(as.character(freq$Var1), "\\|")
  split_df <- as.data.frame(lapply(split_strings, as.data.frame))
  result <- as.data.frame(cbind(t(split_df), freq$Freq))
  colnames(result) <- c('Kingdom','Phylum','Class','Order','Family', 'Genus', 'Species', 'Freq')
  result$Freq = as.numeric(result$Freq)
  
  # link_list of sankeyNetwork
  genus_species <- result[c('Genus', 'Species', 'Freq')]
  names(genus_species) <- c('source', 'target', 'freq')
  family_genus <- aggregate(result$Freq, by = list(result$Family, result$Genus), FUN = sum)
  names(family_genus) <- c('source', 'target', 'freq')
  order_family <- aggregate(result$Freq, by = list(result$Order, result$Family), FUN = sum)
  names(order_family) <- c('source', 'target', 'freq')
  class_order <- aggregate(result$Freq, by = list(result$Class, result$Order), FUN = sum)
  names(class_order) <- c('source', 'target', 'freq')
  phylum_class <- aggregate(result$Freq, by = list(result$Phylum, result$Class), FUN = sum)
  names(phylum_class) <- c('source', 'target', 'freq')
  link_list <- rbind(phylum_class, class_order, order_family, family_genus, genus_species)
  
  # node_list of sankeyNetwork
  node_list <- reshape2::melt(result, id = 'Freq')
  node_list <- node_list[!duplicated(node_list$value), ]
  
  link_list$IDsource <- match(link_list$source, node_list$value) - 1 
  link_list$IDtarget <- match(link_list$target, node_list$value) - 1
  
  # plotly
  plt <- plot_ly(
    type = 'sankey', orientation = 'h',
    node = list(
      label = node_list$value,
      pad = 5, thickness = 20,
      line = list(color = 'black', width = 0.5)
    ),
    link = list(
      source = link_list$IDsource, target = link_list$IDtarget,
      value = link_list$freq
    )
  )

  # save
  image_path = file.path(dbpath, proj.id, paste0(file_pre,'_annotation.confirm_sankey.html'))
  saveWidget(plt, file = image_path)
  
  progress$set(value = 5, message = 'Finished')
  
  return(plt)
  
}