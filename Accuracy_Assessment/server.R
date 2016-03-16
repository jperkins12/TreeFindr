#server.R
library(shiny)
#source('Stem_Accuracy_Assessment.R')

shinyServer(function(input, output) {
  
  output$contents <- renderTable({
    
    #output raw distance matrix table
    inFile = input$file
    #check file is uploaded
    if (is.null(inFile))
      return(NULL)
    
    filePath = inFile$datapath
      
    read.csv(filePath)
    
  })
  
  output$stemStats <- renderTable({
    
    #generate stem stats table
    inFile = input$file
    #check file is uploaded
    if (is.null(inFile))
      return()
    
    filePath = inFile$datapath
    
    newMat = readDistMat(filePath, usrCols, chooseHdr = TRUE)
    statsDisplay = statsGen(newMat)
    
  })
  
  output$fileName <- renderText({
    #output file name for display
    inFile = input$file
    txt = inFile$name
    
  })
  
  output$selectList <- renderUI({
    #skip if no uploaded table
    if (is.null(input$file)) {
      return()
    }
    
    #get header names
    datf = input$file
    dat = read.csv(datf$datapath)
    headers = names(dat)
    
    #create selectable list
    selectInput('selectAct',
                label = 'Actual Stem Column',
                choices = headers,
                selected = 1)
    
  })
  
  output$selectList2 <- renderUI({
    
    #skip if no uploaded table
    if (is.null(input$file)) {
      return()
    }
    
    #get header names
    datf = input$file
    dat = read.csv(datf$datapath)
    headers = names(dat)
    
    selectInput('selectEst',
                label = 'Estimated Stem Column',
                choices = headers,
                selected = 2)
  })

  output$selectList3 <- renderUI({
    
    #skip if no uploaded table
    if (is.null(input$file)) {
      return()
    }
    
    #get header names
    datf = input$file
    dat = read.csv(datf$datapath)
    headers = names(dat)
    
    selectInput('selectDist',
                label = 'Distance Column',
                choices = headers,
                selected = 3)
  })    
  
})