#
# Stem_Accuracy_Assessment.r
#
# Inputs: CSV Distance Matrix
# Output: CSV Distance Matrix, featuring only unique pairs of actual and estimated stems
#
# Author: Jamie Perkins
# Email: jp2081@wildcats.unh.edu
#

readDistMat <- function(csvPath) {
  
  #open distance matrix
  distMat = read.csv(csvPath, header = TRUE)
  distOrder = distMat[order(distMat$Distance),]
  newMat = distOrder[1,]
  
  for(i in 1:dim(distOrder)[1]) {
    
    actStem = distOrder[i, 'InputID']
    estStem = distOrder[i, 'TargetID']
    
    if ((actStem %in% newMat$InputID) | (estStem %in% newMat$TargetID)) {
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
  meanDist = mean(newMat$Distance)
  
  #count values keep track of distance thresholds
  count1 = 0
  count2 = 0
  count3 = 0
  count4 = 0
  count5 = 0
  for (t in 1:dim(newMat)[1]) {
    
    val = newMat[t,'Distance']
    
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

csvPath = file.choose()
newMat = readDistMat(csvPath)
statsFrame = statsGen(newMat)
