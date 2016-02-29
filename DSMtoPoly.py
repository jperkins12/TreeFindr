#
#DSM to Polygon
#v0.1
#
#Function: extracts polygons representing tree crowns from a rasterized height field
#
#Input: DSM layer, generated from lidar point cloud or otherwise, normalized for elevation
#Ground should be set to 0
#
#output: shapefile featuring polygons representative of tree crown areas
#
#Author: Jamie Perkins
#Email: jp2081@wildcats.unh.edu
#

#GUI Inputs
##DSMtoPoly=name
##TreeFindr=group
##Plot_Code=string
##DSM=raster
##Use_Mask=boolean False
##Mask_Image=raster
##Tree_Crowns=output vector
##Stem_Estimations=output vector
##Set_temp_Directory=folder

from qgis.core import *
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from qgis.analysis import *
import processing
import os

progress.setText( '\nStarting...' )

#change variable names to something more manageable
dsm = DSM
plotCode = Plot_Code
tempDir = Set_temp_Directory
mask = Mask_Image
maskQuery = Use_Mask
if not maskQuery:
    mask = None

progress.setInfo('\nIntermediate files will be saved to {0}'.format(tempDir))


def removeTopo(dsm_raster, mask_raster, maskQ):
    
    global tempDir, plotCode
    #entries list for storing raster calculator info
    entries = []
    
    #check for mask layer
    if maskQ is True:
        progress.setInfo( '\n Mask file: {0}'.format(mask_raster) )
        maskQ = True
        #load mask layer
        mask_info = QFileInfo(mask_raster)
        mName = mask_info.basename()
        maskLayer = QgsRasterLayer(mask_raster,mName)
        if not maskLayer.isValid():
            progress.setInfo( 'Mask layer failed to load!' )
            
        mask1 = QgsRasterCalculatorEntry()
        mask1.ref = 'mask@1'
        mask1.raster = maskLayer
        mask1.bandNumber = 1
        entries.append( mask1 )
    else:
        progress.setInfo( '\nNo mask used' )

    #set threshold values
    #all below will be set to 0
    threshdn = 3
    #all above will be set to 0
    threshup = 80
    
    progress.setInfo( '\nRemoving topography below threshold {0} and above {1}'.format(threshdn, threshup) )
    
    #load dsm layer
    file_info = QFileInfo(dsm_raster)
    bName = file_info.baseName()
    dsmLayer = QgsRasterLayer(dsm_raster, bName)
    if not dsmLayer.isValid():
        progress.setInfo( 'DSM layer failed to load!' )
    
    #removes all topopgraphy below a threshold to isolate tree crowns in DSM
    #Define band1
    dsm1 = QgsRasterCalculatorEntry()
    dsm1.ref = 'dsm@1'
    dsm1.raster = dsmLayer
    dsm1.bandNumber = 1
    entries.append( dsm1 )

    #generate out file name
    calcFile = '{0}_noTopo.tif'.format( plotCode)
    calcPath = os.path.join( tempDir, calcFile)
    progress.setInfo( 'Writing to {0}'.format(calcPath) )

    #process calculation with input extent and resolution
    #calculation is to remove all data points below threshold
    if maskQ is False:
        calcString = '({0}>{1})*({0}<{2})*{0}'.format(dsm1.ref, threshdn, threshup)
    else:
        calcString = '({0}>{1})*({0}<{2})*{0}*{3}'.format(dsm1.ref, threshdn, threshup,mask1.ref)
    #calcStringLog = 'Raster calculation: {0}'.format(calcString)
    #QgsMessageLog.logMessage(calcStringLog, 'DSMtoPoly')

    calc = QgsRasterCalculator( calcString, calcPath, 'GTiff', dsmLayer.extent(), dsmLayer.width(), dsmLayer.height(),  entries )

    #report and calculation errors
    #lookup error outputs on QGIS API tutorial
    er = calc.processCalculation()
    if er is not 0:
        progress.setInfo( 'Calc error {0}'.format(er) )
    
    return calcPath

def closeFilter(no_topo):
    
    #generate filtered file path
    #and process closing filter
    
    global tempDir, plotCode
    progress.setInfo( '\nPerforming closing filter' )
    
    filteredName = '{0}_Filtered.tif'.format( plotCode)
    filteredPath = os.path.join( tempDir, filteredName)
    progress.setInfo( 'Writing to {0}'.format(filteredPath) )
    
    processing.runalg('saga:morphologicalfilter', no_topo,  1,  2, 3, filteredPath)
    
    return filteredPath    

def segmentation(filtered_layer):
    
    global tempDir, plotCode
    
    progress.setInfo( '\nSegmenting image' )
    segName = '{0}_seg.tif'.format( plotCode)
    segPath = os.path.join( tempDir, segName)
    progress.setInfo( 'Writing to {0}'.format(segPath) )
    
    #runs watershed segmenation on image
    processing.runalg('saga:watershedsegmentation',  filtered_layer, 1, 1, 1, 4, True, True, segPath, None, None)
    
    progress.setInfo( 'Image segmented' )
    
    return segPath

def segCalc(segmentation_layer, filtered_layer):
    
    #multiplies no topo by dsm to isolate tree crowns
    #load filtered raster
    
    global tempDir, plotCode
    progress.setInfo( '\nRemoving ground from segmentation raster' )
    
    filteredInfo = QFileInfo(filtered_layer)
    filteredBase = filteredInfo.baseName()
    filtLayer = QgsRasterLayer(filtered_layer, filteredBase)
    if not filtLayer.isValid():
        progress.setInfo( 'Filtered layer failed to load!' )
    
    #fetch filtered raster params
    entries = []
    #Define filtered band1
    filt1 = QgsRasterCalculatorEntry()
    filt1.ref = 'filt@1'
    filt1.raster = filtLayer
    filt1.bandNumber = 1
    entries.append( filt1 )
    
    #load segmented raster
    segInfo = QFileInfo(segmentation_layer)
    segBase = segInfo.baseName()
    segLayer = QgsRasterLayer(segmentation_layer, segBase)
    if not segLayer.isValid():
        progress.setInfo( 'Segmentation layer failed to load!' )
    
    #fetch segmented raster params
    #Define filtered band1
    seg1 = QgsRasterCalculatorEntry()
    seg1.ref = 'seg@1'
    seg1.raster = segLayer
    seg1.bandNumber = 1
    entries.append( seg1 )
    
    calcBase = '{0}_segRaster_clean.tif'.format( plotCode)
    calcPath = os.path.join( tempDir, calcBase)
    progress.setInfo( 'Writing to {0}'.format(calcPath) )
    
    calcString = '({0} > 0)*{1}'.format(filt1.ref, seg1.ref)
    #print calcString
    
    calc = QgsRasterCalculator(calcString, calcPath, 'GTiff', segLayer.extent(), segLayer.width(), segLayer.height(),  entries )

    er2 = calc.processCalculation()
    if er2 is not 0:
        progress.setInfo( 'Calc error {0}'.format(er2) )
    
    return calcPath

def polygonize(segmented_image):
    
    #outputs cleaned vectorized tree crowns
    #setup output path
    
    global tempDir, plotCode
    progress.setInfo( '\nPolygonizing segmentation layer' )
    
    vecBase = '{0}_treeCrowns.shp'.format( plotCode)
    vecPath = os.path.join( tempDir, vecBase)
    progress.setInfo( 'Writing to {0}'.format(vecPath) )
    
    processing.runalg('gdalogr:polygonize', segmented_image, 'DN', vecPath)
    
    #load new layer
    treeLayer = QgsVectorLayer(vecPath, 'treePolygons','ogr')
    if not treeLayer.isValid():
        progress.setInfo( 'treeLayer failed to load!' )
    
    progress.setInfo( '\nRemoving ground polygons' )
    
    #iterate over features, store those with DN=0 in list
    rmList = []
    iter = treeLayer.getFeatures()
    for f in iter:
        fid = f.id()
        #print fid
        fdn = f[0]
        if fdn == 0:
            rmList.append( fid )
            
    caps = treeLayer.dataProvider().capabilities()
    if caps & QgsVectorDataProvider.DeleteFeatures:
        res = treeLayer.dataProvider().deleteFeatures(rmList)
    else:
        progress.setInfo( 'Unable to remove ground polygons' )
    
    progress.setInfo( '\nCleaning tree polygons' )
    
    #set extent for v.clean
    ext = treeLayer.extent()
    a = ext.xMinimum()
    b = ext.xMaximum()
    c = ext.yMinimum()
    d = ext.yMaximum()
    regionString = '{0},{1},{2},{3}'.format(a,b,c,d)
    
    #new vector output name
    cleanBase = vecBase.replace('.shp', '_clean.shp')
    cleanPath = os.path.join( tempDir, cleanBase)
    progress.setInfo( 'Writing to {0}'.format(cleanPath) )
    
    #clean up tree polygons, remove small areas
    #10 -> rmarea
    #threshold -> 1.4
    #snap tolerance -> -1 (no snapping)
    #v.in.org min area -> 0.0001
    processing.runalg('grass:v.clean', vecPath, 10, 1.4, regionString, -1, 0.0001, cleanPath, None)
    
    #open cleaned layer
    cleanLayer = QgsVectorLayer(cleanPath, 'cleanPolygons', 'ogr')
    if not cleanLayer.isValid():
        progress.setInfo( 'Cleaned layer failed to load!' )
    
    #using caps again because the data provider did not change
    progress.setInfo( '\nCreating TreeID field' )
    if caps & QgsVectorDataProvider.AddAttributes:
        newfield = cleanLayer.dataProvider().addAttributes([QgsField('TreeID', QVariant.Int)])
    else:
        progress.setInfo( 'Cannot add TreeID field' )
        
    cleanLayer.updateFields()
    
    #add unique ID to each feature
    if caps & QgsVectorDataProvider.ChangeAttributeValues:
        cleanLayer.startEditing()
        cleanIter = cleanLayer.getFeatures()
        indexVal = 0
        for item in cleanIter:
            item['TreeID'] = indexVal
            indexVal += 1
            cleanLayer.updateFeature(item)
            
        cleanLayer.commitChanges()
        
        #remove extra fields
        #search for unnecessary fields
        count = 0
        dList = []
        for field in cleanLayer.pendingFields():
            if field.name() != 'TreeID':
                dList.append(count)
            count += 1
            
        progress.setInfo( 'Removing DN field' )
        remfield = cleanLayer.dataProvider().deleteAttributes(dList)
        
    else:
        progress.setInfo( 'Cannot modify attributes' )
        
    cleanLayer.updateFields()
    
    #generate centroids path
    progress.setInfo( '\nEstimating stem locations' )
    stemBase = '{0}_stemEst.shp'.format( plotCode)
    stemPath = os.path.join( tempDir, stemBase)
    #output polygon centroids
    processing.runalg('qgis:polygoncentroids', cleanPath, stemPath)
    if not os.path.exists(stemPath):
        process.setInfo( 'Centroid layer failed!' )

    return cleanPath, stemPath

#
#run all processes
#
notopoLayer = removeTopo(dsm, mask, maskQuery)
filteredLayer = closeFilter(notopoLayer)
segLayer = segmentation(filteredLayer)
cleanSeg = segCalc(segLayer, filteredLayer)
treeVectors, stemEst = polygonize(cleanSeg)

Tree_Crowns = treeVectors
Stem_Estimations = stemEst

progress.setInfo( 'finished\n' )
