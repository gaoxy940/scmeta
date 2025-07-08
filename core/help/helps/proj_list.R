#### SET HELP ####
help.proj_list <- fluidPage(
  
  fixedRow(
    class = "scrollable-container",
    column(width = 11,
           h3('Project List'), br(),
           
           p(style = 'word-break:break-word',
             '
             Here, users can upload personal datasets and perform data preprocessing. 
             scMETA allows multiple samples to be uploaded as a compressed package and provides a temporary project repository for users.
             '
           ),
           p(style = 'word-break:break-word',
             '
             scMETA features two built-in demo projects designed to clearly illustrate its functionalities and assist users in getting started more quickly. 
             Additionally, a downloadable example project is available to guide users in uploading their own data.
             '
           ),

           br(),
           h4('Upload the raw sequencing data and conduct de novo data analysis'),
           p(style = 'word-break:break-word',
             '
             In addition to the original paired-end sequencing files in FASTQ format, if there is a grouping, the user must also upload a file named "group.txt" to provide scMETA with the necessary grouping information. 
             The FASTQ files and the group.txt file (if applicable) should be packaged into a .zip or .tar.gz archive before uploading. The server will check the input format and execute FastQC to verify data integrity.
             Inappropriate samples are flagged and automatically discarded by the server during subsequent analyses.
             '
           ),
           p(style = 'word-break:break-word',
             '
             Please note that this is intended for small sample uploads only. 
             If the number of samples exceeds ten, online real-time analysis will not be applicable because of computation time, so it is recommended to use the "Submit Task" module to upload data and submit task.
             '
           ),

           br(),
           h4('Upload the result files received from the "Submit Task" module for visualization'),
           p('The result files of tasks submitted through the "Submit Task" module will be sent to users as email attachments. 
           Users can download and review these files. Additionally, users have the option to upload the results to the platform for visualization. 
           However, online analysis is still not supported.'),

           br(),br(),
           p(style = 'word-break:break-word',
             '
             To begin the analysis, click on a project from the table on the right. 
             You may choose either a demo project or a newly created project for the subsequent analysis.
             '
           ),
           
           hr(),
           
           tags$ol(
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/proj_list/image_ui_1.png'), br(), br(),
             tags$li(tags$b('Project Name:'), br(),
                     'To create a new project, enter the project name here first. The default is "MyProject"'), br(),
             tags$li(tags$b('Package and Upload Data:'), br(),
                     'Package all the files into a zip file and upload it here.'), br(),
        
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/proj_list/image_ui_2.png'), br(), br(),
             tags$li(tags$b('Upload Data:'), br(),
                     '
                     Enter the project name and select a local path to upload user data. Then, click the button to add a new project. 
                     After this, the newly created project, along with a system-generated unique ID, will be displayed in the table on the right. 
                     (Note: The upload path only supports English letters, numbers, and characters.)
                     '
                     ), br(),
             tags$li(tags$b('Upload Exemplar:'), br(),
                     '
                     This is a test case that includes six paired-end sequencing samples along with their corresponding grouping information.
                     '), br(),
             tags$li(tags$b('Download Exemplar:'), br(),
                     '
                     Download this test case to your local device. 
                     Users can view the data formats requested by the server, including the format of the group.txt file.
                     '), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/proj_list/image_ui_3.png'), br(), br(),
             tags$li(tags$b('Upload the result file returned by scMETA:'), br(),
                     'upload the ZIP file received in the email from scMETA to visualize the results.'), br(),

             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/proj_list/image_proj_info.png'), br(), br(),
             tags$li(tags$b('Project Information:'), br(),
                     'A comprehensive list of project details, including the project ID, project name, number of samples included, and group information.'), br(),
             tags$li(tags$b('Delect Project:'), br(),
                     'Select a project and click this button to delete it along with all the related data.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/proj_list/image_sample_info.png'), br(), br(),
             tags$li(tags$b('Sample Information:'), br(),
                     'Define group information for each sample. Currently, scMETA only offers a subsequent comparative analysis between two groups: negative control and treatment.'), br(),
           )
    )
  )
)
