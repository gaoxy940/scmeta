#### snp analysis ####

source('core/5_snp_analysis/func/get_ref_filename.R')
source('core/5_snp_analysis/func/get_snp_hclust_tab.R')
source('core/5_snp_analysis/func/get_snp_species_tab.R')
source('core/5_snp_analysis/func/get_snp_hclust_diff_tab.R')
source('core/5_snp_analysis/func/get_anno_confirm_list.R')
source('core/5_snp_analysis/func/get_snp_sample_list.R')
source('core/5_snp_analysis/tab/snp_records.R')
source('core/5_snp_analysis/plt/snp_heatmap.R')
source('core/5_snp_analysis/plt/snp_gcircle.R')
source('core/5_snp_analysis/plt/snp_scircle.R')
source('core/5_snp_analysis/plt/snp_tree.R')


core.snp_analysis.UI <- fluidPage(
  useShinyjs(),
  div(id = "content_snp",
  sidebarLayout(
    sidebarPanel(width = 5,

                 h4('Step1. SNP Sites Identification'),
                 br(),

                 radioButtons("anno_levels", 
                              'Step1.1 Selecte the species for SNP analysis', 
                              c('Species','Genus','Family'),
                              selected = 'Species'),
                 
                 uiOutput('anno_confirm_list_Dui'),
                 br(),
                 
                 # Select the reference genome
                 radioGroupButtons(inputId = 'snp_ref', 
                                   label = 'Step1.2 Upload the reference genome', 
                                   choices = c('Use the SNP Exemplar','Upload'), 
                                   selected = 'Use the SNP Exemplar', 
                                   size = 'sm'),                 
                 conditionalPanel(
                   condition ="input.snp_ref == 'Use the SNP Exemplar'",
                   actionButton(inputId = 'upload_snp_exp', label = 'Upload the SNP Exemplar', icon = icon('upload')),
                 ),
                 conditionalPanel(
                   condition ="input.snp_ref == 'Upload'",
                    fileInput(inputId = 'snp_ref.file_input',
                              label = '',
                              multiple = F,
                              accept = c('.fna'),
                              placeholder = 'Support .fna file'),
                 ),
                 
                 br(),
                 # RUN
                 actionButton(inputId = 'run_snp_analysis', label = 'Run SNP Analysis', icon = icon('play')),
                 br(),

                 hr(),
                 h4('Step2. Show Sample SNP Sites'),
                 uiOutput('snp_sample_list_Dui'),
                 actionButton(inputId = 'show_snp_scircle', label = 'Show Sample Circle', icon = icon('list-check')),


                 hr(),
                 h4('Step3. Subspecies Identification'),
                 br(),

                 radioButtons("snp_dist_method",
                              "Selection of genetic distance methods", 
                              c('Bray-Curtis Distance of 5-mers','Jaccard Distance of 5-mers','BLAST Soring Matrix'),
                              selected = 'Bray-Curtis Distance of 5-mers'),
                 numericInput(inputId = 'snp_hclust_treenum',
                              label = 'Please enter the number of clusters',
                              value=8, min = 1, step = 1),     
                
                 # SHOW
                 actionButton(inputId = 'show_snp_hclust', label = 'Clustering & Show HeatMAP', icon = icon('redo')),
                 br(),br(),
                 
                 h5('Step3.1 Difference Analysis Based on HeatMAP-Clusters'),                 
                 uiOutput('snp_hclust_list_compare_Dui'),
                 uiOutput('snp_hclust_list_control_Dui'),

                 # Run Difference Analysis
                 actionButton(inputId = 'run_snp_hclust_diff', label = 'Run Difference Analysis', icon = icon('play')),
                 br(),

                 hr(),
                 h4('Step4. Construct the Phylogenetic Tree'),
                 br(),
                 # Run Construct the Phylogenetic Tree
                 actionButton(inputId = 'run_snp_tree', label = 'Run Constructing', icon = icon('play')),
                 br(),
          
    ),## end sidebarPanel
    
    mainPanel(width = 7,
              br(), 
              tabsetPanel(id = 'Panel_plt',
                tabPanel('Genome Circle', value = 'Panel_plt_gcircle', br(), plotOutput('plt_snp_gcircle'),
                  downloadButton('dbtn_snp_gcircle', 'Download PDF', icon = shiny::icon("download"), class = "btn btn-primary pull-right")),
                tabPanel('Sample Circle', value = 'Panel_plt_scircle', br(), plotOutput('plt_snp_scircle'),
                  downloadButton('dbtn_snp_scircle', 'Download PDF', icon = shiny::icon("download"), class = "btn btn-primary pull-right")),
                tabPanel('HeatMAP', value = 'Panel_plt_heatmap', br(), iheatmaprOutput('plt_snp_heatmap_iheatmapr')),
                tabPanel('Tree', value = 'Panel_plt_tree', br(), plotOutput('plt_snp_tree'),
                  downloadButton('dbtn_snp_tree', 'Download PDF', icon = shiny::icon("download"), class = "btn btn-primary pull-right")),
              ),
              
              hr(),
              
              br(),
              tabsetPanel(id = 'Panel_tab',
                tabPanel('SNP Matrix', value = 'Panel_tab_matrix', br(), dataTableOutput('tab_snp_matrix'),
                  downloadButton('dbtn_snp_matrix', 'Download Full Table', icon = shiny::icon("download"), class = "btn btn-primary pull-right")),
                tabPanel('HeatmapCluster Table', value = 'Panel_tab_hcluster', br(), dataTableOutput('tab_snp_matrix_hclust')),
                tabPanel('DiffAnalysis Table', value = 'Panel_tab_diff', br(), dataTableOutput('tab_snp_diff')),
              ),
              
    )## end mainPanel
  )## end sidebarLayout
  )## end div
)## end ui

core.snp_analysis <- function(input, output, session){

  #### INITIALIZE DATA ####
  ref_filepath <- reactiveVal('')
       
  #### INITIALIZE UI ####
  output$anno_confirm_list_Dui <- renderUI({
    proj_id = PROJ.ID()
    selectInput("anno_confirm_list", 
                "", 
                core.snp_analysis.func.get_anno_confirm_list(DBPATH(),
                                            proj_id,
                                            Anno.File.Pre(), 
                                            input$anno_levels))
  })  

  #### Task Params ####
  observeEvent(Task_Params(), {
    if (length(Task_Params()) > 1) {
      if(Task_Params()$snp == 'No'){
        runjs("$('#content_snp').css('opacity', '0.5'); $('#content_snp').css('pointer-events', 'none');")
      } else if(Task_Params()$snp == 'Yes'){
        # snp_level
        updateRadioButtons(session, "anno_levels", choices = Task_Params()$snp_level)
        # snp_name
        updateSelectInput(session, "anno_confirm_list", choices = Task_Params()$snp_name)
        # snp_ref_filepath
        ref_filepath <- (Task_Params()$snp_ref_filepath)
        runjs("$('#content_snp').css('opacity', '1'); $('#content_snp').css('pointer-events', 'auto');")
      }      
    } else {
      # snp_level
      updateRadioButtons(session, "anno_levels", 
                        c('Species','Genus','Family'),
                        selected = 'Species')
      # snp_name
      updateSelectInput(session, "anno_confirm_list", core.snp_analysis.func.get_anno_confirm_list(DBPATH(),
                                                        PROJ.ID(),
                                                        Anno.File.Pre(), 
                                                        input$anno_levels))
      # snp_ref_filepath
      ref_filepath <- ('')
      runjs("$('#content_snp').css('opacity', '1'); $('#content_snp').css('pointer-events', 'auto');")
    }
  })
  
  #### ACTIVITY ####
  ## ref_filepath
  observeEvent(input$snp_ref.file_input, {
    if (!is.null(input$snp_ref.file_input)) {
      ref_filepath(input$snp_ref.file_input$datapath)
    }
  })

  ## Upload SNP Exemplar
  use_snp_exemplar <- reactiveVal(FALSE)
  observeEvent(input$upload_snp_exp, {
    
    ref_filepath('Bifidobacterium_longum.fna')
    showModal(modalDialog(
            title = "Success",
            HTML("The reference genome of 'Bifidobacterium_longum' has been successfully uploaded: Bifidobacterium_longum.fna<br>",
            "Next, SNP analysis will be performed on all samples with the species name 'Bifidobacterium_longum'."),
            alertType = "success"
          ))

  })

  ## run_snp_analysis
  observeEvent(input$run_snp_analysis, ignoreInit = TRUE, {

    proj_id = PROJ.ID()
    anno_level = input$anno_levels
    species_name = input$anno_confirm_list
    ref_filename = core.snp_analysis.func.get_ref_filename(DBPATH(),
                                                          proj_id,
                                                          species_name,
                                                          ref_filepath())

    if(ref_filepath() == 'Bifidobacterium_longum.fna'){
      proj_id = 'P3AB1A2717C'
      species_name = 'Bifidobacterium_longum'
      ref_filename = 'Bifidobacterium_longum.fna'
    }    
    if (length(Task_Params()) == 0 || Task_Params()$snp == 'No'){
      if( is.null(ref_filename) || ref_filename == ''){
            showModal(modalDialog(
                    title = "Invalid Input",
                    "Please upload the reference genome!",
                    alertType = "warning"
                  ))
            return(NULL)
          }
    }
    if (length(Task_Params()) > 0 && Task_Params()$snp == 'Yes'){
      species_name = Task_Params()$snp_name
      ref_filename = paste0(species_name,'.fna')
    }    

    progress <- Progress$new();
    progress$set(0.3, message = 'Reading...') 
    showPageSpinner(type = 1, background = "#FFFFFF30")

    # code
    file_path.snp_matrix = file.path(DBPATH(), proj_id, 'result/snippy',species_name,'snp_matrix.txt')
    if(!file.exists(file_path.snp_matrix) || file.size(file_path.snp_matrix) < 20){
      
      # determine whether the critical step of quality control has been performed
      if (length(list.files(file.path(DBPATH(), proj_id, 'temp/fastp'), full.names = FALSE)) == 0){
        showModal(modalDialog(
            title = "Operation Error",
            "Please select a project from the 'Project List' and ensure that the raw data exists and the 'Quality Control' measures are in place!",
            alertType = "error"
          ))
          return(NULL)
      }

      # get_snp_species_tab
      core.snp_analysis.func.get_snp_species_tab(DBPATH(),
                                          proj_id,
                                          Anno.File.Pre(),
                                          anno_level, species_name)

      # run snippy
      progress$set(0.6, message = 'Running...')
      system2(
          command = "/bin/bash",
          args = c(
            "script/run_snippy.sh",
            file.path(DBPATH(), proj_id),
            species_name,
            ref_filename
          ),
          stdout = file.path(DBPATH(), proj_id, paste0('result/log.run_snippy_',species_name,'.txt')),
          stderr = file.path(DBPATH(), proj_id, paste0('result/log.run_snippy_',species_name,'.txt')),
          wait = FALSE
      )
      
    }## end if

    # Polls every 5 seconds for the completion of an asynchronous instruction.
    script_running <- reactiveVal(TRUE)
    observe({

      if (script_running()) {

        invalidateLater(5000)

        if (file.exists(file_path.snp_matrix)) {

          # www.files
          dir_path = paste0('www/snp.files/', paste0(proj_id,'_',species_name,'_snp.files'))
          if (!dir.exists(dir_path)) {
            dir.create(dir_path, recursive = TRUE)
          }
          file.copy(from = list.files(file.path(DBPATH(), proj_id, 'result/snippy', species_name, 'vcf.files'), full.names = TRUE), to = dir_path, overwrite = TRUE)

          progress$set(0.9, message = 'Plotting...') 
          # Refresh table
          output$tab_snp_matrix <- renderDT({
            core.snp_analysis.tab.snp_matrix(DBPATH(),
                                              proj_id,
                                              species_name)
          })
          
          # Refresh plot
          output$plt_snp_gcircle <- renderPlot({
            core.snp_analysis.plt.snp_gcircle(DBPATH(),
                                        proj_id,
                                        species_name,
                                        ref_filename)
          })

          ## Dui
          output$snp_sample_list_Dui <- renderUI(
            selectInput("snp_sample_list", 
                        "Select up to three samples at a time", 
                        core.snp_analysis.func.get_snp_sample_list(DBPATH(),
                                                    proj_id,
                                                    species_name),
                        multiple = TRUE)
          )

          progress$close()
          updateTabsetPanel(session, 'Panel_plt', selected = 'Panel_plt_gcircle')
          updateTabsetPanel(session, 'Panel_tab', selected = 'Panel_tab_matrix')
          hidePageSpinner()
          script_running(FALSE)
        }

      }# end if(script_running())

    })# end observe    

  })

  ## show_snp_scircle
  observeEvent(input$show_snp_scircle,{

    proj_id = PROJ.ID()
    species_name = input$anno_confirm_list
    sample_list = input$snp_sample_list
    if(ref_filepath() == 'Bifidobacterium_longum.fna'){
      proj_id = 'P3AB1A2717C'
      species_name = 'Bifidobacterium_longum'
    }

    if (length(sample_list) > 3){
      showModal(modalDialog(
            title = "Invalid Input",
            'Too many samples. Up to three samples at a time!',
            alertType = "warning"
          ))
      return(NULL)
    }
    
    showPageSpinner(type = 1, background = "#FFFFFF30")

    # Refresh plot
    output$plt_snp_scircle <- renderPlot({
        core.snp_analysis.plt.snp_scircle(DBPATH(),
                                     proj_id,
                                     species_name,
                                     sample_list)
    })

    updateTabsetPanel(session, 'Panel_plt', selected = 'Panel_plt_scircle')

    hidePageSpinner()

  })

  ## show_snp_hclust
  observeEvent(input$show_snp_hclust, {

    proj_id = PROJ.ID()
    species_name = input$anno_confirm_list
    dist_method = input$snp_dist_method
    hclust_treenum = as.numeric(input$snp_hclust_treenum)
    if(ref_filepath() == 'Bifidobacterium_longum.fna'){
      proj_id = 'P3AB1A2717C'
      species_name = 'Bifidobacterium_longum'
    }

    if(is.na(hclust_treenum)){
      showModal(modalDialog(
        title = "Invalid Input",
        'Please enter the number of clusters!',
        alertType = "warning"
      ))
      return(NULL)
    }
    samples_num = basic.get_samples_num(DBPATH(), proj_id)
    if(hclust_treenum > 20 || hclust_treenum > samples_num){
      showModal(modalDialog(
        title = "Invalid Input",
        'the number of clusters is too large!',
        alertType = "warning"
      ))
      return(NULL)
    }    

    showPageSpinner(type = 1, background = "#FFFFFF30")

    core.snp_analysis.func.get_snp_hclust_tab(DBPATH(), proj_id, species_name, dist_method, hclust_treenum)

    # Refresh table
    output$tab_snp_matrix_hclust <- renderDT(
      core.snp_analysis.tab.snp_hclust(DBPATH(),
                                        proj_id,
                                        species_name)
    )

    # Refresh plot
    output$plt_snp_heatmap_iheatmapr <- renderIheatmap(
      core.snp_analysis.plt.snp_heatmap(DBPATH(),
                                        proj_id,
                                        species_name,
                                        hclust_treenum)
    )

    # Refresh ui
    output$snp_hclust_list_control_Dui <- renderUI(
      checkboxGroupInput("snp_hclust_list_control", 
                        "Control Cluster (multiple selections allowed)", 
                        choices = paste0("Cluster", 1:hclust_treenum),
                        inline = T),
    )
    output$snp_hclust_list_compare_Dui <- renderUI(
    radioButtons("snp_hclust_list_compare",
                "Comparison Cluster",
                choices = paste0("Cluster", 1:hclust_treenum),
                inline = T),
    )  

    updateTabsetPanel(session, 'Panel_plt', selected = 'Panel_plt_heatmap')
    updateTabsetPanel(session, 'Panel_tab', selected = 'Panel_tab_hcluster')

    hidePageSpinner()
  
  })

  ## run_snp_hclust_diff
  observeEvent(input$run_snp_hclust_diff, {
    proj_id = PROJ.ID()
    species_name = input$anno_confirm_list
    if(ref_filepath() == 'Bifidobacterium_longum.fna'){
      proj_id = 'P3AB1A2717C'
      species_name = 'Bifidobacterium_longum'
    }

    cp = input$snp_hclust_list_compare
    ct = input$snp_hclust_list_control
    if(is.null(cp) || any(cp == '') || is.null(ct) || any(ct == ''))  {return(NULL)}
    if(all(cp == ct)){
      showModal(modalDialog(
        title = "Invalid Input",
        'The same cluster can not be analyzed for differences!',
        alertType = "warning"
      ))
      return(NULL)
    }

    showPageSpinner(type = 1, background = "#FFFFFF30")
    
    # Refresh table
    output$tab_snp_diff <- renderDT(
      core.snp_analysis.tab.snp_hclust_diff(DBPATH(),
                                        proj_id,
                                        species_name,
                                        cp, ct)
    )

    updateTabsetPanel(session, 'Panel_tab', selected = 'Panel_tab_diff')

    hidePageSpinner()

  })

  ## run tree
  observeEvent(input$run_snp_tree, {

    proj_id = PROJ.ID()
    species_name = input$anno_confirm_list
    if(ref_filepath() == 'Bifidobacterium_longum.fna'){
      proj_id = 'P3AB1A2717C'
      species_name = 'Bifidobacterium_longum'
    }

    showPageSpinner(type = 1, background = "#FFFFFF30")
    
    # Refresh plot
    output$plt_snp_tree <- renderPlot(
      core.snp_analysis.plt.snp_tree(DBPATH(), proj_id, species_name)
    )

    updateTabsetPanel(session, 'Panel_plt', selected = 'Panel_plt_tree')

    hidePageSpinner()

  })

  ## download pdf
  output$dbtn_snp_gcircle <- downloadHandler(
    filename = function() {
      'snp_circle_genome.pdf'
    },
    content = function(file) {
      isolate({
        proj_id = PROJ.ID()
        species_name = input$anno_confirm_list
        if(ref_filepath() == 'Bifidobacterium_longum.fna'){
          proj_id = 'P3AB1A2717C'
          species_name = 'Bifidobacterium_longum'
        }
        pdf_path = file.path(DBPATH(), proj_id, 'result/snippy',species_name,'pdf','snp_circle_genome.pdf')
        if(ref_filepath()=='' || !file.exists(pdf_path)){
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
  output$dbtn_snp_scircle <- downloadHandler(
    filename = function() {
      'snp_circle_sample.pdf'
    },
    content = function(file) {
      isolate({
        proj_id = PROJ.ID()
        species_name = input$anno_confirm_list
        if(ref_filepath() == 'Bifidobacterium_longum.fna'){
          proj_id = 'P3AB1A2717C'
          species_name = 'Bifidobacterium_longum'
        }
        pdf_path = file.path(DBPATH(), proj_id, 'result/snippy',species_name,'pdf','snp_circle_sample.pdf')
        if(is.null(input$snp_sample_list) || !file.exists(pdf_path)){
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
  output$dbtn_snp_tree <- downloadHandler(
    filename = function() {
      'snp_phylo_tree.pdf'
    },
    content = function(file) {
      isolate({
        proj_id = PROJ.ID()
        species_name = input$anno_confirm_list
        if(ref_filepath() == 'Bifidobacterium_longum.fna'){
          proj_id = 'P3AB1A2717C'
          species_name = 'Bifidobacterium_longum'
        }
        pdf_path = file.path(DBPATH(), proj_id, 'result/snippy',species_name,'pdf','snp_phylo_tree.pdf')
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
  output$dbtn_snp_matrix <- downloadHandler(
    filename = function() {
      'snp_matrix.txt'
    },
    content = function(file) {
      isolate({
        proj_id = PROJ.ID()
        species_name = input$anno_confirm_list
        if(ref_filepath() == 'Bifidobacterium_longum.fna'){
          proj_id = 'P3AB1A2717C'
          species_name = 'Bifidobacterium_longum'
        }
        file_path = file.path(DBPATH(), proj_id, 'result/snippy',species_name,'snp_matrix.txt')
        if(!file.exists(file_path) || file.size(file_path) < 10 * 1024) {
          showModal(modalDialog(
            title = "ERROR",
            "Illegal operation. The file is incorrect!",
            alertType = "error"
          ))
          return(NULL)
        }
        showPageSpinner(type = 1, background = "#FFFFFF30")
        file.copy(file_path, file)
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

shinyApp(core.snp_analysis.UI, core.snp_analysis)
