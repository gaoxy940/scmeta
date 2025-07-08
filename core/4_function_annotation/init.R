#### function annotation ####

source('core/4_function_annotation/tab/func_anno_records.R')
source('core/4_function_annotation/func/get_func_anno_list.R')
source('core/4_function_annotation/plt/func_anno_bar.R')
source('core/4_function_annotation/plt/func_anno_heatmap.R')


core.function_annotation.UI <- fluidPage(
  useShinyjs(),
  div(id = "content_func",
  sidebarLayout(
    sidebarPanel(width = 5,

                 h4('Step1. Functional Annotation with HUMAnN3'),
                 br(),
                 # RUN 
                 actionButton(inputId = 'run_func_anno', label = 'Run Functional Annotation', icon = icon('play')),
                 br(),

                 hr(),

                 h4('Step2. Pathway Visualization'), 
                 br(),
                 uiOutput('func_anno_list_Dui'),
                 br(),
                 # PLOT
                 actionButton(inputId = 'show_func_anno_bar', label = 'Show Barplot', icon = icon('play')),
                 br(),
 
    ),## end sidebarPanel
    
    mainPanel(width = 7,

              br(),
              tabsetPanel(
                tabPanel('Metabolic Barplot', br(),
                  conditionalPanel(
                    condition = "input.show_func_anno_bar > 0",
                    imageOutput("plt_func_anno_bar"),
                    downloadButton('dbtn_func_anno_bar', 'Download PNG', icon = shiny::icon("download"), class = "btn btn-primary pull-right"))
                ),
                tabPanel('KEGG HeatMAP', br(), 
                    plotOutput('plt_func_anno_heatmap'),
                    downloadButton('dbtn_func_anno_heatmap', 'Download PDF', icon = shiny::icon("download"), class = "btn btn-primary pull-right")
                ),

              ),

              hr(),

              br(),
              tabsetPanel(
                tabPanel('Metabolic Pathway', br(), dataTableOutput('tab_func_anno_summary')),
                tabPanel('KEGG Pathway', br(), dataTableOutput('tab_func_anno_kegg')),
              ),
              
    )## end mainPanel
  )## end sidebarLayout
  )## end div
)## end ui

core.function_annotation <- function(input, output, session){

  #### Task Params ####
  observeEvent(Task_Params(), {
    if (length(Task_Params()) > 1) {
      # func_anno
      if(Task_Params()$func_anno == 'No') {
        runjs("$('#content_func').css('opacity', '0.5'); $('#content_func').css('pointer-events', 'none');")
      }
    } else {
      runjs("$('#content_func').css('opacity', '1'); $('#content_func').css('pointer-events', 'auto');")
    }
  })

  #### INITIALIZE UI ####
  output$func_anno_list_Dui <- renderUI(  
    selectInput("func_anno_selected_pathway", 
                "Choose a pathway of interest to show", 
                core.function_annotation.func.get_func_anno_list(DBPATH(), PROJ.ID()))
  )

  #### ACTIVITY ####
  ## run_func_anno
  observeEvent(input$run_func_anno, {

    proj_id = PROJ.ID()
    
    progress <- Progress$new()
    showPageSpinner(type = 1, background = "#FFFFFF30")

    # code
    file_path.humann_pathabundance = file.path(DBPATH(), proj_id, 'result/humann3/pathabundance_relab_unstratified.tsv')
    if(!file.exists(file_path.humann_pathabundance) || file.size(file_path.humann_pathabundance) == 0) {

      # determine whether the critical step of quality control has been performed
      if (length(list.files(file.path(DBPATH(), proj_id, 'temp/fastp'), full.names = FALSE)) == 0){
        showModal(modalDialog(
            title = "Operation Error",
            "Please select a project from the 'Project List' and ensure that the raw data exists and the 'Quality Control' measures are in place!",
            alertType = "error"
          ))
          return(NULL)
      }
 
      progress$set(0.4, message = 'Run HUMAnN3...')
      system2(
          command = "/bin/bash",
          args = c(
            "script/run_humann3.sh",
            file.path(DBPATH(), proj_id)
          ),
          stdout = file.path(DBPATH(), proj_id, 'result/log.run_humann3.txt'),
          stderr = file.path(DBPATH(), proj_id, 'result/log.run_humann3.txt'),
          wait = FALSE
      )
      
    }# end if

    # Polls every 5 seconds for the completion of an asynchronous instruction.
    script_running <- reactiveVal(TRUE)
    observe({

      if (script_running()) {

        invalidateLater(5000)

        if (file.exists(file_path.humann_pathabundance)) {
          progress$set(0.8, message = 'Refresh Table...')
          # Table
          output$tab_func_anno_summary <- renderDT(server=TRUE,{
            core.function_annotation.tab.func_anno_summary(DBPATH(),
                                                    proj_id)
          })
          output$tab_func_anno_kegg <- renderDT(server=TRUE,{
            core.function_annotation.tab.kegg_pathway(DBPATH(),
                                                    proj_id)
          })
          # Plot
          output$plt_func_anno_heatmap <- renderPlot({        
            core.function_annotation.plt.heatmap(DBPATH(), proj_id)
          })

          updateSelectInput(session, "func_anno_selected_pathway", "Choose a pathway of interest to show",
                            choices = core.function_annotation.func.get_func_anno_list(DBPATH(),PROJ.ID()))

          progress$set(0.9, message = 'Finished')
          progress$close()
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe

  })

  ## show_func_anno_bar
  observeEvent(input$show_func_anno_bar, {

    proj_id = PROJ.ID()
    selected_pathway = sub(":.*$", "", input$func_anno_selected_pathway)

    showPageSpinner(type = 1, background = "#FFFFFF30")

    image_path <- core.function_annotation.plt.func_anno_bar(DBPATH(),proj_id,selected_pathway)

    if(is.null(image_path) || !file.exists(image_path)) {
      showModal(modalDialog(
        title = "Invalid Input",
        paste0("WARRING: Requested feature <",selected_pathway,"> was not stratified! You can choose another one and try again."),
        alertType = "warning"
      ))

      output$plt_func_anno_bar <- renderImage(list(src = '', contentType = "image/png", width = "100%", height = "100%"))

      hidePageSpinner()
    } else {
      # PLOT
      output$plt_func_anno_bar <- renderImage({
        list(src = image_path, contentType = "image/png", width = "100%", height = "100%")
      }, deleteFile = FALSE)

      hidePageSpinner()
    }
  })

  ## download png
  output$dbtn_func_anno_bar <- downloadHandler(
    filename = function() {
      'function_barplot.png'
    },
    content = function(file) {
      isolate({
        proj_id = PROJ.ID()
        selected_pathway = sub(":.*$", "", input$func_anno_selected_pathway)
        png_path = file.path(DBPATH(), proj_id, paste0("result/humann3/png/barplot_",selected_pathway,".png"))
        if(is.null(selected_pathway) || !file.exists(png_path)){
          showModal(modalDialog(
            title = "ERROR",
            "Illegal operation. Please run the program first!",
            alertType = "error"
          ))
          return(NULL)
        }
        showPageSpinner(type = 1, background = "#FFFFFF30")
        file.copy(png_path, file)
        hidePageSpinner()
      })
    }
  )
  output$dbtn_func_anno_heatmap <- downloadHandler(
    filename = function() {
      'function_heatmap.pdf'
    },
    content = function(file) {
      isolate({
        proj_id = PROJ.ID()
        pdf_path = file.path(DBPATH(), proj_id, 'result/humann3/png/heatmap_KEGG.Pathway.L2.pdf')
        if(!file.exists(pdf_path)){
          showModal(modalDialog(
            title = "ERROR",
            "Illegal operation. Please run the program first!",
            alertType = "error"
          ))
          return(NULL)
        }
        showPageSpinner(type = 1, background = "#FFFFFF30")
        file.copy(pdf_path, file)
        hidePageSpinner()
      })
    }
  )
  
} 

# CSS class
# addResource <- function() {
#   addCss(
#     HTML("
#       .centered-image-container {
#         text-align: center;
#       }
#     ")
#   )
# }

shinyApp(core.function_annotation.UI, core.function_annotation)
