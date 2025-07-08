#### filter ui ####

core.quality_control.Dui.filter_ui <- function(dbpath, proj.id, id, label, feature, step, run_qc_filter_reset){

  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}

  num = run_qc_filter_reset

  file_path.fastp_summary = file.path(dbpath, proj.id, 'result/fastp/fastp_summary.txt')
  if(!file.exists(file_path.fastp_summary)) {return(NULL)}
  
  fastp_summary <- read.table(file_path.fastp_summary, header = T, row.names = 1)
  num <- as.numeric(gsub("%", "", fastp_summary[[feature]]))

  min = min(num) %/% step * step
  max = (max(num) + step) %/% step * step

  choices <- seq(min, max, step)
  selected <- c(min, max)
  
  
  widget <- sliderTextInput(inputId = id, label = label,
                            choices = choices, selected = selected,
                            grid = T)
  
  return(widget)
  
}