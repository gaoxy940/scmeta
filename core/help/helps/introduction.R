#### SET HELP ####
help.introduction <- fluidPage(
  fixedRow(
    class = "scrollable-container",
    column(width = 11,
           h3('Introduction'), br(),
           
           p(style = 'word-break:break-word',
             '
             scMETA is a web server for the analysis and visualization of single-cell metagenomes, 
             The platform supports raw sequencing data in FASTQ format and provides de novo analysis, 
             which includes data preprocessing, sample quality control, species annotation, functional identification, mutation analysis, subspecies clustering, and phylogenetic analysis. 
             Furthermore, it facilitates comparative analyses between strains and even among different bacterial cells. 
             
             With SCMeta, users can easily analyze data and generate publication-ready results through a code-free interface. 
             '
           ),
           
           p(style = 'word-break:break-word',
             '
             scMETA provides customized analyses and interactive data visualization services, enabling scientists, including those with limited programming skills, to easily analyze single-cell metagenomic data and generate publication-ready graphical results through a no-code interface. 
             All visualization results are available for download.
             '
           ),
           br(),           

           hr(),
           h3('General Interface Structure'), br(),

           p(style = 'word-break:break-word',
             '
             As shown in the figure below, the user inferface includes three areas: 
             ', tags$b('toolbar'), ' on the top, the major ', tags$b('manipulation area'), ' in the left side. 
             and ', tags$b('visualization area'), ' in the right side. 
             The manipulation area mainly includes parameter sub-area and control-panel, 
             which can be used for submitting parameters and selecting pipelines for data process. 
             In plot visualization area, there is dynamic plot and static plot, 
             which is synchronously displayed. 
             Interactive visualization also supports displaying a context or information depending on the object under the mouse cursor.
             '
           ),
           
           br(),        
           img(class='img-thumbnail', src = 'help_image/introduction/interface.png'), br(), br(),

           hr(),br(),
           h3('Analysis Tools'), br(),
           h4('Data Processing Packages'),br(),
           p('FastQC (version 0.12.1)'),
           p('FASTP (version 0.23.2)'),
           p('Bowtie (version 2.5.4)'),
           p('diamond (version 2.1.10)'),
           p('samtools (version 1.18)'),
           p('bcftools (version 1.21)'),
           p('bedtools (version v2.31.1)'),
           p('Kraken2 (version 2.1.3)'),
           p('Bracken (version2.9)'),
           p('MetaPhlAn4 (version 4.1.1)'),
           p('HUMAnN3 (version 3.7)'),
           p('snp-sites (version 2.5.1)'),
           p('Snippy (version 4.6.0)'),
           p('FastTree (version 2.1.11)'),
           p('R (version 4.3.3)'),
           p('R packages: ape, vegan, fastcluster, broom, tidyverse, limma, jsonlite, data.table, stringr ...'),
           

           br(),
           h4('Visualization Packages'),br(),
           p('Visualization packages is shiny (version 1.10.0) and plotly (version 4.10.4) for R that supports analysis through interactive data exploration on the platform.'),
           p('Other R packages: shinywidgets, shinybs, shinycssloaders, shinydashboard, progress, dt, magick, htmlwidgets, rcolorbrewer, iheatmapr, pheatmap, networkd3, circlize, sunburstr, ggtree ...'),
           
           br(),br(),
           img(class='img-thumbnail', src = 'help_image/introduction/workflow.png'), br(),
           

           
    )
  )
)
