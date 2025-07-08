#### SET HELP ####
help.qc <- fluidPage(
  fixedRow(
        class = "scrollable-container",
    column(width = 11,
           h3('Quality Control'), br(),
           
           p(style = 'word-break:break-word',
             '
             Fastp was employed to control the quality of the samples. 
             Users can refer to the metrics presented in the table on the right to eliminate substandard samples and select appropriate samples for further analysis. 
             By default, no filtering culls are applied.
             '
           ),
           
           hr(),
           
           tags$ol(
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/qc/image_ui_01.png'), br(), br(),
             tags$li(tags$b('Run Quality Control:'), br(),
                     'Click the button to execute the operation.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/qc/image_ui_02.png'), br(), br(),
             tags$li(tags$b('Filter Sample:'), br(),
                     'When the user selects yes, the slide boxes containing various metrics for filtering will be displayed.'), br(),
             tags$li(tags$b('Filter:'), br(),
                     'After setting the sliders, click the button to confirm the filter.'), br(),
             tags$li(tags$b('Reset:'), br(),
                     'Reset the filter to return to the original sample list.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/qc/image_fastp_summary.png'), br(), br(),
             tags$li(tags$b('Fastp Summary Table:'), br(),
                     'The values of each metric for the samples, including total reads, clean reads, cut reads, Q30 rates, GC content, and duplication rates.'), br(),
             
           )
    )
  )
)
