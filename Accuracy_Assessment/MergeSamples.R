#
# ExtractSamples.R
#
# Extracts point sampled measurements from raw OR data and saves them in new csv file
#
# Author: Jamie Perkins
# Email: jp2081@wildcats.unh.edu

findRawData <- function() {
  #generate list of paths for all raw data files
  rawDir = choose.dir(caption = 'Select Data Directory')
  
  #search for all files with extention _raw
  rawFiles = list.files(path = rawDir, pattern = '*_raw*', full.names = TRUE, recursive = TRUE)
  
  return(rawFiles)
  
}

extractSamples <- function(rawFiles) {
  #find tables with specified data and save as new .csv
  
  #choose save directory
  saveHead = choose.dir(caption = 'Select Save Directory')
  
  defaultPg = 'Sample Trees'
  
  for (file in rawFiles) {
    
    #extract plot code
    plotCode = substr(basename(file),1,3)
    
    print(paste('Working on', plotCode))
    
    #construct save path
    saveBase = paste(plotCode, '_sampleTrees.csv', sep = '')
    savePath = file.path(saveHead, saveBase)
    
    xlFile = loadWorkbook(file)
    sheetNames = getSheets(xlFile)
    
    #check if default is in workbook
    if (defaultPg %in% sheetNames) {
      
      sampleSheet = defaultPg
      
    } else {
      
      #select from UI
      sampleSheet = select.list(sheetNames)
      
    }
    
    preTable = readWorksheet(xlFile, sampleSheet)
    
    findIndex = 'Tree #'
    #find index of starting row
    for (i in 1:nrow(preTable)) {
      
      sampleRow = preTable[i,]
      if (findIndex %in% sampleRow) {
        
        rowNum = i
        
      }
      
    }
    
    sampleTable = readWorksheet(xlFile, sampleSheet, rowNum)
    
    #write to csv file
    write.csv(sampleTable, file = savePath)
      
  }
  
}

#check for proper packages
library(XLConnect)

#run script
rawFiles = findRawData()
extractSamples(rawFiles)

