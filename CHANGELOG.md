## Version 3.4

* Released August 7, 2013
* Configuration file now supports time slider **enabled_by_default** option. (see [Issue 7][ghi7])
* Improved error handling when ArcGIS web service fails to return metadata. (see [Issue 9][ghi9])
* Major internal rewrite of ArcGISHeatMapLayer (see [Issue 10][ghi10])
    * More closely reflects the design pattern of standard ArcGIS API for Flex layers.
    * Updated life-cycle of layer and events (invalidateProperties(), commitProperties(), invalidateLayer(), updateLayer())
    * useAMF true by default.
    * override various functions(addMapListeners, removeMapListeners, commmitProperties, removeAllChildren).
    * simplified updateLayer.
    * moved updateLayer logic to redrawHeatMapLayer.
    * new getHeatMapLayerData function which replaces generateHeatMap function.
    * new function loadHeatMapServiceInfo which loads service metadata (consolidates DetailsTask).
        * Listen to LayerEvent.LOAD to get access to the layer's layerDetails.
    * getHeatMapLayerData function now consolidates QueryTask to get features which generate the heat map.
    * parseURL re-written and now populates internal private data members (_urlService, and _urlLayerID).
    * removed events (getDetailsComplete, refreshStart, refreshEnd).
        * now listen to LayerEvent.UPDATE_START and LayerEvent.UPDATE_END to handle refresh effects as well as featureCount of layer.
        * new properties (featureCount and featureSet), provides access to the data used to generate the heat map.
    * gradientDict renamed to gradientArray
    * Deprecated package com.esri.samples.events.
    * Deprecated HeatMapEvent class.
    * Deprecated package com.esri.samples.geometry.
    * Deprecated HeatMapPoint class.
    * Updated class properties documentation and live sample links.
        * See [Issue 10][ghi10] and [Issue 11][ghi11].
* Updated [widget][widget-master] (see [Issue 13][ghi13])
* Updated [samples][samples-master] (see [Issue 12][ghi12])
* Updated [documentation][wikidoc]
* Updated build.properties to require ArcGIS API 3.4 for Flex. (see [Issue 8][ghi8])
* Updated meta.xml, widget version and description to reflect version 3.4. (see [Issue 8][ghi8])
* Added [gh_pages branch][gh_pages] and [ArcGISHeatMapLayer API Documentation][gh_pages_doc]

## Version 3.3

* Released May 14, 2013
* Updated build.properties to require ArcGIS API 3.3 for Flex.
* Updated meta.xml, widget version and description to reflect version 3.3.

## Version 3.2

* Released March 22, 2013
* Updated build.properties to require ArcGIS API 3.2 for Flex.
* Updated meta.xml, widget version and description to reflect version 3.2.

## Version 3.1

* Released January 10, 2013
* New ArcGISHeatMapLayer class supporting:
	* Custom color themes
	* Density radius
	* Clustering options
	* Calculator functions to dynamically calculate density and clustering
* Updated HeatMapGradientDict to support custom themes, including new function fillCustomPaletteMap to support calculating a heatmap theme based upon an array of hexidecimal colors.
* Renamed ColorMatrixUtil.blackAndWhiteFilter to ColorMatrixUtil.blackAndWhite.
* Updated HeatMapWidget
	* Added user interface component to HeatMapThemeView to support custom color theme.
	* Added user interface component to HeatMapWidget to support modifying heat map density radius.
	* Added configuration options to support density radius and custom theme color.
* Updated standalone samples (HeatMapTest.mxml, HeatMapTimeTest.mxml) to showcase new ArcGISHeatMapLayer functionality.
* Source code now all on GitHub.
	* New documentation on [Github wiki](../../wiki) for [Application Builder](../../wiki/Application-Builder) users and [Developers](../../wiki/Developers).
* Flex Library Project support including [Ant build file](build.xml) to compile source code into a library swc and library documentation (asdoc).
* Application Builder HeatMap widget is still available on [ArcGIS.com](http://www.arcgis.com/home/item.html?id=43daf0ffb1d34e31ad752da1340aeb40).
* Developers: Requires Adobe Flex SDK 4.6.0 and ArcGIS API 3.1 for Flex

## Version 3.0

* Released June 13, 2012
* Supports [Application Builder](http://resources.arcgis.com/en/help/flex-viewer/concepts/01m3/01m30000004m000000.htm "Viewer concepts") integration.
* Updated to support Spark components (removed mx components).
* Updated standalone samples (HeatMapTest.mxml, HeatMapTimeTest.mxml)
* Widget updates: now supports proxy and time slider configuration.
* Source code: Now uses same source code as included the API samples found on the [Resource Center](http://resources.arcgis.com/en/help/flex-api/samples/01nq/01nq0000007m000000.htm "API Samples") (ArcGISHeatMapLayer and related classes).
* Updated documentation with more screenshots.
* Developers: Requires Adobe Flex SDK 4.6.0 and ArcGIS API 3.0 for Flex

## Version 2.x support updates and bug fixes

* February 8, 2012 (ArcGIS Viewer 2.5 for Flex compatibility)

* November 1, 2011 (Fixed issue where widget was not reading useamf from config file correctly)

* August 11, 2011 (ArcGIS Viewer 2.4 for Flex compatibility)

## Version 2

* Released July 28, 2011 
* dynamic query support, time-aware support, UI enhancements.

## Version 1

* Released June 1, 2011

[gh_pages]: http://esri.github.io/heatmap-widget-flex
[gh_pages_doc]: http://esri.github.io/heatmap-widget-flex/docs
[wikidoc]: https://github.com/Esri/heatmap-widget-flex/wiki
[samples-master]: https://github.com/Esri/heatmap-widget-flex/tree/master/samples-HeatMap/src
[widget-master]: https://github.com/Esri/heatmap-widget-flex/tree/develop/viewer-HeatMapWidget/src/widgets/HeatMap

[ghi7]: https://github.com/Esri/heatmap-widget-flex/issues/7
[ghi8]: https://github.com/Esri/heatmap-widget-flex/issues/8
[ghi9]: https://github.com/esri/heatmap-widget-flex/issues/9
[ghi10]: https://github.com/esri/heatmap-widget-flex/issues/10 
[ghi11]: https://github.com/Esri/heatmap-widget-flex/issues/11
[ghi12]: https://github.com/Esri/heatmap-widget-flex/issues/12
[ghi13]: https://github.com/Esri/heatmap-widget-flex/issues/13