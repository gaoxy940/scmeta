# func.get_snp_species_tab

core.snp_analysis.func.get_snp_species_tab <- function(dbpath, proj.id, file_pre, anno_level, species_name){

    if(is.null(dbpath)) {return(NULL)}
    if(is.null(proj.id)) {return(NULL)}
    if(is.null(file_pre) || file_pre == '') {
        showModal(modalDialog(
            title = "Operation Error",
            "Unable to find the corresponding annotation information, please run the 'Species Annotation' module first!",
            alertType = "warning"
        ))
        return(NULL)
    }

    dir_path = file.path(dbpath, proj.id, 'result/snippy',species_name)
    if (!dir.exists(dir_path)) {
        dir.create(dir_path, recursive = TRUE)
    }

    file_path.snp_species = file.path(dir_path, 'snp_species.txt')
    if(!file.exists(file_path.snp_species)){

        file_path.anno_confirm = file.path(dbpath, proj.id, paste0(file_pre, '_annotation.confirm.txt'))        
        if(!file.exists(file_path.anno_confirm)) {
            showModal(modalDialog(
                title = "Operation Error",
                "Unable to find the corresponding annotation information, please run the 'Species Annotation' module first!",
                alertType = "warning"
            ))
            return(NULL)
        }
        
        anno <- read.table(file_path.anno_confirm, header = T, row.names = 1)
        # check for reliable annotations above the threshold
        anno <- anno[anno$Percentage != "UnClassified", ]
        if(nrow(anno) == 0){
            showModal(modalDialog(
            title = "Warning",
            "No reliable annotation were found, please set a lower threshold",
            alertType = "warning"
            ))
            return(NULL)
        }

        anno_list = gsub(".*__", "", anno[[anno_level]])
        snp_species = data.frame(Sample=rownames(anno),Species=anno_list)
        snp_species = subset(snp_species, Species == species_name)

        # save
        write.table(snp_species, file_path.snp_species, sep='\t', row.names=F, quote = F)

    }      

}