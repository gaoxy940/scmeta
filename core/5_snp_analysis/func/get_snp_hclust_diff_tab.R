# fun.get_snp_hclust_diff_tab

core.snp_analysis.fun.get_snp_hclust_diff_tab <- function(dbpath, proj.id, species_name, cp, ct){

    if (is.null(dbpath)) {return(NULL)}
    if (is.null(proj.id)) {return(NULL)}
    
    file_path.snp_hcluster.tab = file.path(dbpath, proj.id, 'result/snippy',species_name, 'snp_hcluster.tab.txt')
    file_path.snp_matrix = file.path(dbpath, proj.id, 'result/snippy',species_name, 'snp_matrix.txt')
  
    if(!file.exists(file_path.snp_hcluster.tab)) {return(NULL)}
    snp_hclust <- read.table(file_path.snp_hcluster.tab, comment.char="", header = T)

    if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 10 * 1024) {return(NULL)}
    dt <- read.table(file_path.snp_matrix, sep='\t', comment.char="", header = T)
    rownames(dt) <- paste0(dt$CHR,'_',dt$POS)
    dt <- dt %>% mutate(across(-c(CHR, REF), ~ ifelse(. == REF, 0, 1)))
    CHR_index <- which(names(dt) == "CHR")
    POS_index <- which(names(dt) == "POS")
    REF_index <- which(names(dt) == "REF")
    dt <- dt[,-c(CHR_index, POS_index, REF_index)]
    # Transpose into rows as samples, cols as features
    # dt <- as.matrix(t(dt))

    #### limma diff analysis ####
    colnames(snp_hclust) = c('Sample', 'Cluster')
    design <- model.matrix(~0+factor(snp_hclust$Cluster))
    colnames(design)=levels(factor(snp_hclust$Cluster))
    rownames(design)=names(snp_hclust$Sample)

    # contrast.matrix
    num_levels <- ncol(design)
    contrast.matrix <- matrix(ncol = length(ct), nrow = num_levels, 0)
    rownames(contrast.matrix) <- colnames(design)
    colnames(contrast.matrix) <- paste0(cp, "-", unlist(ct))

    for (i in seq_along(ct)) {
    contrast.matrix[cp,i] <- 1
    contrast.matrix[ct[i],i] <- -1    
    }

    # fit
    fit <- lmFit(dt,design)
    fit2 <- contrasts.fit(fit, contrast.matrix)
    fit2 <- eBayes(fit2)
    tT = na.omit(topTable(fit2, n=Inf, adjust="BH"))
    tT <- tT[tT$adj.P.Val < 0.05, ]
    if(length(ct) == 1) {tT <- select(tT, -"t", -"B", -"AveExpr")}
    else if(length(ct) > 1) {tT <- select(tT, -"F", -"AveExpr")}
    
    # save
    fpath = file.path(dbpath, proj.id, 'result/snippy',species_name, 'snp_hcluster.diff.tab.txt')
    write.table(tT, file = fpath, quote = F)

    return(fpath)

}
