# func.get_snp_hclust_tab

core.snp_analysis.func.get_snp_hclust_tab <- function(dbpath, proj.id, species_name, dist_method, hclust_treenum){

    if (is.null(dbpath)) {return(NULL)}
    if (is.null(proj.id)) {return(NULL)}
    if (is.null(hclust_treenum)) {return(NULL)}
    if (is.null(dist_method)) {return(NULL)}
    
    dir_path = file.path(dbpath, proj.id, 'result/snippy',species_name)
    file_path.snp_matrix = file.path(dir_path,'snp_matrix.txt')
    if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 10 * 1024) {return(NULL)}
    snp <- read.table(file_path.snp_matrix, sep='\t', comment.char="", header = T)
    rownames(snp) <- paste0(snp$CHR,'_',snp$POS)

    # dist matrix
    if(dist_method == 'BLAST Soring Matrix'){
      ## BLAST Soring Matrix
      snp <- snp %>% mutate(across(-c(CHR, POS), ~ ifelse(. == REF, 2, -3)))
      CHR_index <- which(names(snp) == "CHR")
      POS_index <- which(names(snp) == "POS")
      REF_index <- which(names(snp) == "REF")
      snp <- snp[,-c(CHR_index, POS_index, REF_index)]
      snp <- t(snp)
      string_dist <- dist(snp, method = "manhattan")
      string_dist <- scale(string_dist)
    }else{      
      CHR_index <- which(names(snp) == "CHR")
      POS_index <- which(names(snp) == "POS")
      REF_index <- which(names(snp) == "REF")
      snp <- snp[,-c(CHR_index, POS_index, REF_index)]
      strings <- apply(snp, 2, function(col) {paste(col, collapse = "")})
      ### 5-mers
      dna <- DNAStringSet(strings)
      kmer <- oligonucleotideFrequency(DNAStringSet(dna), 5L)
      rownames(kmer)=names(strings)
      if(dist_method == 'Jaccard Distance of 5-mers'){
        ## Jaccard Distance of 5-mers
        string_dist <- vegdist(kmer, method = "jaccard")
      }else if(dist_method == 'Bray-Curtis Distance of 5-mers'){
        ## Bray-Curtis of 5-mers
        string_dist <- vegdist(kmer, method = "bray")
      }
    }
    
    dist_df <- as.data.frame(as.matrix(string_dist))
    
    # clusters   
    hclusters <- cutree(hclust(as.dist(string_dist), method = "ward.D2"), k = hclust_treenum)
    clusters <- data.frame(sample = names(hclusters), hcluster = (paste0('Cluster', hclusters)))
    rownames(clusters) = clusters$sample

    # save
    write.table(clusters, file = file.path(dir_path,'snp_hcluster.tab.txt'), quote = F)
    write.table(dist_df, file = file.path(dir_path,'snp_matrix_dist.txt'), quote = F)

}