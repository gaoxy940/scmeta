# plot snp tree

core.snp_analysis.plt.snp_tree <- function(dbpath, proj.id, species_name){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}

  dir_path = file.path(dbpath, proj.id, 'result/snippy',species_name)
  
  # hcluster
  file_path.snp_hcluster = file.path(dir_path,'snp_hcluster.tab.txt')
  if(!file.exists(file_path.snp_hcluster)) {
    showModal(modalDialog(
            title = "Warning",
            "It is recommended that you run the clustering in step 3 first!"
          ))
    return(NULL)
  }

  progress <- Progress$new(max = 5)
  on.exit(progress$close())
  progress$set(2, message = 'Running...')

  cluster <- read.table(file_path.snp_hcluster, row.names = 1, header = T)
  colnames(cluster) <- c('sample','hcluster')
  cluster <- rbind(cluster, c('Reference','Reference'))

  # tree.nwk
  file_path.snp_tree = file.path(dir_path,'tree.nwk')
  if(!file.exists(file_path.snp_tree) || file.size(file_path.snp_tree) < 1*1024){
    system(paste("/bin/bash script/run_snippy_tree.sh",dir_path))
  }
  tree <- read.tree(file_path.snp_tree)

  progress$set(4, message = 'Plotting...')

  drawTreePlot <- function(savePdf = FALSE) {
    ggtree(tree, 
          # linetype='dashed', 
          color = "#487AA1",
          layout="circular",
          branch.length = "none") %<+% cluster +
        geom_tiplab(aes(color = hcluster), size=1.5,align = TRUE,offset = 1) + 
        theme(legend.position = "right")
  }

  ## save
  pdf_dir_path = file.path(dir_path, 'pdf')
  if (!dir.exists(pdf_dir_path)) {
      dir.create(pdf_dir_path, recursive = TRUE)
  }  
  pdf_path = file.path(pdf_dir_path,'snp_phylo_tree.pdf')
  p = drawTreePlot(savePdf = TRUE)
  ggsave(pdf_path, p)
  p

}
