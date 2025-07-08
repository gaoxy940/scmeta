# plot feature_vln

core.quality_control.plt.feature_vln <- function(dbpath, proj_id, feature){

  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj_id)) {return(NULL)}
  
  file_path.fastp_summary = file.path(dbpath, proj_id, 'result/fastp/fastp_summary.txt')
  file_path.fastp_summary_filtered = file.path(dbpath, proj_id, 'result/fastp/fastp_summary_filtered.txt')
  if(file.exists(file_path.fastp_summary_filtered)) {
    fastp_summary <- read.table(file_path.fastp_summary_filtered, header = T, row.names = 1)
  } else if(file.exists(file_path.fastp_summary)) {
    fastp_summary <- read.table(file_path.fastp_summary, header = T, row.names = 1)
  } else {return(NULL)}
  
  if(feature == 'Q30_rates'){
    fastp_summary$Q30_rates <- as.numeric(gsub("%", "", fastp_summary$Q30_rates))
  }
  dt <- data.frame(Freq. = fastp_summary[[feature]])
  
  
  fig <- plot_ly(data = dt, 
                 y = ~Freq.,
                 type = 'violin', points = F, spanmode = 'hard',
                 showlegend = F,
                 hoverinfo = 'y',
                 name = feature)
    
  fig <- fig %>% config(displayModeBar = F)
  
  
  return(fig)
    
}
