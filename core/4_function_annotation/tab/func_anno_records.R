# refresh tab_func_anno_summary & kegg pathway

core.function_annotation.tab.func_anno_summary <- function(dbpath, proj_id) {
  
    if (is.null(dbpath)) {return(NULL)}
    if (is.null(proj_id)) {return(NULL)}

    file_path.humann_pathabundance = file.path(dbpath, proj_id, 'result/humann3/pathabundance_relab_unstratified.tsv')
    if(!file.exists(file_path.humann_pathabundance)) {return(NULL)}
    df <- read.csv(file_path.humann_pathabundance, row.names = 1, sep = '\t', header = T)
    # index1 <- which(names(df) == "UNMAPPED")
    # index2 <- which(names(df) == "UNINTEGRATED")
    # df <- df[,-c(index1, index2)]
    df <- df[-(1:2), ]

    for (col in names(df)) {
        if (is.numeric(df[[col]])) {
            df[[col]] <- round(df[[col]], 4)
        }
    }
    df <- df[order(-df[, 1]), ]
  
    tab <- datatable(df, selection = 'none', extensions = 'Buttons',
                    options = list(scrollX=TRUE, lengthMenu = c(20,25,30),
                                    dom = 'lftipB',
                                    buttons = c('copy', 'csv', 'excel','pdf')),
                    escape = F)

    return(tab)
  
}

core.function_annotation.tab.kegg_pathway <- function(dbpath, proj_id) {
  
    if (is.null(dbpath)) {return(NULL)}
    if (is.null(proj_id)) {return(NULL)}

    file_path.humann_kegg = file.path(dbpath, proj_id, 'result/humann3/KEGG.PathwayL2.raw.txt')
    if(!file.exists(file_path.humann_kegg)) {return(NULL)}
    df <- read.table(file_path.humann_kegg, sep = '\t', header = TRUE, row.names = 1 ,check.names = FALSE)
    # index1 <- which(names(df) == "UNMAPPED")
    # index2 <- which(names(df) == "UNINTEGRATED")
    # df <- df[,-c(index1, index2)]

    df <- df[order(-df[, 1]), ]
  
    tab <- datatable(df, selection = 'none', extensions = 'Buttons',
                    options = list(scrollX=TRUE, lengthMenu = c(20,25,30),
                                    dom = 'lftipB',
                                    buttons = c('copy', 'csv', 'excel','pdf')),
                    escape = F)

    return(tab)
  
}
