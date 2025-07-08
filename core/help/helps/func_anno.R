#### SET HELP ####
help.func_anno <- fluidPage(
  fixedRow(
        class = "scrollable-container",
    column(width = 11,
           h3('Gene Ontology Analysis'), br(),
           
           p(style = 'word-break:break-word',
             '
             Microbial samples were functionally annotated using HUMAnN 3 (version 3.7). 
             HUMAnN 3 identifies functional genes within the microbiome and estimates their abundance by comparing sequencing data to pre-built databases, 
             including UNIREF90, eggNOG, and KEGG. It employs various alignment tools, such as DIAMOND and BLAST, to enhance the accuracy and coverage of gene recognition.
             '
           ),
           
           hr(),
           
           tags$ol(
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/func_anno/image_ui_01.png'), br(), br(),
             tags$li(tags$b('Run Function annotation:'), br(),
                     'Click the button to execute the operation.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/func_anno/image_ui_02.png'), br(), br(),
             tags$li(tags$b('Show barplot:'), br(),
                     'When the program is finished, it will return a list of functional comments in the drop-down box, from which user can select a pathway of interest to show.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/func_anno/image_pathway_barplot.png'), br(), br(),
             tags$li(tags$b('Metabolic Barplot:'), br(),
                     'This barplot illustrates the species distribution characteristics of the metabolic pathway of interest. Click the download button to save the image locally.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/func_anno/image_kegg_heatmap.png'), br(), br(),
             tags$li(tags$b('KEGG HeatMAP:'), br(),
                     'The KEGG pathway is presented as a heatmap to illustrate the differences in functional pathways expressed by various taxa.'), br(),
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/func_anno/image_metabolic_summary.png'), br(), br(),
             tags$li(tags$b('Metabolic Pathway:'), br(),
                     'Summary of metabolic pathways.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/func_anno/image_kegg_summary.png'), br(), br(),
             tags$li(tags$b('KEGG Pathway:'), br(),
                     'Summary of KEGG pathways.'), br(),
             
           )       
    )
  )
)
