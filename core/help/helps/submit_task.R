#### SET HELP ####
help.submit <- fluidPage(
  fixedRow(
        class = "scrollable-container",
    column(width = 11,
           h3('Submit Task'), br(),
           
           p(style = 'word-break:break-word',
             '
             If the number of samples to be analyzed is large and online analysis is not feasible, users can package and upload the data here. 
             After configuring the necessary steps and parameters for analysis and submitting a designated email address, the web server processes the task in the background. 
             This process may take several days, depending on the volume of data. 
             Once the task is complete, the server compiles the results of the analysis and sends them to the email address provided by the user.
             '
           ),
           
           hr(),
           
           tags$ol(

             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/submit_task/image_ui_01.png'), br(), br(),
             tags$li(tags$b('Upload Data:'), br(),
                     'Enter the project name and select one local path to upload user data, and then click this button to upload data.'), br(),
             tags$li(tags$b('Upload Exemplar:'), br(),
                     'This is a test case that includes six paired-end sequencing samples along with their corresponding grouping information.'), br(),
             tags$li(tags$b('Download Exemplar:'), br(),
                     '
                     Download this test case to your local device. 
                     Users can view the data formats requested by the server, including the format of the group.txt file.
                     '), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/submit_task/image_ui_02.png'), br(), br(),
             tags$li(tags$b('Parameter Setting:'), br(),
                     '
                     For user data, quality control and species annotation are the default steps performed, as functional annotation and SNP analysis depend on the results of the first two analyses. 
                     Several methods and databases are available for species annotation. 
                     For SNP analysis, both the specified species and the reference genome are required.
                     '), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/submit_task/image_ui_03.png'), br(), br(),
             tags$li(tags$b('Submit the Task:'), br(),
                     '
                     Enter a valid email address and click the button. The server will first determine whether the selected parameters are valid. 
                     After confirmation, the server will receive the task. 
                     The task may take several days to execute, depending on the volume of data, so please be patient. 
                     Once the analysis is complete, the results will be packaged and sent to the user-provided email address.
                     '), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/submit_task/image_proj_info.png'), br(), br(),
             tags$li(tags$b('Project Information:'), br(),
                     'This is a test case that includes six paired-end sequencing samples along with their corresponding grouping information.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/submit_task/image_parameter_info.png'), br(), br(),
             tags$li(tags$b('Parameter Information:'), br(),
                     'Summary of user\'s selection of parameters'), br(),
           )
    )
  )
)
