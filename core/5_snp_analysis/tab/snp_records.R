# refresh tab_repGenome_summary & snp_matrix

core.snp_analysis.tab.repGenome_summary <- function(dbpath, proj_id) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj_id)) {return(NULL)}
  
  file_path.repGenome_summary = file.path(dbpath, proj_id, 'Bifidobacterium_longum_find_repGenome_summary.txt')
  
  if(!file.exists(file_path.repGenome_summary)) {return(NULL)}
  
  smy <- read.table(file_path.repGenome_summary, header = T)
  
  tab <- datatable(smy, selection = 'none', extensions = 'Buttons',
                   options = list(scrollX=TRUE, lengthMenu = c(10,20,30),
                                  dom = 'lftipB',
                                  buttons = c('copy', 'csv', 'excel','pdf')),
                   escape = F)
  #tab <- datatable(dt, options = list(dom = 'lftip',scrollX = TRUE), escape = F)
  
  return(tab)
  
}

core.snp_analysis.tab.snp_matrix <- function(dbpath, proj_id, species_name) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj_id)) {return(NULL)}
  
  dir_path = file.path(dbpath, proj_id, 'result/snippy',species_name)
  file_path.snp_matrix = file.path(dir_path,'snp_matrix.txt')
  
  if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 10 * 1024) {return(NULL)}
  
  snp <- read.table(file_path.snp_matrix, sep = '\t',comment.char="", header = T, nrows = 100)
  rownames(snp) <- paste0(snp$CHR,'_',snp$POS)
  CHR_index <- which(names(snp) == "CHR")
  POS_index <- which(names(snp) == "POS")
  snp <- snp[,-c(CHR_index, POS_index)]
  snp = as.data.frame(t(snp))
  www_file_list = file.path('snp.files', paste0(proj_id,'_',species_name,'_snp.files'), paste0(rownames(snp),'.vcf.txt'))

  tab <- data.table(
    snp,
    Links = ifelse(file.exists(file.path('www',www_file_list)),
                  paste0("<a href='",www_file_list,"' target='_blank'>", rownames(snp), "</a>"),
                  rownames(snp))
  )
  rownames(tab) = rownames(snp)
  dt <- datatable(tab, selection = 'none', options = list(scrollX=TRUE, lengthMenu = c(10,20,30),
                                                            dom = 'lftipB'),
                  escape = F)   

  return(dt)
  
}

core.snp_analysis.tab.snp_hclust <- function(dbpath, proj_id, species_name) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj_id)) {return(NULL)}
  
  file_path.snp_hcluster.tab = file.path(dbpath, proj_id, 'result/snippy', species_name, 'snp_hcluster.tab.txt')

  if(!file.exists(file_path.snp_hcluster.tab)) {return(NULL)}
  
  snp_hclust <- read.table(file_path.snp_hcluster.tab, comment.char="", header = T)
  
  tab <- datatable(snp_hclust, selection = 'none', extensions = 'Buttons',
                   options = list(scrollX=TRUE, lengthMenu = c(10,20,30),
                                  dom = 'lftipB',
                                  buttons = c('copy', 'csv', 'excel','pdf')),
                   escape = F)

  return(tab)
  
}

core.snp_analysis.tab.snp_hclust_diff <- function(dbpath, proj_id, species_name, cp, ct) {
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj_id)) {return(NULL)}
  
  file_path.snp_hcluster.diff.tab = core.snp_analysis.fun.get_snp_hclust_diff_tab(dbpath, proj_id, species_name, cp, ct)

  if(is.null(file_path.snp_hcluster.diff.tab)) {return(NULL)}
  if(!file.exists(file_path.snp_hcluster.diff.tab)) {return(NULL)}
  
  snp_hclust_diff <- read.table(file_path.snp_hcluster.diff.tab, comment.char="", header = T)
  
  tab <- datatable(snp_hclust_diff, selection = 'none', extensions = 'Buttons',
                   options = list(scrollX=TRUE, lengthMenu = c(10,20,30),
                                  dom = 'lftipB',
                                  buttons = c('copy', 'csv', 'excel','pdf')),
                   escape = F)

  return(tab)
  
}
