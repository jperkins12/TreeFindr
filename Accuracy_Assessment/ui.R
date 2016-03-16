#ui.R
library(shiny)

shinyUI(fluidPage(
  #titlePanel('TreeFindr Accuracy Assessment'),
  titlePanel(img(src = 'TreeFindr_Logo.png', width = 1148/2, height = 249/2)),
  h4('Stem Accuracy Assessment'),
  br(),

  sidebarLayout(
    sidebarPanel(h2('Parameters'),
                 
                 fileInput('file', label = 'Select Distance Matrix'),
                 
                 #reactively generated list selections
                 uiOutput('selectList'),
                 uiOutput('selectList2'),
                 uiOutput('selectList3'),
                 
                 br(),
                 
                 actionButton('go', 'Submit')
                 
    ),
    
    mainPanel(
      conditionalPanel(
        condition = "input.go == 0",
        h4(textOutput('fileName')),
        tableOutput('contents')
      ),
      conditionalPanel(
        condition = "input.go > 0",
        h4('Stem Accuracy Values'),
        tableOutput('stemStats')
      )
    )
  )
))