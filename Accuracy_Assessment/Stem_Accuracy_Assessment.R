#
# Stem_Accuracy_Assessment.r
#
# Inputs: CSV Distance Matrix
# Output: CSV Distance Matrix, featuring only unique pairs of actual and estimated stems
#
# Author: Jamie Perkins
# Email: jp2081@wildcats.unh.edu
#

readDistMat <- function(csvPath, usrCols = NULL, chooseHdr=FALSE) {
  
  #define columns to be used
  if (chooseHdr == FALSE) {
    
    colsList = c(1,2,3)
    
  } else {
    
    colsList = usrCols
    
  }
  
  #open distance matrix
  distMat = read.csv(csvPath, header = TRUE)
  distOrder = distMat[order(distMat[,colsList[3]]),]
  newMat = distOrder[1,]
  
  print(nrow(distOrder))
  
  for(i in 1:nrow(distOrder)) {
    
    actStem = distOrder[i, colsList[1]]
    estStem = distOrder[i, colsList[2]]
    
    if ((actStem %in% newMat[, 1]) | (estStem %in% newMat[,2])) {
      #pass if matching values in new table
      next
      
    } else {
      newMat = rbind(newMat, distOrder[i,])
    }
  }
  
  return(newMat)
  
}


statsGen <- function(newMat) {
  
  totStem = nrow(newMat)
  #generate statistics for stem accuracy data
  meanDist = mean(newMat[,3])
  
  #count values keep track of distance thresholds
  count1 = 0
  count2 = 0
  count3 = 0
  count4 = 0
  count5 = 0
  for (t in 1:dim(newMat)[1]) {
    
    val = newMat[t,3]
    
    if (val <= 5) {
      count5 = count5 + 1
    }
    if (val <= 4) {
      count4 = count4 + 1
    }
    if (val <=3) {
      count3 = count3 + 1
    }
    if (val <= 2) {
      count2 = count2 + 1
    }
    if (val <= 1) {
      count1 = count1 + 1
    }
    
  }
  
  #create new data frame
  statsCols = c('1m', '2m', '3m', '4m', '5m')
  rawThresh = c(count1, count2, count3, count4, count5)
  percentThresh = rawThresh/totStem
  
  statsFrame = data.frame(rawThresh, percentThresh)
  rownames(statsFrame) = statsCols
  
  return(statsFrame)
  
}


bioStats <- function(newMat, plotCode) {
  
  #generate stats for height and crown radious stats
  sampleDir = choose.dir(caption = 'Choose Data Directory')
  
  dirList = list.files(sampleDir)
  
  for (file in dirList) {
    
    if (grepl(plotCode, file, ignore.case = TRUE)) {
      
      dataPath = file.path(sampleDir, file)
      
    }
    
  }
  
  dataFile = read.csv(dataPath, stringsAsFactors = FALSE)
  
  #create new dataframe
  #bioNames = c('TreeID', 'DataID', 'EstID', 'Distance')
  bioNames = c('TreeID', 'DataID', 'EstID', 'Distance', 'Actual Height', 'Est Height', 'Actual Radius', 'Est Radius', 'Diff Height', 'Diff Radius')
  bioFrame = data.frame(matrix(ncol = length(bioNames), nrow = (nrow(dataFile)-1)))
  colnames(bioFrame) = bioNames
  
  rCount = 1
  
  for (nr in 1:nrow(newMat)) {
    #lookup in newMat
    nrID = newMat[nr, 1]
    
    for (dr in 1:nrow(dataFile)) {
      #lookup ID in sampleTree file
      drID = dataFile[dr, 2]
      
      if (nrID == drID) {
        
        #once confirmed treeID's match, assign all data vars
        estID = as.numeric(newMat[nr, 2])
        distVal = as.numeric(newMat[nr, 3])
        actHT = as.numeric(dataFile[dr, 5])
        estHT = as.numeric(newMat[nr, 6])
        estRD = as.numeric(newMat[nr, 5])
        
        #find measured mean rad
        actRD = mean(as.numeric(dataFile[dr, 7:10]))
        
        #calc accuracy values
        difHT = (estHT-actHT)/actHT
        difRD = (estRD-actRD)/actRD
        
        newRow = c(nrID, drID, estID, distVal, actHT, estHT, actRD, estRD, difHT, difRD)
        
        #print(newRow)
        
        bioFrame[rCount,] = newRow
        
        #increase row count
        rCount = rCount + 1
        
      }
        
    }
      
  }
  
  return(bioFrame)

}


csvPath = file.choose()
plotCode = substr(basename(csvPath),1,3)
newMat = readDistMat(csvPath)
statsFrame = statsGen(newMat)
bioFrame = bioStats(newMat, plotCode)