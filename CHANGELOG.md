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
