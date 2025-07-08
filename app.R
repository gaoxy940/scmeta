#### start app ####

library(shiny)
library(shinyWidgets)
library(progress)
library(plotly)
library(reshape2)
library(DT)
library(grid)
library(umap)
library(broom)
library(networkD3)
library(sunburstR)
library(dplyr)
library(tidyverse)
library(jsonlite)
library(RColorBrewer)
library(iheatmapr)
library(limma)
library(data.table)
library(htmlwidgets)
library(circlize)
library(ComplexHeatmap)
library(pheatmap)
library(stringr)
library(ggtree)
library(ape)
library(shinydashboard)
library(shinycssloaders)
library(shinyjs)
shinyjs::useShinyjs()
library(fastcluster)
library(Biostrings)
library(vegan)
#library(sendmailR)


source('basic/inc.R')
source('core/1_data_upload/init.R')
source('core/2_quality_control/init.R')
source('core/3_species_annotation/init.R')
source('core/4_function_annotation/init.R')
source('core/5_snp_analysis/init.R')
source('core/6_submit_task/init.R')
source('core/help/init.R')


options(shiny.maxRequestSize=10*1024^3)


ui <- fluidPage(

  navbarPage(

    title = div(tags$img(src = "logo_scmeta.png", 
        style = "display: block; 
        margin-left: auto; margin-right: auto; 
        margin-top: -13px; margin-bottom: 0;
        height: 50px; width: auto;")),
    inverse = T,collapsible = T,

      tabPanel("Project List", br(), core.data_upload.UI),
      tabPanel("Quality Control", br(), core.quality_control.UI),
      tabPanel("Species Annotation", br(), core.species_annotation.UI),
      tabPanel("Gene Ontology Analysis", br(), core.function_annotation.UI),
      tabPanel("SNP & Subspecies", br(), core.snp_analysis.UI),
      tabPanel("Submit Task", br(), core.submit_task.UI),
      tabPanel("Help", br(), core.help.UI),
             
  ),

  hr(),
  br(),

  tags$div(
    style = "text-align: center;",
    tags$img(src = "logo_jinfeng.png", height = "40px", style = "display: block; margin: auto; margin-bottom: 10px;")
  )

)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  core.data_upload(input, output, session)
  core.quality_control(input, output, session)
  core.species_annotation(input, output, session)
  core.function_annotation(input, output, session)
  core.snp_analysis(input, output, session)
  core.submit_task(input, output, session)
  core.help(input, output, session)
  
}

# Run the application 

shinyApp(ui = ui, server = server)
# shiny::runApp('app.R', host = '0.0.0.0', port = 80, launch.browser = FALSE)
