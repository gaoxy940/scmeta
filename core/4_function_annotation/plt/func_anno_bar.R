# plot groups bar

core.function_annotation.plt.func_anno_bar <- function(dbpath, proj.id, pathway){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  
  progress <- Progress$new();
  progress$set(0.4, message = 'Reading...')

  png_dir_path = file.path(dbpath, proj.id, "result/humann3/png")
  if (!dir.exists(png_dir_path)) {
    dir.create(png_dir_path, recursive = TRUE)
  }
  file_path.barplot = file.path(png_dir_path, paste0("barplot_",pathway,".png"))

  if(!file.exists(file_path.barplot)){
    progress$set(0.7, message = 'Plotting...')
    system(paste("/bin/bash script/run_humann3_barplot.sh",file.path(dbpath, proj.id),pathway))
  }
  
  progress$close()
  return(file_path.barplot)
    
}
