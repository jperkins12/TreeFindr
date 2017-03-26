![alt tag](https://github.com/jperkins12/TreeFindr/blob/master/Images/TreeFindr_Logo.png)
v0.1

### Overview:
The TreeFindr project is aimed at providing an open-source pathway to estimating forest biometrics from rasterized forest height profiles. It is currently in the early stages of development as a QGIS plugin with an accuracy assessment in R.

### Using the QGIS plugin:

![alt tag](https://github.com/jperkins12/TreeFindr/blob/master/Images/Execute_Window.PNG)

1. **Plot Code:**

  Used to identify outputs. Can be any string, in this case the format is two letters followed by a number.

2. **DSM:**

  The digital surface model layer. A raster height map featuring vegetation.
  
3. **Mask Image:**

  *(Optional)* A binary raster image that indicates desired image regions to include in analysis (Include = 1, Exclude = 2). Must ensure 'Use Mask' option is checked in order to use.
  
4. **Segmentation Threshold:**
  
  *(Default = 4)* Seed to saddle difference in watershed segmentation. Higher values result in more segments merging together.

5. **Clean Threshold:**

  *(Default = 1.4)* Threshold for v.clean algorithm. Higher values result in fewer remaining small areas.
  
6. **Set temp Directory:**

  Choose desired directory to store intermediate files. I have never tried not using this so the 'optional' tag may in fact be incorrect. Useful for identifying the source of errors in the processing pathway.

7. **Tree Crowns:**

  The output vector layer indicating tree crown areas.

8. **Stem Estimations:**

  The output vector layer indicating estimated stem locations as points.

#### Notes
- Only tested with ENVI formatted height profile as input height field. For some reason does not work with BCAL lidar height profile outputs.
- Reqires the OSGeo4W and SAGA modules to be properly installed within QGIS.

##### Logo Information:
- Tree graphic by <a href="http://www.freepik.com/">Freepik</a> from <a href="http://www.flaticon.com/">Flaticon</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a>. Made with <a href="http://logomakr.com" title="Logo Maker">Logo Maker</a>
