# plot heatmap

core.function_annotation.plt.heatmap <- function(dbpath, proj_id){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj_id)) {return(NULL)}

  file_path.kegg = file.path(dbpath, proj_id, 'result/humann3/KEGG.PathwayL2.raw.txt')
  if(!file.exists(file_path.kegg)) {
    showModal(modalDialog(
          title = "Inconsistent Output",
          "The result of the KEGG pathway is null",
          alertType = "error"
        ))
        return(NULL)
  }
  dt <- read.table(file_path.kegg, , sep = '\t', header = TRUE, row.names = 1, check.names = FALSE)
  # dt <- dt + 1
  # Transpose into rows as samples, cols as features
  dt <- as.matrix(dt)

  progress <- Progress$new();
  progress$set(0.8, message = 'Ploting...')

  fig = pheatmap::pheatmap(dt,
          color=colorRampPalette(c("navy", "white", "firebrick3"))(100),
          scale="row",
          cluster_cols = TRUE,
          # cluster_rows = TRUE,
          clustering_method="complete",
          clustering_distance_cols="correlation",
          # clustering_distance_rows="manhattan",
          # annotation_col = group_list,
          # filename = pdf_path,
          show_colnames = FALSE,
          show_rownames = TRUE,
  )

  png_dir_path = file.path(dbpath, proj_id, "result/humann3/png")
  if (!dir.exists(png_dir_path)) {
    dir.create(png_dir_path, recursive = TRUE)
  }
  pdf_path = file.path(png_dir_path, 'heatmap_KEGG.Pathway.L2.pdf')
  pdf(pdf_path)
  grid::grid.newpage()
  grid::grid.draw(fig$gtable)
  dev.off()

  progress$close()
  return(fig)
    
}
