# TreeFindr
v0.1

### Overview:
The TreeFindr project is aimed at providing an open-source pathway to estimating forest biometrics from rasterized forest height profiles. It is currently in the early stages of development as a QGIS plugin.

Input: Rasterized height field. Normalized for evelvation (ex. lowest point should = 0)
Output: Polygon shapefile featuring delineated tree crowns.

Notes
- Only tested with ENVI formatted height profile as input height field. For some reason does not work with BCAL lidar height profile outputs.
- Reqires the OSGeo4W and SAGA modules to be properly installed within QGIS.
