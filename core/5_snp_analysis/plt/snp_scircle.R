# plot snp circle of snp sites for sample

core.snp_analysis.plt.snp_scircle <- function(dbpath, proj.id, species_name, sample_list){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  if(is.null(sample_list)) {return(NULL)}

  progress <- Progress$new();
  progress$set(0.3, message = 'Reading...')

  dir_path = file.path(dbpath, proj.id, 'result/snippy', species_name)
  seq_split <- 2000    # windows size

  # genome info
  file_path.size.genome = file.path(dir_path,'size.genome')
  if(!file.exists(file_path.size.genome)){
    progress$close()
    return(NULL)
  }
  seq_stat <- read.table(file_path.size.genome, sep = '\t')
  seq_stat <- as.data.frame(cbind(seq_stat[, 1], 1, seq_stat[, 2]))
  colnames(seq_stat) <- c('seq_ID','seq_start','seq_end')
  seq_stat$seq_start <- as.numeric(seq_stat$seq_start)
  seq_stat$seq_end <- as.numeric(seq_stat$seq_end)
  genome_size <- seq_stat[1,3]
  genome_name <- seq_stat[1,1]


  ## 1. read sample.txt
  if(!is.na(sample_list[1])){
    file_path = file.path(dir_path, 'vcf.files', paste0(sample_list[1], ".vcf.txt"))
    if(file.exists(file_path))
      sample1 <- read.table(file_path,sep = '\t',header = T, stringsAsFactors = FALSE)
  }
  if(!is.na(sample_list[2])){
    file_path = file.path(dir_path, 'vcf.files', paste0(sample_list[2], ".vcf.txt"))
    if(file.exists(file_path))
      sample2 <- read.table(file_path,sep = '\t',header = T, stringsAsFactors = FALSE)
  }
  if(!is.na(sample_list[3])){
    file_path = file.path(dir_path, 'vcf.files', paste0(sample_list[3], ".vcf.txt"))
    if(file.exists(file_path))
      sample3 <- read.table(file_path,sep = '\t',header = T, stringsAsFactors = FALSE)
  }

  ## 2. Statistical variation types
  list_stat <- function(dat) {
    dat$change <- ifelse(dat$TYPE == 'snp', paste(dat$REF, dat$ALT, sep = '=>'), NA)
    dat=data.frame(seq_ID=dat$CHR,seq_stat=dat$POS,seq_end=dat$POS,type=dat$TYPE,change=dat$change,ratio=dat$QUAL)
    dat <- list(dat[which(dat$type == 'snp'& (dat$change == 'A=>T'|dat$change == 'T=>A')), ],
                dat[which(dat$type == 'snp'& (dat$change == 'A=>G'|dat$change == 'T=>C')), ],
                dat[which(dat$type == 'snp'& (dat$change == 'A=>C'|dat$change == 'T=>G')), ],
                dat[which(dat$type == 'snp'& (dat$change == 'G=>A'|dat$change == 'C=>T')), ],
                dat[which(dat$type == 'snp'& (dat$change == 'G=>T'|dat$change == 'C=>A')), ],
                dat[which(dat$type == 'snp'& (dat$change == 'G=>C'|dat$change == 'C=>G')), ],
                dat[which(dat$type == 'ins'), ],
                dat[which(dat$type == 'del'), ])
    return(dat)
  }
  
  list_check <- function(dat) {
    new_row <- data.frame(seq_ID = genome_name, seq_strat = 0, seq_end = 0, type = '', change = '', ratio = 0)
    dat <- lapply(dat, function(df) {
      if (is.null(df) || nrow(df) == 0) {
        return(new_row)
      } else {
        return(df)
      }
    })
    return(dat)
  }

  if(!is.na(sample_list[1])){sample1_list <- list_check(list_stat(sample1))}
  if(!is.na(sample_list[2])){sample2_list <- list_check(list_stat(sample2))}
  if(!is.na(sample_list[3])){sample3_list <- list_check(list_stat(sample3))}

  ## 3. plot
  progress$set(0.8, message = 'Plotting...')
  drawCircosPlot <- function(savePdf = FALSE) {
    circos.clear()
    circle_size = unit(1, 'snpc')
    circos.par(gap.degree = 3, start.degree = 90)

    circos.genomicInitialize(seq_stat, plotType = c('axis'), major.by = 200000, track.height = 0.05)
    circos.genomicTrackPlotRegion(
      seq_stat, track.height = 0.05, stack = TRUE, bg.border = NA,
      panel.fun = function(region, value, ...) {
        circos.genomicRect(region, value, col = '#049a0b', border = NA, ...)
      } )

    color_assign <- c('#BC80BD', '#FDB462', '#80B1D3', '#FB8072', '#8DD3C7', '#FFFFB3', 'red', 'blue')
    plot_circos <- function(dat, sampleID) {
      circos.genomicTrackPlotRegion(
        dat, track.height = 0.12, bg.border = 'black', bg.lwd = 0.4,
        panel.fun = function(region, value, ...) {
          if(region[[1]][1] == 0) return(NULL)
          circos.genomicPoints(region, value, pch = 16, cex = 0.5, col = color_assign[getI(...)], ...)
          circos.yaxis(labels.cex = 0.2, lwd = 0.1, tick.length = convert_x(0.15, 'mm'))
          xlim = CELL_META$xlim
          ylim = CELL_META$ylim
          circos.text(mean(xlim), mean(ylim), sampleID, cex = 0.7, col = 'black', facing = 'inside', niceFacing = TRUE)
        } )
    }
    if(!is.na(sample_list[1])){plot_circos(sample1_list, sample_list[1])}
    if(!is.na(sample_list[2])){plot_circos(sample2_list, sample_list[2])}
    if(!is.na(sample_list[3])){plot_circos(sample3_list, sample_list[3])}

    snv_legend <- Legend(
      at = c(1, 2, 3, 4, 5, 6, 7, 8),
      labels = c(' SNP: A>T|T>A', ' SNP: A>G|T>C', ' SNP: A>C|T>G', ' SNP: G>A|C>T', ' SNP: G>T|C>A', ' SNP: G>C|C>G', ' InDel: insert', ' InDel: delet'),
      labels_gp = gpar(fontsize = 6), title = 'variance type', title_gp = gpar(fontsize = 7),
      grid_height = unit(0.4, 'cm'), grid_width = unit(0.4, 'cm'), type = 'points', background = NA,
      legend_gp = gpar(col = c('#BC80BD', '#FDB462', '#80B1D3', '#FB8072', '#8DD3C7', '#FFFFB3', 'red', 'blue')) )
    pushViewport(viewport(x = 0.5, y = 0.5))
    grid.draw(snv_legend)
    upViewport()
    circos.clear()
  }

  ## save
  pdf_dir_path = file.path(dir_path, 'pdf')
  if (!dir.exists(pdf_dir_path)) {
      dir.create(pdf_dir_path, recursive = TRUE)
  }  
  pdf_path = file.path(pdf_dir_path,'snp_circle_sample.pdf')
  pdf(pdf_path)
  drawCircosPlot(savePdf = TRUE)  
  dev.off()

  drawCircosPlot(savePdf = FALSE) 
  progress$close()
}
