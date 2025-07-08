#### submit task ####

# source('core/1_data_upload/func/proj_create.R')
source('core/1_data_upload/tab/proj_records.R')
# source('core/6_submit_task/func/task_run.R')

core.submit_task.UI <- fluidPage(
  sidebarLayout(
    sidebarPanel(width = 5, 
                 
                 h4('Step1. Data Upload'),
                 br(),

                 textInput(inputId = 'task_proj_name', 
                           label = 'Please enter your project name, default is "MyProject"', 
                           value = 'MyProject'),
                 br(),
                 fileInput(inputId = 'task_data_upload', 
                           label = 'Please package and upload your data',
                           multiple = F,
                           accept = c('.zip', '.tar'),
                           placeholder = 'Support .zip or .tar package'),
                 
                 fluidRow(
                    column(6, actionButton(inputId = 'task_upload_data', label = 'Upload Data', icon = icon('upload')), align = 'left'),
                    column(6, actionButton(inputId = 'task_upload_data_exp', label = 'Upload Exemplar', icon = icon('upload')), align = 'right'),
                 ),
                 downloadButton(outputId = 'task_download_data_exp', label = 'Download Exemplar', icon = icon('download')),
                 br(),
                 
                 hr(),

                 h4('Step2. params Setting'),
                 br(),

                ## fastp
                radioGroupButtons(inputId = 'task_fastp', 
                                    label = 'Quality Control', 
                                    choices = c('Yes'), 
                                    size = 'sm'),

                ## anno
                radioGroupButtons(inputId = 'task_anno', 
                                    label = 'Species Annotation', 
                                    choices = c('Yes'),
                                    size = 'sm'),
                conditionalPanel(
                  condition ="input.task_anno == 'Yes'",
                  radioButtons("task_anno_method", 
                                "Selection of species annotation methods", 
                                c('Kraken2','Metaphlan4'),
                                selected = 'Kraken2'),
                      
                    conditionalPanel(
                    condition ="input.task_anno_method == 'Kraken2'",
                    radioButtons("task_kraken2_db", 
                                  "Select the reference database of Kraken2", 
                                  choices = c("Standard + Protozoa + Fungi 16G",
                                  "Standard + Protozoa + Fungi 69G",
                                  "Standard + Protozoa + Fungi + Plant 144G"),
                                  selected = "Standard + Protozoa + Fungi 16G"),
                    helpText('The larger the database you select, the longer the computation takes'),
                    ),
                  
                  numericInput("task_anno_confirm_threshold",
                              "Set species annotation percentage threshold, recommended 60",
                              value=60, min = 0, max=100, step = 5),    
                  
                ),

                ## func_anno
                radioGroupButtons(inputId = 'task_func_anno', 
                                    label = 'Function Annotation', 
                                    choices = c('Yes','No'), 
                                    selected = 'No', 
                                    size = 'sm'),

                ## snp
                radioGroupButtons(inputId = 'task_snp', 
                                    label = 'SNP Analysis', 
                                    choices = c('Yes','No'), 
                                    selected = 'No', 
                                    size = 'sm'),
                conditionalPanel(
                  condition ="input.task_snp == 'Yes'",
                  selectInput("task_snp_level",
                              "Selecte the species level for SNP analysis",
                              c('Species','Genus','Family')),
                  textInput('task_snp_name', 
                            'Enter the species name for SNP analysis',
                            'Bifidobacterium longum'),
                  fileInput(inputId = 'task_snp_ref_filepath', 
                            label = 'Please upload the reference genome',
                            multiple = F,
                              accept = c('.fna'),
                              placeholder = 'Support .fna file'),
                ),

                hr(),

                h4("Step3. Enter email for submit your task"),
                textInput(inputId = 'task_email', 
                            label = "Please provide your email. After the operation is completed, we will return the results to your mailbox."),
                
                br(),
                actionButton(inputId = 'task_submit', label = 'Submit the Task', icon = icon('angle-double-right')),
              
                 
    ),## end sidebarPanel
    
    mainPanel(width = 7,
              br(),
              tabsetPanel(
                tabPanel('Project Information', br(), dataTableOutput('tab_task_proj')),
              ),
              tabsetPanel(
                tabPanel('Sample Information', br(), dataTableOutput('tab_task_proj_info'))
              ),
              hr(),
              br(),
              tabsetPanel(
                tabPanel('params Information', br(), htmlOutput('tab_task_params_info')),                
              ),

    )## end mainPanel
  )## end sidebarLayout
)## end ui

core.submit_task <- function(input, output, session){  
  
  #### INITIALIZE DATA ####
  task_proj_id <- reactiveVal()
  reactive_task_params_anno_method <- reactive(input$task_anno_method)
  reactive_task_params_anno_db <- reactive({ifelse(reactive_task_params_anno_method() == 'Kraken2',input$task_kraken2_db,ifelse(reactive_task_params_anno_method() == 'Metaphlan4',"mpa_vOct22_CHOCOPhlAnSGB_202212",''))})
  reactive_task_params_anno_threshold <- reactive({as.numeric(input$task_anno_confirm_threshold)})
  reactive_task_params_func_anno <- reactive({input$task_func_anno})
  reactive_task_params_snp <- reactive({input$task_snp})
  reactive_task_params_snp_level <- reactive({ifelse(input$task_snp == "Yes",input$task_snp_level,'')})
  reactive_task_params_snp_name <- reactive({ifelse(input$task_snp == "Yes",input$task_snp_name,'')})
  reactive_task_params_snp_ref_filepath <- reactive(input$task_snp_ref_filepath)
  reactive_task_params_email <- reactive({input$task_email})
  reactive_task_params <- reactive(paste0("<p style='color: #4D84B7'>","Quality Control: Yes","<br><br>",
           "Species Annotation: Yes","<br>",
           "annotation method: ",reactive_task_params_anno_method(),"<br>",
           "reference database: ",reactive_task_params_anno_db(),"<br><br>",
           "Function Annotation: ",reactive_task_params_func_anno(),"<br><br>",
           "SNP Analysis: ",reactive_task_params_snp(),"<br>",
           "snp analysis level: ",reactive_task_params_snp_level(),"<br>",
           "snp analysis species: ",reactive_task_params_snp_name(),"<br><br>",
          #  "snp analysis reference genome: ",reactive_task_params_snp_ref_filepath(),"<br><br>",
           "Your Email: ",reactive_task_params_email(),"</p>"))

  #### INITIALIZE UI ####
  output$tab_task_params_info <- renderText({
    reactive_task_params()    
  })  

  #### ACTIVITY ####
  ## Download Exemplar Data
  output$task_download_data_exp <- downloadHandler(
    filename  <- function() {
      paste("SCMeta_Demo","zip", sep=".")
    },
    content = function(file) {
      file.copy("data/Exemplar/Demo.zip", file)
    },
    contentType ="application/zip"
  )

  ## Upload Exemplar Data
  observeEvent(input$task_upload_data_exp, {

    task_proj_id(basic.create_proj_id())
    file_path = file.path(DBPATH(), "Demo.zip")
    proj_name = input$task_proj_name
    proj_id = task_proj_id()
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

    # core.data_upload.func.proj_create(DBPATH(), file.path(DBPATH(), "Demo.zip"), task_proj_id(), task_proj_name)
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

          # refresh tab_task_proj & tab_task_proj_info
          progress$set(0.8, message = 'Refresh Table...')          
          output$tab_task_proj <- renderDT(
            core.data_upload.tab.proj_records(DBPATH(),
                                            task_proj_id())
          )
          output$tab_task_proj_info <- renderDT(
            core.data_upload.tab.proj_info(DBPATH(),
                                          task_proj_id())
          )
          
          progress$set(0.9, message = 'Finished')
          progress$close()
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe
    
  })

  ## Upload Data
  observeEvent(input$task_upload_data, {

    file_path = input$task_data_upload$datapath
    proj_name = input$task_proj_name
    task_proj_id(basic.create_proj_id())
    proj_id = task_proj_id()
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

    # core.data_upload.func.proj_create(DBPATH(), file_path, task_proj_id(), proj_name)
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

          # refresh tab_task_proj & tab_task_proj_info
          progress$set(0.8, message = 'Refresh Table...')          
          output$tab_task_proj <- renderDT(
            core.data_upload.tab.proj_records(DBPATH(),
                                            task_proj_id())
          )
          output$tab_task_proj_info <- renderDT(
            core.data_upload.tab.proj_info(DBPATH(),
                                          task_proj_id())
          )
          
          progress$set(0.9, message = 'Finished')
          progress$close()
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe
    
  })
  
  ## Submit Task
  observeEvent(input$task_submit, ignoreInit = TRUE, {
    
    # Determines whether the params is correct
    if(reactive_task_params_email() == ''){
      showModal(modalDialog(
        title = "Inappropriate Input",
        'Email can not be empty!',
        alertType = "warning"
      ))
      return(NULL)
    }else if(!grepl("@", reactive_task_params_email())) {
      showModal(modalDialog(
        title = "Inappropriate Input",
        'The email format is incorrect, please check it!',
        alertType = "warning"
      ))
      return(NULL)
    }else if(reactive_task_params_snp() == 'Yes'&& reactive_task_params_snp_name() == ''){
      showModal(modalDialog(
        title = "Inappropriate Input",
        'SNP analysis species can not be empty!',
        alertType = "warning"
      ))
      return(NULL)
    }

    # confirm again
    showModal(modalDialog(
      title = "Confirm Submit",
      HTML("Please double-check the paramss, then click 'Confirm' to upload the task, or 'Cancel' to abort.<br><br>",
      reactive_task_params()),
      footer = tagList(
        actionButton("confirmSubmit", "Confirm"),
        actionButton("cancelSubmit", "Cancel")
      )
    ))
    
  })
  
  observeEvent(input$confirmSubmit, ignoreInit = TRUE, {
    task_params <- list(
      anno_method = reactive_task_params_anno_method(),
      anno_db = reactive_task_params_anno_db(),
      anno_threshold = reactive_task_params_anno_threshold(),
      func_anno = reactive_task_params_func_anno(),
      snp = reactive_task_params_snp(),
      snp_level = reactive_task_params_snp_level(),
      snp_name = reactive_task_params_snp_name(),
      snp_ref_filepath = reactive_task_params_snp_ref_filepath(),
      email = as.character(reactive_task_params_email())
    )
    if(task_params$anno_db == "Standard + Protozoa + Fungi 16G") task_params$anno_db = "pluspf16g"
      else if(task_params$anno_db == "Standard + Protozoa + Fungi 69G") task_params$anno_db = "pluspf"
      else if(task_params$anno_db == "Standard + Protozoa + Fungi + Plant 144G") task_params$anno_db = "pluspfp"
    task_params$snp_name <- gsub(" ", "_", task_params$snp_name)

    proj_id = task_proj_id()
    db_path = DBPATH()
    save(task_params, file = file.path(db_path, proj_id, "task_params.rd"))

    system2(
      command = "Rscript",
      args = c(
        "core/6_submit_task/func/task_run.R",
        db_path, proj_id
      ),
      stdout = file.path(db_path, proj_id, 'result/log.run_submit_task.txt'),
      stderr = file.path(db_path, proj_id, 'result/log.run_submit_task.txt'),
      wait = FALSE
    )
    
    showModal(modalDialog(
      title = "Task Submission Successful",
      'We will send an email to the address you provided once the task is complete. Thank you for your patience!',
      alertType = "success"
    ))
    #   return(NULL)

    # removeModal()
  })
  
  observeEvent(input$cancelSubmit, {
    removeModal()
  })  

} 

shinyApp(core.submit_task.UI, core.submit_task)