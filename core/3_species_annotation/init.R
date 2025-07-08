#### species annotation ####

source('core/3_species_annotation/func/anno_confirm.R')
source('core/3_species_annotation/func/anno_groups.R')
source('core/3_species_annotation/tab/anno_records.R')
source('core/3_species_annotation/tab/groups_tab.R')
source('core/3_species_annotation/plt/anno_sankey.R')
source('core/3_species_annotation/plt/anno_sunburst.R')
source('core/3_species_annotation/plt/groups_bar.R')

core.species_annotation.UI <- fluidPage(
  sidebarLayout(
    sidebarPanel(width = 5,
                 
                 h4('Step1. Parameter Setting'),
                 br(),

                 radioButtons("anno_method", 
                              "Selection of species annotation methods", 
                              c('Kraken2','Metaphlan4'),
                              selected = 'Kraken2'),
                 
                 conditionalPanel(
                   condition ="input.anno_method == 'Kraken2'",
                   radioButtons("Kraken2_db", 
                                "Select the reference database of Kraken2", 
                                choices = c("Standard + Protozoa + Fungi 16G" = "pluspf16g",
                                  "Standard + Protozoa + Fungi 69G" = "pluspf",
                                  "Standard + Protozoa + Fungi + Plant 144G" = "pluspfp"),
                                selected = "pluspf16g"),
                   helpText('The larger the database you select, the longer the computation takes'),
                 ),                 
                 br(),
                 numericInput("anno_confirm_threshold",
                              "Set species annotation percentage threshold, recommended 60",
                              value=60, min = 0, max=100, step = 5),                 
                 br(),

                 # RUN
                 actionButton(inputId = 'run_species_annotation', label = 'Run Species Annotation', icon = icon('play')),
                 br(),

                 hr(),

                 h4('Step2. Select the Species Annotation Level to Show'),
                 br(),

                 radioButtons("anno_level_show", 
                              'Select the level to display in the "Annotation Level" table and "Groups Bar" chart', 
                              c('Species','Genus','Family','Order','Class','Phylum','Kingdom'),
                              selected = 'Genus'),
                 br(),
                 # SHOW
                 actionButton(inputId = 'show_species_annotation', label = 'Show the Level', icon = icon('list-check')),
                 
                 
    ),## end sidebarPanel
    
    mainPanel(width = 7,
              br(), 
              tabsetPanel(
                tabPanel('Sunburst', br(), sund2bOutput('plt_anno_sunburst'),
                ),
                tabPanel('Sankey', br(), plotlyOutput('plt_anno_sankey'),
                #column(2, offset = 10, actionButton('test','play'))
                ),                
                tabPanel('Groups Bar', br(), plotlyOutput('plt_anno_groups'))
              ),
              
              hr(),
              
              br(),
              tabsetPanel(
                tabPanel('Annotation Confirm', br(), dataTableOutput('tab_anno_confirm')),
                tabPanel('Annotation Level', br(), dataTableOutput('tab_anno_levels')),
                tabPanel('Annotation Fruquency by Groups', br(), dataTableOutput('tab_anno_groups')),
              ),
              
    )## end mainPanel
  )## end sidebarLayout
)## end ui

core.species_annotation <- function(input, output, session){ 
  
  #### Task Params - INITIALIZE UI ####
  observeEvent(Task_Params(), {
    if (length(Task_Params()) > 1) {
      # anno_method
      updateRadioButtons(session, "anno_method", choices = Task_Params()$anno_method)
      # anno_db
      if(Task_Params()$anno_db == "Standard + Protozoa + Fungi 16G") {
        updateRadioButtons(session, "Kraken2_db", choices = c("Standard + Protozoa + Fungi 16G" = "pluspf16g"))
      } else if(Task_Params()$anno_db == "Standard + Protozoa + Fungi 69G") {
        updateRadioButtons(session, "Kraken2_db", choices = c("Standard + Protozoa + Fungi 69G" = "pluspf"))
      } else if(Task_Params()$anno_db == "Standard + Protozoa + Fungi + Plant 144G") {
        updateRadioButtons(session, "Kraken2_db", choices = c("Standard + Protozoa + Fungi + Plant 144G" = "pluspfp"))
      }
      # anno_threshold
      updateNumericInput(session, "anno_confirm_threshold", value = Task_Params()$anno_threshold)
    } else {
      # anno_method
      updateRadioButtons(session, "anno_method", choices = c('Kraken2', 'Metaphlan4'), selected = 'Kraken2')
      # anno_db
      updateRadioButtons(session, "Kraken2_db", choices = c("Standard + Protozoa + Fungi 16G" = "pluspf16g",
                                  "Standard + Protozoa + Fungi 69G" = "pluspf",
                                  "Standard + Protozoa + Fungi + Plant 144G" = "pluspfp"),
                                selected = "pluspf16g")
      # anno_threshold
      updateNumericInput(session, "anno_confirm_threshold", value = 60)
    }
  })
  
  #### INITIALIZE DATA ####
  # filename_pre
  assign('Anno.File.Pre', reactive({
  if(input$anno_method == 'Kraken2'){
      return(paste0("result/kraken2/","kraken2.",input$Kraken2_db))
    }else if(input$anno_method == 'Metaphlan4'){
      return('result/metaphlan4/metaphlan4')
    }else{
      return(NULL)
    }}), envir = .GlobalEnv)
  
  #### ACTIVITY ####
  ## RUN
  observeEvent(input$run_species_annotation, ignoreInit = TRUE, {

    filename_pre = Anno.File.Pre()
    proj_id = PROJ.ID()
    anno_threshold = as.numeric(input$anno_confirm_threshold)
    anno_level = input$anno_level_show

    progress <- Progress$new()
    showPageSpinner(type = 1, background = "#FFFFFF30")
 
    # code
    file_path.up0_all = file.path(DBPATH(), proj_id, paste0(filename_pre, '_combined.percentages.up0_all.txt'))
    if(!file.exists(file_path.up0_all) || file.size(file_path.up0_all) < 1*1024) {

      # determine whether the critical step of quality control has been performed
      if (length(list.files(file.path(DBPATH(), proj_id, 'temp/fastp'), full.names = FALSE)) == 0){
        showModal(modalDialog(
            title = "Operation Error",
            "Please select a project from the 'Project List' and ensure that the raw data exists and the 'Quality Control' measures are in place!",
            alertType = "error"
          ))
          return(NULL)
      }
        
      progress$set(value = 0.4, message = 'Annotating...')
      if(input$anno_method == 'Kraken2'){
        system2(
          command = "/bin/bash",
          args = c(
            "script/run_anno_kraken2.sh",
            file.path(DBPATH(), proj_id),
            input$Kraken2_db
          ),
          stdout = file.path(DBPATH(), proj_id, 'result/log.run_anno_kraken2.txt'),
          stderr = file.path(DBPATH(), proj_id, 'result/log.run_anno_kraken2.txt'),
          wait = FALSE
        )
      }else{
        system2(
          command = "/bin/bash",
          args = c(
            "script/run_anno_metaphlan4.sh",
            file.path(DBPATH(), proj_id)
          ),
          stdout = file.path(DBPATH(), proj_id, 'result/log.run_anno_metaphlan4.txt'),
          stderr = file.path(DBPATH(), proj_id, 'result/log.run_anno_metaphlan4.txt'),
          wait = FALSE
        )
      }
        
    }# end if
    
    # Polls every 5 seconds for the completion of an asynchronous instruction.
    script_running <- reactiveVal(TRUE)
    observe({

      if (script_running()) {

        invalidateLater(5000) 

        if (file.exists(file_path.up0_all)) {

          progress$set(value = 0.7, message = 'Annotation Confirming...')
          # save anno_confirm
          core.species_annotation.func.anno_confirm(DBPATH(),
                                                    proj_id,
                                                    filename_pre,
                                                    anno_threshold)
          
          progress$set(value = 0.8, message = 'Ploting...')
          # Refresh table
          output$tab_anno_confirm <- renderDT(server=T,{
            core.species_annotation.tab.anno_confirm(DBPATH(),
                                                    proj_id,
                                                    filename_pre)
          })          
          output$tab_anno_levels <- renderDT(server=T,{
            core.species_annotation.tab.anno_levels(DBPATH(),
                                                    proj_id,
                                                    filename_pre,
                                                    anno_level)
          })
          # Refresh plot
          output$plt_anno_sankey <- renderPlotly(
            core.species_annotation.plt.anno_sankey(DBPATH(),
                                                  proj_id,
                                                  filename_pre)
          )          
          output$plt_anno_sunburst <- renderSund2b(
            core.species_annotation.plt.anno_sunburst(DBPATH(),
                                                      proj_id,
                                                      filename_pre)
          )
          
          ## Groups anno frequency
          core.species_annotation.func.anno_groups(DBPATH(),
                                                  proj_id,
                                                  filename_pre,
                                                  anno_level)          
          # Refresh groups table
          output$tab_anno_groups <- renderDT(server=T,{
            core.species_annotation.tab.groups_tab(DBPATH(),
                                                  proj_id,
                                                  filename_pre,
                                                  anno_level)
          })          
          # Refresh groups plot
          output$plt_anno_groups <- renderPlotly(
            core.species_annotation.plt.groups_bar(DBPATH(),
                                                  proj_id,
                                                  filename_pre,
                                                  anno_level)
          )

          progress$set(value = 0.9, message = 'Finished')
          progress$close()
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe
    
  })

  ## SHOW
  observeEvent(input$show_species_annotation, ignoreInit = TRUE, {

    filename_pre = Anno.File.Pre()
    proj_id = PROJ.ID()
    anno_level = input$anno_level_show

    # Refresh table
    output$tab_anno_levels <- renderDT(server=FALSE,{
      core.species_annotation.tab.anno_levels(DBPATH(),
                                              proj_id,
                                              filename_pre,
                                              anno_level)
    })

    ## Groups Comparative
    core.species_annotation.func.anno_groups(DBPATH(),
                                             proj_id,
                                             filename_pre,
                                             anno_level)
    
    # Refresh groups table
    output$tab_anno_groups <- renderDT(server=FALSE,{
      core.species_annotation.tab.groups_tab(DBPATH(),
                                             proj_id,
                                             filename_pre,
                                             anno_level)
    })
    
    # Refresh groups plot
    output$plt_anno_groups <- renderPlotly(
      core.species_annotation.plt.groups_bar(DBPATH(),
                                             proj_id,
                                             filename_pre,
                                             anno_level)
    )

  })

}

shinyApp(core.species_annotation.UI, core.species_annotation)
