#### quality control ####

source('core/2_quality_control/plt/feature_vln.R')
source('core/2_quality_control/Dui/filter_ui.R')
source('core/2_quality_control/tab/fastp_summary.R')
source('core/2_quality_control/tab/fastp_summary_filter.R')


core.quality_control.UI <- fluidPage(

  sidebarLayout(
    sidebarPanel(width = 5,

                 h4('Step1. Quality Control with Fastp'),
                 br(),
                 actionButton(inputId = 'run_fastp', label = 'Run Quality Control', icon = icon('play')),
                 br(),

                 hr(),                 

                 h4('Step2. Filter Sample'),                 
                 # Filter Sample
                 radioGroupButtons(inputId = 'qc_filter', 
                                   label = '', 
                                   choices = c('Yes','No'), 
                                   selected = 'No', 
                                   size = 'sm'),
                 conditionalPanel(
                  condition ="input.qc_filter == 'Yes'",
                  uiOutput('qc_Total_reads'),
                  uiOutput('qc_Clean_reads'),
                  uiOutput('qc_Cut_reads'),
                  uiOutput('qc_Q30_rates'),
                  uiOutput('qc_GC_connects'),
                  uiOutput('qc_Duplication'),
                  fluidRow(
                    column(6, actionButton(inputId = 'run_qc_filter_reset', label = 'Reset', icon = icon('puzzle-piece')), align = 'left'),
                    column(6, actionButton(inputId = 'run_qc_filter', label = 'Filter', icon = icon('play')), align = 'right'),
                  ),
                 ),
 
    ),## end sidebarPanel
    
    mainPanel(width = 7,
              fluidRow(
                column(6, plotlyOutput('plt_qc_cleanreads')),
                column(6, plotlyOutput('plt_qc_q30'))
              ),
              
              hr(),

              tabsetPanel(
                tabPanel('Fastp Summary Table', br(), dataTableOutput('tab_fastp_summary')),
              ),
              
    )## end mainPanel
  )## end sidebarLayout
)## end ui

core.quality_control <- function(input, output, session){

    #### INITIALIZE UI ####
    output$qc_Total_reads <- renderUI(
      core.quality_control.Dui.filter_ui(DBPATH(), PROJ.ID(),
                                        'qc_Total_reads','Total reads','Total_reads', 10000, input$run_qc_filter_reset)
    )

    output$qc_Clean_reads <- renderUI(
      core.quality_control.Dui.filter_ui(DBPATH(), PROJ.ID(),
                                        'qc_Clean_reads','Clean reads','Clean_reads', 10000, input$run_qc_filter_reset)
    )

    output$qc_Cut_reads <- renderUI(
      core.quality_control.Dui.filter_ui(DBPATH(), PROJ.ID(),
                                        'qc_Cut_reads','Cut reads','Cut_reads', 20, input$run_qc_filter_reset)
    )

    output$qc_Q30_rates <- renderUI(
      core.quality_control.Dui.filter_ui(DBPATH(), PROJ.ID(),
                                        'qc_Q30_rates','Q30 rates','Q30_rates', 1, input$run_qc_filter_reset)
    )

    output$qc_GC_connects <- renderUI(
      core.quality_control.Dui.filter_ui(DBPATH(), PROJ.ID(),
                                        'qc_GC_connects','GC connects','GC_connects', 1, input$run_qc_filter_reset)
    )

    output$qc_Duplication <- renderUI(
      core.quality_control.Dui.filter_ui(DBPATH(), PROJ.ID(),
                                        'qc_Duplication','Duplication','Duplication', 0.1, input$run_qc_filter_reset)
    )


    #### ACTIVITY ####
    ## Run Fastp
    observeEvent(input$run_fastp,{
      
      proj_id = PROJ.ID()      

      # code
      file_path.fastp_summary = file.path(DBPATH(), proj_id, 'result/fastp/fastp_summary.txt')
      if(!file.exists(file_path.fastp_summary) || file.size(file_path.fastp_summary) == 0) {

        showPageSpinner(type = 1, background = "#FFFFFF30")
        progress <- Progress$new();
        progress$set(0.4, message = 'Run Fastp...')
        # system2(paste("/bin/bash script/run_fastp.sh",file.path(DBPATH(), proj_id), ">", file.path(DBPATH(), proj_id, 'result/log.run_fastp.txt'), "2>&1"), wait = FALSE)
        system2(
          command = "/bin/bash",
          args = c(
            "script/run_fastp.sh",
            file.path(DBPATH(), proj_id)
          ),
          stdout = file.path(DBPATH(), proj_id, 'result/log.run_fastp.txt'),
          stderr = file.path(DBPATH(), proj_id, 'result/log.run_fastp.txt'),
          wait = FALSE
        )

        # Polls every 5 seconds for the completion of an asynchronous instruction.
        script_running <- reactiveVal(TRUE)
        observe({        
          if (script_running()) {
            invalidateLater(5000)          
            if (file.exists(file_path.fastp_summary)) {
              # Refresh Plot
              progress$set(0.9, message = 'Refresh Plot...')
              output$plt_qc_cleanreads <- renderPlotly(
                core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Clean_reads')
              )
              output$plt_qc_q30 <- renderPlotly(
                core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Q30_rates')
              )
              # Refresh Table
              progress$set(0.9, message = 'Refresh Table...')
              output$tab_fastp_summary <- renderDT(server=FALSE,{
                  core.quality_control.tab.fastp_summary(DBPATH(), proj_id)
              })
              progress$close()
              hidePageSpinner()
              script_running(FALSE)
            }
          }
        })# end observe

      }else{

        progress <- Progress$new();
        progress$set(0.6, message = 'Refresh Plot...')
        # Refresh Plot
        output$plt_qc_cleanreads <- renderPlotly(
          core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Clean_reads')
        )
        output$plt_qc_q30 <- renderPlotly(
          core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Q30_rates')
        )
        progress$set(0.8, message = 'Refresh Table...')
        # Refresh Table
        output$tab_fastp_summary <- renderDT(server=FALSE,{
            core.quality_control.tab.fastp_summary(DBPATH(), proj_id)
        })
        progress$set(0.9, message = 'Finished')
        progress$close()

      }
 
    }, ignoreInit = T)

    ## Sample Filter
    observeEvent(input$run_qc_filter,{

        proj_id = PROJ.ID()
        Total_thr <- input$qc_Total_reads
        Clean_thr <- input$qc_Clean_reads
        Cut_thr <- input$qc_Cut_reads
        Q30_thr <- input$qc_Q30_rates
        GC_thr <- input$qc_GC_connects
        Duplication_thr <- input$qc_Duplication

        # Refresh Plot
        output$plt_qc_cleanreads <- renderPlotly(
          core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Clean_reads')
        )
        output$plt_qc_q30 <- renderPlotly(
          core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Q30_rates')
        )
        # Refresh table
        output$tab_fastp_summary <- renderDT(server=FALSE,{
            core.quality_control.tab.fastp_summary_filter(DBPATH(), proj_id,
                                                          Total_thr, Clean_thr, Cut_thr, Q30_thr, GC_thr, Duplication_thr)
        })

    })

    ## Sample Reset
    observeEvent(input$run_qc_filter_reset,{
    
      #restore filtered files
      proj_id = PROJ.ID()
      file.copy(file.path(DBPATH(), proj_id, 'result/fastp/fastp_summary.txt'),
       file.path(DBPATH(), proj_id, 'result/fastp/fastp_summary_filtered.txt'), overwrite = TRUE)
      file.copy(file.path(DBPATH(), proj_id, 'group.txt'),
       file.path(DBPATH(), proj_id, 'group_filtered.txt'), overwrite = TRUE)

      # Refresh Plot
      output$plt_qc_cleanreads <- renderPlotly(
        core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Clean_reads')
      )
      output$plt_qc_q30 <- renderPlotly(
        core.quality_control.plt.feature_vln(DBPATH(), proj_id, 'Q30_rates')
      )
      # Refresh table
      output$tab_fastp_summary <- renderDT(server=FALSE,{
        core.quality_control.tab.fastp_summary(DBPATH(), proj_id)
      })      

    })
      
} 

shinyApp(core.quality_control.UI, core.quality_control)
