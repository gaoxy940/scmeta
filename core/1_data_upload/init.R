#### data upload ####

source('core/1_data_upload/act/get_proj_id.R')
source('core/1_data_upload/act/get_Task_Params.R')
# source('core/1_data_upload/func/proj_create.R')
source('core/1_data_upload/func/proj_upload.R')
source('core/1_data_upload/func/proj_delete.R')
source('core/1_data_upload/tab/proj_records.R')


core.data_upload.UI <- fluidPage(
  sidebarLayout(
    sidebarPanel(width = 5,
                 
                 br(),
                 helpText("You can click the demo project in the right panel to proceed directly to the next step of analysis. Alternatively, you can follow the tips below to upload your own data to create a new project."),
                 helpText("Please note that this is for small sample uploads only (File size < 1.0GB). If your data is too large, please proceed to the 'Submit Task' section."),

                 hr(),

                 radioGroupButtons(inputId = 'project_create', 
                                    label = 'Create Project', 
                                    choices = c('Create a new project','Upload the result file returned by scMETA'), 
                                    selected = 'Create a new project', 
                                    size = 'sm'),

                 ## Create Project
                 conditionalPanel(
                    condition ="input.project_create == 'Create a new project'",
                    # proj_name
                    textInput(inputId = 'proj_name_new', 
                              label = 'Please enter your project name, default is "MyProject"', 
                              value = 'MyProject'),
                    br(),
                    
                    # Upload data
                    fileInput(inputId = 'data_upload.file_input', 
                              #  label = 'Please package and upload your data, or upload the ZIP file you received in the email to visualize the results',
                              label = 'Please package and upload your data',
                              multiple = F,
                              accept = c('.zip', '.tar.gz'),
                              placeholder = 'Support .zip or .tar.gz package'),
                    helpText('If your project consists of groups, a file named "group.txt" is required in the package, which looks like:'),
                    helpText("Sample Group",br(),"SRR0001 Control",br(),"SRR0002 Treat"),
                    br(),
                    
                    fluidRow(
                        column(6, actionButton(inputId = 'upload_data', label = 'Upload Data', icon = icon('upload')), align = 'left'),
                        column(6, actionButton(inputId = 'upload_data_exp', label = 'Upload Exemplar', icon = icon('upload')), align = 'right'),
                    ),
                    downloadButton(outputId = 'download_data_exp', label = 'Download Exemplar', icon = icon('download')),
                    br(),

                 ),

                 ## Upload the result file returned by scMETA
                 conditionalPanel(
                    condition ="input.project_create == 'Upload the result file returned by scMETA'",
                    
                    # proj_name
                    textInput(inputId = 'proj_name_upload', 
                              label = 'Please enter your project name, default is "MyProject"', 
                              value = 'MyProject'),
                    br(),
                    # Upload the result file
                    fileInput(inputId = 'data_upload.result_file', 
                              label = 'Please upload the ZIP file you received in the email to visualize the results',
                              multiple = F,
                              accept = c('.zip', '.tar'),
                              placeholder = 'Support .zip or .tar package'),
                    actionButton(inputId = 'upload_result_file', label = 'Upload File', icon = icon('upload')),
                    br(),

                 ),
                                            
    ),## end sidebarPanel
    
    mainPanel(width = 7,
              br(), 
              tabsetPanel(
                tabPanel('Project Information', br(), DTOutput('tab_proj'),
                div(style = "display: flex; justify-content: space-between;",
                actionButton('proj_refresh', label = 'Refresh', icon = icon('refresh')),
                actionButton('proj_delete', label = 'Delete', icon = icon('trash'))))
              ),

              hr(),
              
              br(),
              tabsetPanel(
                tabPanel('Sample Information', br(), dataTableOutput('tab_proj_info'))
              ),
              
    )## end mainPanel
  )## end sidebarLayout
)## end ui

core.data_upload <- function(input, output, session){ 
  
  #### INITIALIZE DATA ####
  assign('DBPATH', reactive(file.path('data')), envir = .GlobalEnv)
  assign('PROJ.ID', reactive(
    core.data_upload.act.get_proj_id(DBPATH(), input$tab_proj_rows_selected)
  ), envir = .GlobalEnv)
  # assign("Task_Params", list(), envir = .GlobalEnv)
  assign('Task_Params', reactive(
    core.data_upload.act.get_Task_Params(DBPATH(), input$tab_proj_rows_selected)
  ), envir = .GlobalEnv)
  assign('Anno.File.Pre', reactive(''), envir = .GlobalEnv)

  #### TABLE ####
  output$tab_proj <- renderDT(
    core.data_upload.tab.proj_records(DBPATH())
  )
  
  output$tab_proj_info <- renderDT(
    core.data_upload.tab.proj_info(DBPATH(),
                                   PROJ.ID())
  )
  
  #### ACTIVITY ####
  ## Download Exemplar Data
  output$download_data_exp <- downloadHandler(
    filename  <- function() {
      "scMETA_Demo.zip"
    },
    content = function(file) {
      file.copy("data/Demo.zip", file)
    },
    contentType ="application/zip"
  )

  ## Upload Exemplar Data
  observeEvent(input$upload_data_exp, {

    updateTextInput(session, "proj_name", value = "Exemplar")
    file_path = file.path(DBPATH(), "Demo.zip")
    proj_name = "Exemplar"
    proj_id = basic.create_proj_id()
    db_path = DBPATH()

    if(basic.is_repeat_proj(db_path, proj_id, proj_name)){
      showModal(modalDialog(
          title = "Invalid Input",
          paste0("The ", proj_id, " project already exists, please try it later."),
          alertType = "warning"
      ))
      return(NULL)
    }

    showPageSpinner(type = 1, background = "#FFFFFF30")
    progress <- Progress$new();
    progress$set(0.6, message = 'Reading...')

    # create proj_dir
    proj_dir <- file.path(db_path, proj_id)
    dir.create(proj_dir)
    # create seq_dir/temp_dir/result_dir
    dir.create(file.path(proj_dir, 'seq'))
    dir.create(file.path(proj_dir, 'temp'))
    dir.create(file.path(proj_dir, 'result'))

    # core.data_upload.func.proj_create(DBPATH(), file.path(DBPATH(), "Demo.zip"), proj_id, "Exemplar")
    system2(
      command = "Rscript",
      args = c(
        "core/1_data_upload/func/proj_create.R",
        db_path, file_path, proj_id, proj_name
      ),
      stdout = file.path(db_path, proj_id, 'result/log.run_proj_create.txt'),
      stderr = file.path(db_path, proj_id, 'result/log.run_proj_create.txt'),
      wait = FALSE
    )

    # Polls every 5 seconds for the completion of an asynchronous instruction.
    script_running <- reactiveVal(TRUE)
    file_path.proj_group <- file.path(db_path, proj_id, 'group_filtered.txt')
    observe({

      if (script_running()) {

        invalidateLater(5000)

        if (file.exists(file_path.proj_group)) {
          
          # refresh tab_proj
          progress$set(0.8, message = 'Refresh Table...')
          output$tab_proj <- renderDT(core.data_upload.tab.proj_records(DBPATH()))
          
          progress$set(0.9, message = 'Finished')
          progress$close()
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe

  })

  ## Upload data
  observeEvent(input$upload_data, {

    file_path = NULL
    if (!is.null(input$data_upload.file_input$datapath)) {
        print(input$data_upload.file_input$datapath)
        file_path = input$data_upload.file_input$datapath
    } else {
        showModal(modalDialog(
            title = "Invalid File",
            alertType = "warning"
        ))

        return(NULL)
    }

    proj_name = input$proj_name_new
    proj_id = basic.create_proj_id()
    db_path = DBPATH()

    if(basic.is_repeat_proj(db_path, proj_id, proj_name)){
      showModal(modalDialog(
          title = "Invalid Input",
          paste0("The ", proj_id, " project already exists, please try it later."),
          alertType = "warning"
      ))
      return(NULL)
    } 

    showPageSpinner(type = 1, background = "#FFFFFF30")
    progress <- Progress$new();
    progress$set(0.6, message = 'Reading...')

    # create proj_dir
    proj_dir <- file.path(db_path, proj_id)
    dir.create(proj_dir)
    # create seq_dir/temp_dir/result_dir
    dir.create(file.path(proj_dir, 'seq'))
    dir.create(file.path(proj_dir, 'temp'))
    dir.create(file.path(proj_dir, 'result'))

    # core.data_upload.func.proj_create(DBPATH(), file_path, proj_id, proj_name)
    system2(
      command = "Rscript",
      args = c(
        "core/1_data_upload/func/proj_create.R",
        db_path, file_path, proj_id, proj_name
      ),
      stdout = file.path(db_path, proj_id, 'result/log.run_proj_create.txt'),
      stderr = file.path(db_path, proj_id, 'result/log.run_proj_create.txt'),
      wait = FALSE
    )

    # Polls every 5 seconds for the completion of an asynchronous instruction.
    script_running <- reactiveVal(TRUE)
    file_path.proj_group <- file.path(db_path, proj_id, 'group_filtered.txt')
    observe({

      if (script_running()) {

        invalidateLater(5000)

        if (file.exists(file_path.proj_group)) {
          
          # refresh tab_proj
          progress$set(0.8, message = 'Refresh Table...')
          output$tab_proj <- renderDT(core.data_upload.tab.proj_records(DBPATH()))
          
          progress$set(0.9, message = 'Finished')
          progress$close()
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe

  })

  ## upload_result_file
  observeEvent(input$upload_result_file, {

    showPageSpinner(type = 1, background = "#FFFFFF30")
    file_path = input$data_upload.result_file$datapath
    proj_name = input$proj_name_upload
    # create project
    proj_id = core.data_upload.func.proj_upload(DBPATH(), file_path, proj_name)
    # load task_params.rd
    if(!is.null(proj_id) && file.exists(file.path(DBPATH(), proj_id, 'task_params.rd'))){
      # refresh tab_proj
      output$tab_proj <- renderDT(core.data_upload.tab.proj_records(DBPATH()))    
    }else{
      showModal(modalDialog(
        title = "Invalid Input",
        "The project does not match, please upload the result file returned by scMETA! If you want to upload the sequencing data, please select 'Create a new project'.",
        alertType = "warning"
      ))
      return(NULL)
    }
    
    hidePageSpinner()
  })

  ## Refresh Project
  observeEvent(input$proj_refresh, {
    # refresh tab_proj
    output$tab_proj <- renderDT(core.data_upload.tab.proj_records(DBPATH()))
  })
  
  ## Delete Project
  observeEvent(input$proj_delete, {
    if (PROJ.ID() == "P3AB1A2716B" || PROJ.ID() == "P3AB1A2717C") {
      showModal(modalDialog(
        title = "Irational Operation",
        'Demo project cannot be deleted!',
        alertType = "warning"
      ))
      return(NULL)
    }

    showModal(modalDialog(
      title = "Confirm Deletion",
      "Are you sure you want to delete this item?",
      footer = tagList(
        actionButton("confirmDelete", "Confirm"),
        actionButton("cancelDelete", "Cancel")
      )
    ))
  })

  observeEvent(input$confirmDelete, {
    core.data_upload.func.proj_delete(DBPATH(), PROJ.ID())
    output$tab_proj <- renderDT(core.data_upload.tab.proj_records(DBPATH()))
    removeModal()
  })
  
  observeEvent(input$cancelDelete, {
    removeModal()
  })

     
} 

shinyApp(core.data_upload.UI, core.data_upload)
