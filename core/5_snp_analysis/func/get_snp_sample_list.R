# get_snp_sample_list

core.snp_analysis.func.get_snp_sample_list <- function(dbpath, proj.id, species_name){
  
  if(is.null(dbpath)) {return(NULL)}
  if(is.null(proj.id)) {return(NULL)}
  
  file_path.snp_species = file.path(dbpath, proj.id, 'result/snippy',species_name, 'snp_species.txt')
  dt <- read.table(file_path.snp_species, sep = '\t',header = T)
  return(as.list(dt$Sample))
  
}