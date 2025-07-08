# plot snp heatmap

core.snp_analysis.plt.snp_heatmap <- function(dbpath, proj.id, species_name, snp_hclust_treenum = 1){
  
  empty_matrix <- matrix(nrow = 1, ncol = 1)
  
  if (is.null(dbpath)) {return(iheatmap(empty_matrix))}
  if (is.null(proj.id)) {return(iheatmap(empty_matrix))}

  progress <- Progress$new();
  progress$set(0.3, message = 'Reading...')
  
  dir_path = file.path(dbpath, proj.id, 'result/snippy',species_name)
  file_path.snp_matrix = file.path(dir_path,'snp_matrix.txt')
  if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 10 * 1024) {return(iheatmap(empty_matrix))}
  snp <- read.table(file_path.snp_matrix, sep='\t', comment.char="", header = T, nrow = 500)
  rownames(snp) <- paste0(snp$CHR,'_',snp$POS)
  snp <- snp %>% mutate(across(-c(CHR, POS), ~ ifelse(. == REF, 0, 1)))
  CHR_index <- which(names(snp) == "CHR")
  POS_index <- which(names(snp) == "POS")
  REF_index <- which(names(snp) == "REF")
  snp <- snp[,-c(CHR_index, POS_index, REF_index)]
  # Transpose into rows as samples, cols as features
  snp <- as.matrix(t(snp))

  # get hcluster
  file_path.snp_hcluster = file.path(dir_path,'snp_hcluster.tab.txt')
  if(!file.exists(file_path.snp_hcluster)) {
    showModal(modalDialog(
            title = "Warning",
            "It is recommended that you run the clustering in step 3 first!"
          ))
    return(iheatmap(empty_matrix))
  }
  cluster <- read.table(file_path.snp_hcluster, row.names = 1, header = T)
  colnames(cluster) <- c('sample','hcluster')
  cluster <- cluster[order(cluster$hcluster), ]
  snp <- snp[match(cluster$sample, rownames(snp)),]

  # get row_annotation
  if(basic.is_groups(dbpath, proj.id)){
    # get group_list
    file_path.group_filtered = file.path(dbpath, proj.id, 'group_filtered.txt')
    file_path.group = file.path(dbpath, proj.id, 'group.txt')
    if (file.exists(file_path.group_filtered)) {
      group_list <- read.table(file_path.group_filtered, header = T, row.names = 1)
    } else if (file.exists(file_path.group)) {
      group_list <- read.table(file_path.group, header = T, row.names = 1)
    }else {return(iheatmap(empty_matrix))}
    # row_annotation
    row_anno <- data.frame(Cluster = cluster$hcluster, Group = group_list[rownames(snp),])
    rownames(row_anno) = rownames(snp)
    
  } else {
    row_anno <- data.frame(Cluster = cluster$hcluster)
    rownames(row_anno) = rownames(snp)
  }

  progress$set(0.8, message = 'Ploting...')
  
  fig <- iheatmap(snp, name = 'Label',
                  row_clusters = cluster$hcluster,
                  # row_annotation = row_anno,
                  # row_k = length(unique(cluster$hcluster)),
                  colors = c("navy", "white", "firebrick3"),
                  row_clusters_name = "Clusters",
                  row_clusters_colors = colorRampPalette(rev(brewer.pal(n = 8, name = 'Set1')))(8),
                  show_row_clusters_colorbar = TRUE) %>% 
                  add_row_annotation(row_anno, side = "left") %>%
                  add_col_title("Clustering Heatmap: Mutation Status (mutated = 1; unmutated = 0)", buffer=0.1)
  
  # pdf_path = file.path(dbpath, proj.id, 'result/snippy', species_name, 'pdf/snp_heatmap.pdf')
  # save_iheatmap(fig, pdf_path)
  
  progress$close()
  return(fig)
    
}
