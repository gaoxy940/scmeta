#### SET HELP ####
help.anno <- fluidPage(
  fixedRow(
        class = "scrollable-container",
    column(width = 11,
           h3('Species Annotation'), br(),
           
           p(style = 'word-break:break-word',
             '
             Two common tools for annotating microbial species are provided: Kraken2 (version 2.1.3) and MetaPhlAn4 (version 4.1.1).
             '
           ),
           p(style = 'word-break:break-word',
             '
             Kraken2 is a rapid species classification tool based on K-mer. 
             It uses a pre-built database to compare sequencing data with k-mers in the database to determine the species to which the sequencing data belongs.
             '
           ),
           p(style = 'word-break:break-word',
             '
             Metamilan4 is a marker gene-based microbiome species annotation tool. 
             It uses a pre-constructed marker gene database to compare the marker genes found in sequencing data with those in the database.
             '
           ),
           p(style = 'word-break:break-word',
             '
             The confidence level corresponds to the annotation results, user can customize a threshold to filter the trusted annotations.
             '
           ),

           
           p(style = 'word-break:break-word',
             '
             The species annotation information will be displayed in the lower right corner of the table, along with the Sankey and Sunburst diagrams to show the species composition. 
             If a grouping is present, a stacked histogram for the grouping will be shown.
             '
           ),
           
           hr(),
           
           tags$ol(
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_ui_01.png'), br(), br(),
             tags$li(tags$b('Annotation Methods:'), br(),
                     '
                     There are two tools available for selection: Kraken2 and Metaphlan4. 
                     In the analysis of species annotation for individual microbial cells, we observed that while Metaphlan4 demonstrated a higher confidence level, 
                     Kraken2 was able to achieve comparable annotation accuracy in a shorter time frame.
                     '), br(),
             tags$li(tags$b('The reference database of Kraken2:'), br(),
                     '
                     Three databases of varying sizes and types are available, allowing users to select the one that best suits the background and objectives of their experiment. 
                     Scheme 1 includes Standard + Protozoa + Fungi (16 GB), Scheme 2 includes Standard + Protozoa + Fungi (69 GB), and Scheme 3 includes Standard + Protozoa + Fungi + Plant (144 GB). 
                     While larger databases generally provide higher operational accuracy, they also require more time to process.
                     '), br(),
             tags$li(tags$b('Annotation Percentage Threshold:'), br(),
                     '
                     The species annotation confidence is set at a default of 60%. 
                     Samples with a confidence level below this threshold will be annotated as "UnClassified".
                     '), br(),
             tags$li(tags$b('Run Species Annotation:'), br(),
                     'Click the button to execute the operation.'), br(),

             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_ui_02.png'), br(), br(),
             tags$li(tags$b('Show the Annotation Level:'), br(),
                     'Select and view the sample annotation at a specific annotation level, including phylum, class, order, family, genus, and species.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_sunburst.png'), br(), br(),
             tags$li(tags$b('Sunburst:'), br(),
                     'A Sunburst map displaying all the samples. Hovering over the map will reveal the proportion of each annotation.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_sankey.png'), br(), br(),
             tags$li(tags$b('Sankey:'), br(),
                     'A Sankey diagram displaying all the samples. Hovering over the diagram will reveal the proportion of each annotation.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_group_bar.png'), br(), br(),
             tags$li(tags$b('Group Bar:'), br(),
                     'A grouped species stacked bar plot is displayed when a grouping exists.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_anno_confirm.png'), br(), br(),
             tags$li(tags$b('Annotation confirm:'), br(),
                     'The table of species annotations is presented below. The row names correspond to the samples. The first column contains the overall annotation information, followed by columns for phylum, class, family, and species annotations. The final column indicates the percentage of confidence for each annotation.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_anno_level.png'), br(), br(),
             tags$li(tags$b('Annotation level:'), br(),
                     'The confidence matrix for the sample, based on the species annotation, is presented according to the annotation level selected by the user.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/anno/image_anno_group.png'), br(), br(),
             tags$li(tags$b('Annotation Frequency by Groups:'), br(),
                     'The Annotation table is organized at the species level, with the following columns: Group (control or treat) , Annotation (which varies according to the selected Annotation level), and Frequency (the number of samples).'), br(),
             
           )
           
    )
  )
)
