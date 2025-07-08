#### help ####
source('core/help/helps/inc.R')


core.help.UI <- fluidPage(

    tags$head(
        tags$style(HTML("
        /* Add custom CSS to enable scroll bars */
        .scrollable-container {
            overflow-x: auto;
            overflow-y: auto;
            height: 700px; /* Set the height as needed */
        }
        "))
    ),

    navlistPanel(
        tabPanel("Introduction", help.introduction),
        "-----",
        tabPanel("Project List", help.proj_list),
        tabPanel("Quality Control", help.qc),
        tabPanel("Species Annotation", help.anno),
        tabPanel("Gene Ontology Analysis", help.func_anno),
        tabPanel("SNP & Subspecies", help.snp),
        tabPanel("Submit Task", help.submit),
        "-----",
        tabPanel("Contact Us", help.contact),
    )

)## end ui

core.help <- function(input, output, session){} 

shinyApp(core.help.UI, core.help)