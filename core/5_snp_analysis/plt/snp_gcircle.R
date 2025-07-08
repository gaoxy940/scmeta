# plot snp circle of snp density

core.snp_analysis.plt.snp_gcircle <- function(dbpath, proj.id, species_name, ref_filename){
  
  if (is.null(dbpath)) {return(NULL)}
  if (is.null(proj.id)) {return(NULL)}
  if (is.null(species_name)) {return(NULL)}
  if (is.null(ref_filename) || ref_filename == '') {return(NULL)}

  progress <- Progress$new();
  progress$set(0.3, message = 'Reading...')

  dir_path = file.path(dbpath, proj.id, 'result/snippy',species_name)
  seq_split <- 2000    # windows size
  
  ## 1. size.genome & windows.gc.txt
  file_path.size.genome = file.path(dir_path,'size.genome')
  file_path.windows.gc = file.path(dir_path,'windows.gc.txt')
  if(!file.exists(file_path.size.genome) || !file.exists(file_path.windows.gc)){
    system(paste("/bin/bash script/run_windows.gc.sh",dir_path,ref_filename,seq_split))
  }
  
  seq_stat <- read.table(file_path.size.genome, sep = '\t')
  seq_stat <- as.data.frame(cbind(seq_stat[, 1], 1, seq_stat[, 2]))
  colnames(seq_stat) <- c('seq_ID','seq_start','seq_end')
  seq_stat$seq_start <- as.numeric(seq_stat$seq_start)
  seq_stat$seq_end <- as.numeric(seq_stat$seq_end)
  genome_size <- seq_stat[1,3]
  
  gc_base <- read.table(file_path.windows.gc, sep = '\t')
  colnames(gc_base) <- c('seq_ID','seq_start','seq_end','GC')
  gc_base$GC <- gc_base$GC * 100
  genome_GC <- round(mean(gc_base$GC), 2)

  ## 2. snp density
  file_path.gcirclize_snp = file.path(dir_path,'gcirclize_snp.txt')
  file_path.gcirclize_snp_stat = file.path(dir_path,'gcirclize_snp_stat.txt')
  
  file_path.snp_matrix = file.path(dir_path,'snp_matrix.txt')
  if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 10 * 1024){
    showModal(modalDialog(
            title = "Illegal Operation",
            "Please run the program first!",
            alertType = "error"
          ))
    progress$close()
    return(NULL)
  }

  snp <- read.table(file_path.snp_matrix, sep = '\t', header = T)
  snp <- snp %>%
  mutate(across(-c(POS, CHR, REF), ~ ifelse(. == REF, NA, .)))
  
  alt_columns <- setdiff(names(snp), c("POS", "CHR", "REF"))
  for (col in alt_columns) {
    if (any(!is.na(snp[[col]]))) {
      snp[[col]][!is.na(snp[[col]])] <- paste(snp$REF[!is.na(snp[[col]])], snp[[col]][!is.na(snp[[col]])], sep = "")
    }
  }

  # 2.1 Initialize counter
  snp_ti <- 0
  snp_tv <- 0
  snp_at <- 0
  snp_ag <- 0
  snp_ac <- 0
  snp_ga <- 0
  snp_gt <- 0
  snp_gc <- 0

  for (col in alt_columns) {
    snp_ti <- snp_ti + sum(snp[[col]] %in% c("AG", "TC", "GA", "CT"))
    snp_tv <- snp_tv + sum(snp[[col]] %in% c("AT", "AC", "TA", "TG", "GT", "GC", "CA", "CG"))
    snp_at <- snp_at + sum(snp[[col]] %in% c("AT", "TA"))
    snp_ag <- snp_ag + sum(snp[[col]] %in% c("AG", "TC"))
    snp_ac <- snp_ac + sum(snp[[col]] %in% c("AC", "TG"))
    snp_ga <- snp_ga + sum(snp[[col]] %in% c("GA", "CT"))
    snp_gt <- snp_gt + sum(snp[[col]] %in% c("GT", "CA"))
    snp_gc <- snp_gc + sum(snp[[col]] %in% c("GC", "CG"))
  }

  # 2.2 calculate snps -> snp$srr_num
  snp$srr_sum <- rowSums(!is.na(snp[alt_columns]) & snp[alt_columns] != "")
  snp <- snp[, c("CHR","POS","REF","srr_sum")]
  colnames(snp)[1:2] <- c('seq_ID', 'seq_site')
    
  # 2.3 calculate the density of SNPs in each seq_split window size -> snp_stat
  snp_stat <- NULL
  seq_ID <- unique(snp$seq_ID)

  for (seq_ID_n in seq_ID) {
    snp_subset <- subset(snp, seq_ID == seq_ID_n)
    seq_end <- seq_split
    snp_num <- 0  
    for (i in 1:nrow(snp_subset)) {
      if (snp_subset[i,'seq_site'] <= seq_end) snp_num <- snp_num + snp_subset[i,'srr_sum']
      else {
        snp_stat <- rbind(snp_stat, c(seq_ID_n, seq_end - seq_split + 1, seq_end, snp_num))
        seq_end <- seq_end + seq_split
        snp_num <- 0
        while (snp_subset[i,'seq_site'] > seq_end) {
          snp_stat <- rbind(snp_stat, c(seq_ID_n, seq_end - seq_split + 1, seq_end, snp_num))
          seq_end <- seq_end + seq_split
        }
        snp_num <- snp_num + snp_subset[i,'srr_sum']
      }
    }  
    while (seq_end < seq_stat[nrow(seq_stat),'seq_end']) {
      snp_stat <- rbind(snp_stat, c(seq_ID_n, seq_end - seq_split + 1, seq_end, snp_num))
      seq_end <- seq_end + seq_split
      snp_num <- 0
    }
    snp_stat <- rbind(snp_stat, c(seq_ID_n, seq_end - seq_split + 1, seq_stat[nrow(seq_stat),'seq_end'], snp_num))
  }

  snp_stat <- data.frame(snp_stat, stringsAsFactors = FALSE)
  names(snp_stat) <- c('seq_ID', 'seq_start', 'seq_end', 'snp_num')
  snp_stat$seq_ID <- as.character(snp_stat$seq_ID)
  snp_stat$seq_start <- as.numeric(snp_stat$seq_start)
  snp_stat$seq_end <- as.numeric(snp_stat$seq_end)
  snp_stat$snp_num <- as.numeric(snp_stat$snp_num)

  # save
  write.table(snp, file_path.gcirclize_snp, sep = '\t',row.names = F,quote = F)
  write.table(snp_stat, file_path.gcirclize_snp_stat, sep = '\t',row.names = F,quote = F)
  write.table(seq_stat, file.path(dir_path,'gcirclize_seq_stat.txt'), sep = '\t',row.names = F,quote = F)

  ## 3. plot
  progress$set(0.8, message = 'Plotting...')
  drawCircosPlot <- function() {
    circos.clear()
    circle_size = unit(1, 'snpc')
    circos.par(gap.degree = 2, start.degree = 90)

    circos.genomicInitialize(seq_stat, plotType = c('axis', 'labels'), major.by = 200000, track.height = 0.05)
    circos.genomicTrackPlotRegion(
      seq_stat, track.height = 0.05, stack = TRUE, bg.border = NA,
      panel.fun = function(region, value, ...) {
        circos.genomicRect(region, value, col = '#049a0b', border = NA, ...)
    })

    circos.genomicTrack(
      gc_base, track.height = 0.08, bg.col = '#EEEEEE6E', bg.border = NA,
      panel.fun = function(region, value, ...) {
        circos.genomicLines(region, value, col = 'blue', lwd = 0.35, ...)
        circos.lines(c(0, max(region)), c(genome_GC, genome_GC), col = 'blue2', lwd = 0.15, lty = 2)
        circos.yaxis(labels.cex = 0.2, lwd = 0.1, tick.length = convert_x(0.15, 'mm'))
    })

    value_max <- max(snp_stat$snp_num)
    colorsChoice <- colorRampPalette(c('white', 'red3'))
    color_assign <- colorRamp2(breaks = c(0:value_max), col = colorsChoice(value_max + 1))
    circos.genomicTrackPlotRegion(
      snp_stat, track.height = 0.08, stack = TRUE, bg.border = NA,
      panel.fun = function(region, value, ...) {
        circos.genomicRect(region, value, col = color_assign(value[[1]]), border = NA, ...)
    })

    gc_legend <- Legend(
      at = 1, labels = c(str_c('GC % ( Average: ', genome_GC, ' % )')), labels_gp = gpar(fontsize = 7),
      grid_height = unit(0.5, 'cm'), grid_width = unit(0.5, 'cm'), type = 'lines', background = '#EEEEEE6E', 
      legend_gp = gpar(col = 'blue', lwd = 0.5))
    snp_legend <- Legend(
      at = round(seq(0, max(snp_stat$snp_num), length.out = 6), 0), labels_gp = gpar(fontsize = 6),
      col_fun = colorRamp2(round(seq(0, max(snp_stat$snp_num), length.out = 6), 0), colorRampPalette(c('white', 'red3'))(6)),
      title_position = 'topleft', title = 'SNP density', legend_height = unit(4, 'cm'), title_gp = gpar(fontsize = 7))
    stat_legend <- Legend(
      at = 1, labels = '1', labels_gp = gpar(fontsize = 0), title_gp = gpar(fontsize = 7), 
      grid_height = unit(0, 'cm'), grid_width = unit(0, 'cm'), type = 'points', pch = NA, background = NA, 
      title = str_c('Sample: ', species_name, '\nRefer species:\n', ref_filename, '\nRefer size: ', genome_size, ' bp\nRefer GC: ', genome_GC, '\nSliding window size: 2000bp', ' %\n\nTotal SNP: ', snp_ti + snp_tv, '\nA>T|T>A: ', snp_at, '\nA>G|T>C: ', snp_ag, '\nA>C|T>G: ', snp_ac, '\nG>A|C>T: ', snp_ga, '\nG>T|C>A: ', snp_gt, '\nG>C|C>G: ', snp_gc, '\nTi/Tv: ', round(snp_ti / snp_tv, 2)))

    y_coord <- 0.5
    x_coord <- 0.5
    pushViewport(viewport(x = x_coord + 0.16, y = y_coord + 0.09))
    grid.draw(gc_legend)
    upViewport()
    pushViewport(viewport(x = x_coord + 0.11, y = y_coord - 0.08))
    grid.draw(snp_legend)
    upViewport()
    pushViewport(viewport(x = x_coord - 0.05, y = y_coord - 0.03))
    grid.draw(stat_legend)
    upViewport()
    circos.clear()
  }

  ## save
  pdf_dir_path = file.path(dir_path, 'pdf')
  if (!dir.exists(pdf_dir_path)) {
      dir.create(pdf_dir_path, recursive = TRUE)
  }  
  
  pdf_path = file.path(pdf_dir_path,'snp_circle_genome.pdf')
  pdf(pdf_path)
  drawCircosPlot()  
  dev.off()

  drawCircosPlot()  

  progress$close()

}
