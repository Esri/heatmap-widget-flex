///////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2013 Esri. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////
package com.esri.ags.samples.layers
{

import com.esri.ags.FeatureSet;
import com.esri.ags.Graphic;
import com.esri.ags.TimeExtent;
import com.esri.ags.clusterers.supportClasses.Cluster;
import com.esri.ags.events.LayerEvent;
import com.esri.ags.events.TimeExtentEvent;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.Layer;
import com.esri.ags.layers.supportClasses.LayerDetails;
import com.esri.ags.samples.layers.supportClasses.HeatMapGradientDict;
import com.esri.ags.tasks.DetailsTask;
import com.esri.ags.tasks.QueryTask;
import com.esri.ags.tasks.supportClasses.Query;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Dictionary;

import mx.collections.ArrayList;
import mx.collections.IList;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;

/**
 * Allows you to generate a client-side dynamic heatmap on the fly through querying a layer resource (points only) exposed by the ArcGIS Server REST API (available in ArcGIS Server 9.3 and above).
 * This layer also supports time through setting the time extent directly on the layer, or through the map the layer is contained within.
 * It is also aware of extent changes and time extent events triggered by its parent containing map, these events will cause the layer to be re-queried and the heatmap generated again.
 *
 * <p>Note that ArcGISHeatMapLayer, like all layers, extend <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/core/UIComponent.html" target="external">UIComponent</a> and thus include basic mouse events, for example:
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html#event:click" target="external">click</a>,
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html#event:mouseOut" target="external">mouseOut</a>,
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html#event:mouseOver" target="external">mouseOver</a>, and
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html#event:mouseDown" target="external">mouseDown</a>,
 * as well as other events like
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/core/UIComponent.html#event:show" target="external">show</a> and
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/core/UIComponent.html#event:hide" target="external">hide</a>,
 * and general properties, such as
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObject.html#alpha" target="external">alpha</a> and
 * <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObject.html#visible" target="external">visible</a>.</p>
 *
 * MXML usage of ArcGISHeatMapLayer:
 * <listing version="3.0">
 * &lt;esri:Map&gt;
 *      &lt;layers:ArcGISHeatMapLayer id="heatMapLayer"
 *                                    outFields="&#42;"
 *                                    url="http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Earthquakes/Since_1970/MapServer/0"/&gt;
 * &lt;/esri:Map&gt;</listing>
 *
 * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/FeatureSet.html&com/esri/ags/class-list.html com.esri.ags.FeatureSet
 * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/events/LayerEvent.html&com/esri/ags/events/class-list.html com.esri.ags.events.LayerEvent
 * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/layers/Layer.html&com/esri/ags/layers/class-list.html com.esri.ags.layers.Layer
 *
 * @see http://developers.arcgis.com/en/flex/sample-code/heatmap.htm Live sample - HeatMap layer
 * @see http://developers.arcgis.com/en/flex/sample-code/heatmap-weighted.htm Live sample - Weighted HeatMap layer (uses calculator functions)
 * @see http://esri.github.io/heatmap-widget-flex Live sample - ArcGIS Viewer for Flex HeatMap Widget
 */
public class ArcGISHeatMapLayer extends Layer
{
    private var _urlChanged:Boolean = false;
    private var _themeChanged:Boolean = false;

    private var _url:String;
    private var _urlService:String;
    private var _urlLayerID:String;
    private var _where:String = "1=1";
    private var _useAMF:Boolean = true;
    private var _proxyURL:String;
    private var _token:String;
    private var _outFields:Array;
    private var _timeExtent:TimeExtent;
    private var _layerDetails:LayerDetails;
    private var _featureCount:int;
    private var _featureSet:FeatureSet;

    private var _heatMapQueryTask:QueryTask = new QueryTask();
    private var _heatMapQuery:Query = new Query();

    private var _heatMapTheme:String = HeatMapGradientDict.RAINBOW_TYPE;
    private var _dataProvider:IList;
    private var _gradientArray:Array;
    private var _bitmapData:BitmapData;

    private static const POINT:Point = new Point();
    private const BLURFILTER:BlurFilter = new BlurFilter(4, 4, BitmapFilterQuality.LOW);
    private var _densityRadius:int = 25;

    private var _shape:Shape = new Shape();
    private var _center:MapPoint;
    private var _world:Number;
    private var _wrapAround:Function;

    private const _matrix1:Matrix = new Matrix();
    private const _matrix2:Matrix = new Matrix();
    private const COLORS:Array = [ 0, 0 ];
    private const ALPHAS:Array = [ 1, 1 ];
    private const RATIOS:Array = [ 0, 255 ];

    private var _clusterCount:int = 0;
    private var _clusterSize:int = 0;
    private var _clusterMaxWeight:Number = 0.0;
    private var _featureRadiusCalculator:Function = internalFeatureRadiusCalculator;
    private var _clusterRadiusCalculator:Function = internalClusterRadiusCalculator;
    private var _featureIndexCalculator:Function = internalFeatureCalculator;
    private var _clusterIndexCalculator:Function = internalClusterCalculator;
    private var _clusterWeightCalculator:Function = internalWeightCalculator;

    /**
     * Creates a new ArcGISHeatMapLayer object.
     *
     * @param url URL to the ArcGIS Server REST resource that represents a point layer in map service or feature service.
     * @param proxyURL The URL to proxy the request through.
     * @param token Token for accessing a secure dynamic ArcGIS service.
     *
     */
    public function ArcGISHeatMapLayer(url:String = null, proxyUrl:String = null, token:String = null)
    {
        super();

        mouseEnabled = false;
        mouseChildren = false;

        this.url = url;
        this.proxyURL = proxyURL;
        this.token = token;
        _gradientArray = HeatMapGradientDict.gradientArray(_heatMapTheme);
    }

    //--------------------------------------------------------------------------
    //
    // Internal override functions
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override protected function addMapListeners():void
    {
        super.addMapListeners();

        if (map)
        {
            map.addEventListener(TimeExtentEvent.TIME_EXTENT_CHANGE, timeExtentChangeHandler);
        }
    }

    /**
      * @private
      */
    override protected function removeMapListeners():void
    {
        super.removeMapListeners();

        if (this.map)
        {
            map.removeEventListener(TimeExtentEvent.TIME_EXTENT_CHANGE, timeExtentChangeHandler);
        }
    }

    /**
     * @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (_urlChanged)
        {
            _urlChanged = false;

            removeAllChildren();
            loadHeatMapServiceInfo();
        }

        if (_themeChanged)
        {
            _themeChanged = false;
            redrawHeatMapLayer();
        }
    }

    /**
     * @private
     */
    override protected function removeAllChildren():void
    {
        super.removeAllChildren();

        this.graphics.clear();
    }

    /**
     * @private
     */
    override protected function updateLayer():void
    {
        //get new data
        getHeatMapLayerData(map.extent);
    }

    //--------------------------------------------------------------------------
    //
    // private internal heatmap functions called by main layer functions
    //
    //--------------------------------------------------------------------------

    /**
    * @private
    */
    protected function timeExtentChangeHandler(event:TimeExtentEvent):void
    {
        this.timeExtent = event.timeExtent;
    }

    private function loadHeatMapServiceInfo():void
    {
        parseURL();
        var _detailsTask:DetailsTask = new DetailsTask(_urlService);
        var layerID:Number = Number(_urlLayerID);
        _detailsTask.getDetails(layerID, new AsyncResponder(getDetailsCompleteHandler, getDetailsFaultHandler, url));

        function getDetailsCompleteHandler(result:Object, token:Object = null):void
        {
            if (token == url) // make sure result is for the current url
            {
                _layerDetails = result as LayerDetails;
                if (_layerDetails)
                {
                    //Will cause parent class (Layer) to dispatch LayerEvent.LOAD
                    setLoaded(true);
                    //will cause updateLayer to be called
                    invalidateLayer();
                }
            }
        }

        function getDetailsFaultHandler(error:Object, token:Object = null):void
        {
            dispatchEvent(new LayerEvent(LayerEvent.LOAD_ERROR, this, error as Fault));
            setLoaded(false);
        }
    }

    private function getHeatMapLayerData(extent:Extent):void
    {
        _heatMapQueryTask = new QueryTask(this.url);
        _heatMapQueryTask.proxyURL = _proxyURL;
        _heatMapQueryTask.token = _token;
        _heatMapQueryTask.useAMF = _useAMF;
        _heatMapQuery.where = _where;
        _heatMapQuery.geometry = extent;
        _heatMapQuery.timeExtent = _timeExtent;
        _heatMapQuery.returnGeometry = true;
        _heatMapQuery.outSpatialReference = map.spatialReference;

        if (_outFields)
        {
            _heatMapQuery.outFields = _outFields;
        }
        else
        {
            _heatMapQuery.outFields = [ '*' ];
        }

        _heatMapQueryTask.execute(_heatMapQuery, new AsyncResponder(heatMapQueryCompleteHandler, heatMapQueryFaultHandler, url));
        var thisLayer:ArcGISHeatMapLayer = this;
        function heatMapQueryCompleteHandler(result:Object, token:Object):void
        {
            if (token == url) // make sure result is for the current url
            {
                var _featureSet:FeatureSet = result as FeatureSet;
                _featureCount = _featureSet.features.length;
                _dataProvider = new ArrayList(_featureSet.features);
                redrawHeatMapLayer();
                dispatchEvent(new LayerEvent(LayerEvent.UPDATE_END, thisLayer, null, true));
            }
        }

        function heatMapQueryFaultHandler(error:Object, token:Object = null):void
        {
            dispatchEvent(new LayerEvent(LayerEvent.UPDATE_END, thisLayer, error as Fault, false));
        }
    }

    private function redrawHeatMapLayer():void
    {
        const mapW:Number = map.width;
        const mapH:Number = map.height;
        const extW:Number = map.extent.width;
        const extH:Number = map.extent.height;
        const facX:Number = mapW / extW;
        const facY:Number = mapH / extH;

        if (!_dataProvider)
        {
            return;
        }
        const len:int = _dataProvider.length;

        var i:int, feature:Graphic, mapPoint:MapPoint, cluster:Cluster, radius:Number;

        if (_bitmapData && (_bitmapData.width !== map.width || _bitmapData.height !== map.height))
        {
            _bitmapData.dispose();
            _bitmapData = null;
        }
        if (_bitmapData === null)
        {
            _bitmapData = new BitmapData(map.width, map.height, true, 0x00000000);
        }

        _bitmapData.lock();

        _bitmapData.fillRect(_bitmapData.rect, 0x00000000);

        if (map.wrapAround180)
        {
            switch (map.spatialReference.wkid)
            {
                case 102113:
                case 102100:
                case 3857:
                {
                    _world = 2.0 * 20037508.342788905;
                    break;
                }
                case 4326:
                {
                    _world = 2.0 * 180.0;
                    break;
                }
                default:
                {
                    _world = 0.0;
                }
            }
            _wrapAround = doWrapAround;
        }
        else
        {
            _world = 0.0;
            _wrapAround = noWrapAround;
        }

        if (_clusterSize)
        {
            if (_center === null)
            {
                _center = map.extent.center;
            }
            var maxWeight:Number = Number.NEGATIVE_INFINITY;
            const cellW:Number = _clusterSize * extW / mapW;
            const cellH:Number = _clusterSize * extH / mapH;
            const clusterDict:Dictionary = new Dictionary();
            for (i = 0; i < len; i++)
            {
                feature = _dataProvider.getItemAt(i) as Graphic;
                mapPoint = feature.geometry as MapPoint;
                if (map.extent.containsXY(mapPoint.x, mapPoint.y))
                {
                    const gx:int = Math.floor((mapPoint.x - _center.x) / cellW);
                    const gy:int = Math.floor((mapPoint.y - _center.y) / cellH);
                    const gk:String = gx + ":" + gy;
                    cluster = clusterDict[gk];
                    if (cluster === null)
                    {
                        const cx:Number = gx * cellW + _center.x;
                        const cy:Number = gy * cellH + _center.y;
                        clusterDict[gk] = cluster = new Cluster(new MapPoint(cx, cy), _clusterWeightCalculator(feature), [ feature ]);
                    }
                    else
                    {
                        cluster.graphics.push(feature);
                        cluster.weight += _clusterWeightCalculator(feature);
                    }
                    maxWeight = Math.max(maxWeight, cluster.weight);
                }
            }
            var count:int = 0;
            for each (cluster in clusterDict)
            {
                COLORS[0] = Math.max(0, Math.min(255, _clusterIndexCalculator(cluster, maxWeight)));
                radius = _clusterRadiusCalculator(cluster, _densityRadius, maxWeight);
                _wrapAround(cluster.center, radius, facX, facY, mapH);
                count++;
            }

            _clusterCount = count;
            dispatchEvent(new Event("clusterCountChanged"));

            _clusterMaxWeight = maxWeight;
            dispatchEvent(new Event("clusterMaxWeightChanged"));
        }
        else
        {
            for (i = 0; i < len; i++)
            {
                feature = _dataProvider.getItemAt(i) as Graphic;
                mapPoint = feature.geometry as MapPoint;
                COLORS[0] = Math.max(0, Math.min(255, _featureIndexCalculator(feature)));
                radius = _featureRadiusCalculator(feature, _densityRadius);
                _wrapAround(mapPoint, radius, facX, facY, mapH);
            }
        }
        // paletteMap leaves some artifacts unless we get rid of the blackest colors
        _bitmapData.threshold(_bitmapData, _bitmapData.rect, POINT, "<", 0x00000001, 0x00000000, 0x000000FF, true);
        // Replace the black and blue with the gradient. Blacker pixels will get their new colors from
        // the beginning of the gradientArray and bluer pixels will get their new colors from the end. 
        //comment out the line below if you would like to see the heatmap without the palette applied, will be only blue and black
        _bitmapData.paletteMap(_bitmapData, _bitmapData.rect, POINT, null, null, _gradientArray, null);
        // This blur filter makes the heat map looks quite smooth.
        _bitmapData.applyFilter(_bitmapData, _bitmapData.rect, POINT, BLURFILTER);

        _bitmapData.unlock();

        _matrix2.tx = parent.scrollRect.x;
        _matrix2.ty = parent.scrollRect.y;

        graphics.clear();
        graphics.beginBitmapFill(_bitmapData, _matrix2, false, false);
        graphics.drawRect(parent.scrollRect.x, parent.scrollRect.y, map.width, map.height);
        graphics.endFill();
    }

    private function noWrapAround(mapPoint:MapPoint, radius:Number, facX:Number, facY:Number, mapH:Number):void
    {
        if (map.extent.containsXY(mapPoint.x, mapPoint.y))
        {
            drawXY(mapPoint.x, mapPoint.y, radius, facX, facY, mapH);
        }
    }

    private function doWrapAround(mapPoint:MapPoint, radius:Number, facX:Number, facY:Number, mapH:Number):void
    {
        var x:Number = mapPoint.x;
        while (x > map.extent.xmin)
        {
            drawXY(x, mapPoint.y, radius, facX, facY, mapH);
            x -= _world;
        }
        x = mapPoint.x + _world;
        while (x < map.extent.xmax)
        {
            drawXY(x, mapPoint.y, radius, facX, facY, mapH);
            x += _world;
        }
    }

    private function drawXY(x:Number, y:Number, radius:Number, facX:Number, facY:Number, mapH:Number):void
    {
        const diameter:int = radius + radius;

        _matrix1.createGradientBox(diameter, diameter, 0, -radius, -radius);

        _shape.graphics.clear();
        _shape.graphics.beginGradientFill(GradientType.RADIAL, COLORS, ALPHAS, RATIOS, _matrix1);
        _shape.graphics.drawCircle(0, 0, radius);
        _shape.graphics.endFill();

        _matrix2.tx = Math.floor((x - map.extent.xmin) * facX);
        _matrix2.ty = Math.floor(mapH - (y - map.extent.ymin) * facY);
        _bitmapData.draw(_shape, _matrix2, null, BlendMode.SCREEN, null, true);
    }


    /**
     * Split the main service url into its MapServer or FeatureServer part
     * and then the layer id in the map service or feature service.
     */
    private function parseURL():void
    {
        var parseString:String = this.url;
        var lastPos:int = parseString.lastIndexOf("/");
        _urlService = parseString.substr(0, lastPos);
        _urlLayerID = parseString.substr(lastPos + 1);
    }

    private function internalWeightCalculator(feature:Graphic):Number
    {
        return 1.0;
    }

    private function internalFeatureCalculator(feature:Graphic):int
    {
        return 255;
    }

    private function internalClusterCalculator(cluster:Cluster, weightMax:Number):int
    {
        return 255 * cluster.weight / weightMax;
    }

    private function internalFeatureRadiusCalculator(feature:Graphic, radius:Number):Number
    {
        return radius;
    }

    private function internalClusterRadiusCalculator(cluster:Cluster, radius:Number, weightMax:Number):Number
    {
        return radius;
    }

    //--------------------------------------------------------------------------
    //
    // Getters and setters
    //
    //--------------------------------------------------------------------------

    //--------------------------------------
    //  url
    //--------------------------------------

    [Bindable(event="urlChanged")]
    /**
     * URL of the point layer in feature or map service that will be used to generate the heatmap.
     *
     * @since ArcGISHeatMapLayer 1.0
     */
    public function get url():String
    {
        return _url;
    }

    /**
     * @private
     */
    public function set url(value:String):void
    {
        if (_url != value)
        {
            _url = value;
            _urlChanged = true;
            invalidateProperties();
            _layerDetails = null;
            setLoaded(false);
            dispatchEvent(new Event("urlChanged"));
        }
    }

    //--------------------------------------
    //  proxyURL
    //--------------------------------------

    /**
     * The URL to proxy the request through.
     *
     * @since ArcGISHeatMapLayer 3.0
     */
    public function get proxyURL():String
    {
        return _proxyURL;
    }

    /**
     * @private
     */
    public function set proxyURL(value:String):void
    {
        _proxyURL = value;
    }

    //--------------------------------------
    //  token
    //--------------------------------------

    [Bindable(event="tokenChanged")]
    /**
     * Token for accessing a secure ArcGIS service.
     *
     * @since ArcGISHeatMapLayer 1.0
     */
    public function get token():String
    {
        return _token;
    }

    /**
     * @private
     */
    public function set token(value:String):void
    {
        if (_token !== value)
        {
            _token = value;
            dispatchEvent(new Event("tokenChanged"));
        }
    }

    //--------------------------------------
    //  useAMF
    //--------------------------------------

    [Bindable(event="useAMFChanged")]
    /**
     * Use AMF for executing the query. This is the preferred method, but the server must support it.
     * Requires the server to be ArcGIS Server 10.0 or above, set to false if using earlier server versions.
     * When useAMF is true, the BaseTask properties concurrency, requestTimeout and showBusyCursor are ignored.
     *
     * @default true
     *
     * @since ArcGISHeatMapLayer 1.0
     */
    public function get useAMF():Boolean
    {
        return _useAMF;
    }

    /**
     * @private
     */
    public function set useAMF(value:Boolean):void
    {
        if (_useAMF !== value)
        {
            _useAMF = value;
            dispatchEvent(new Event("useAMFChanged"));
        }
    }

    //--------------------------------------
    //  where
    //--------------------------------------

    [Bindable(event="whereChanged")]
    /**
     * A where clause for the query, refer to the Query class in the ArcGIS API for Flex documentation.
     *
     * @default 1=1
     *
     * @since ArcGISHeatMapLayer 1.0
     */
    public function get where():String
    {
        return _where;
    }

    /**
     * @private
     */
    public function set where(value:String):void
    {
        if (_where !== value)
        {
            _where = value;
            invalidateLayer();
            dispatchEvent(new Event("whereChanged"));
        }
    }

    //--------------------------------------
    //  outFields
    //--------------------------------------

    [Bindable(event="outFieldsChanged")]
    /**
     * Attribute fields to include in the FeatureSet returned in the HeatMapEvent.
     *
     * @since ArcGISHeatMapLayer 1.0
     */
    public function get outFields():Array
    {
        return _outFields;
    }

    /**
     * @private
     */
    public function set outFields(value:Array):void
    {
        if (_outFields !== value)
        {
            _outFields = value;
            dispatchEvent(new Event("outFieldsChanged"));
        }
    }

    //--------------------------------------
    //  timeExtent
    //--------------------------------------

    [Bindable(event="timeExtentChanged")]
    /**
     * The time instant or the time extent to query, this is usually set internally
     * through a time extent change event when the map time changes and not set directly.
     *
     * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/TimeExtent.html&com/esri/ags/class-list.html com.esri.ags.TimeExtent
     *
     * @since ArcGISHeatMapLayer 2.0
     */
    public function get timeExtent():TimeExtent
    {
        return _timeExtent;
    }

    /**
     * @private
     */
    public function set timeExtent(value:TimeExtent):void
    {
        if (_timeExtent !== value)
        {
            _timeExtent = value;
            invalidateLayer();
            dispatchEvent(new Event("timeExtentChanged"));
        }
    }

    //--------------------------------------
    //  theme
    //--------------------------------------

    [Bindable(event="heatMapThemeChanged")]
    /**
     * The "named" color scheme used to generate the client-side heatmap layer.
     * @default RAINBOW
     * @see com.esri.ags.samples.layers.supportClasses.HeatMapGradientDict#RAINBOW_TYPE
     *
     * @since ArcGISHeatMapLayer 1.0
     */
    public function get theme():String
    {
        return _heatMapTheme;
    }

    /**
     * @private
     */
    public function set theme(value:String):void
    {
        if (_heatMapTheme !== value)
        {
            _heatMapTheme = value;
            _gradientArray = HeatMapGradientDict.gradientArray(_heatMapTheme);
            _themeChanged = true;
            invalidateProperties();
            dispatchEvent(new Event("heatMapThemeChanged"));
        }
    }

    //--------------------------------------
    //  layer details
    //--------------------------------------

    /**
     * The detailed information from the ArcGIS web service layer used to generate the heatmap.
     *
     * @return The <code>LayerDetails</code> of the point layer being queried in the map or feature service.
     *
     * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/events/LayerEvent.html#LOAD&com/esri/ags/events/class-list.html com.esri.ags.events.LayerEvent.LOAD
     * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/layers/supportClasses/LayerDetails.html&com/esri/ags/layers/supportClasses/class-list.html com.esri.ags.layers.supportClasses.LayerDetails
     *
     * @since ArcGISHeatMapLayer 3.0
     */
    public function get layerDetails():LayerDetails
    {
        return _layerDetails;
    }

    //--------------------------------------
    //  cluster max weight
    //--------------------------------------

    [Bindable("clusterMaxWeightChanged")]
    /**
     * The maximum weight of the cluster.
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function get clusterMaxWeight():Number
    {
        return _clusterMaxWeight;
    }

    //--------------------------------------
    //  cluster count
    //--------------------------------------

    [Bindable("clusterCountChanged")]
    /**
     * The cluster count.
     *
     * @default 0
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function get clusterCount():int
    {
        return _clusterCount;
    }

    //--------------------------------------
    //  cluster size
    //--------------------------------------

    [Bindable]
    /**
     * The cluster size.
     *
     * @default 0
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function get clusterSize():int
    {
        return _clusterSize;
    }

    /**
     * @private
     */
    public function set clusterSize(value:int):void
    {
        if (_clusterSize !== value)
        {
            _clusterSize = value;
            invalidateLayer();
        }
    }

    //--------------------------------------
    //  density radius
    //--------------------------------------

    [Bindable]
    /**
     * The density radius.  This controls the size of the heat
     * radius for a given point.
     *
     * @default 25
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function get densityRadius():int
    {
        return _densityRadius;
    }

    /**
     * @private
     */
    public function set densityRadius(value:int):void
    {
        if (_densityRadius !== value)
        {
            _densityRadius = value;
            invalidateLayer();
        }
    }

    //--------------------------------------
    //  feature radius calculator function
    //--------------------------------------

    [Bindable(event="featureRadiusCalculatorChanged")]
    /**
     * The function to use to calculate the density radius.
     * If not set the heatmap layer will default to the internal function.
     *
     * @default internalFeatureRadiusCalculator
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function set featureRadiusCalculator(value:Function):void
    {
        _featureRadiusCalculator = value === null ? internalFeatureRadiusCalculator : value;
        invalidateLayer();
    }

    //--------------------------------------
    //  feature index calculator function
    //--------------------------------------

    [Bindable(event="featureIndexCalculatorChanged")]
    /**
     * The function to use to calculate the index used to retrieve colors from
     * the gradient dictionary.
     * If not set the heatmap layer will default to the internal function.
     *
     * @default internalFeatureCalculator
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function set featureIndexCalculator(value:Function):void
    {
        _featureIndexCalculator = value === null ? internalFeatureCalculator : value;
        invalidateLayer();
    }

    //--------------------------------------
    //  cluster radius calculator function
    //--------------------------------------

    [Bindable(event="clusterRadiusCalculatorChanged")]
    /**
     * The function to use to calculate the cluster radius.
     * If not set the heatmap layer will default to the internal function.
     *
     * @default internalClusterRadiusCalculator
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function set clusterRadiusCalculator(value:Function):void
    {
        _clusterRadiusCalculator = value === null ? internalClusterRadiusCalculator : value;
        invalidateLayer();
    }

    //--------------------------------------
    //  cluster index calculator function
    //--------------------------------------

    [Bindable(event="clusterIndexCalculatorChanged")]
    /**
     * The function to use to calculate the cluster index.
     * If not set the heatmap layer will default to the internal function.
     *
     * @default internalClusterCalculator
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function set clusterIndexCalculator(value:Function):void
    {
        _clusterIndexCalculator = value === null ? internalClusterCalculator : value;
        invalidateLayer();
    }

    //--------------------------------------
    //  cluster weight calculator function
    //--------------------------------------

    [Bindable(event="clusterWeightCalculatorChanged")]
    /**
     * The function to use to calculate the cluster weight.
     * If not set the heatmap layer will default to the internal function.
     *
     * @default internalWeightCalculator
     *
     * @since ArcGISHeatMapLayer 3.1
     */
    public function set clusterWeightCalculator(value:Function):void
    {
        _clusterWeightCalculator = value === null ? internalWeightCalculator : value;
        invalidateLayer();
    }

    //--------------------------------------
    //  feature count
    //--------------------------------------

    [Bindable(event="featureCountChange")]
    /**
     * The number of point features used to create the heatmap layer.
     *
     * @see https://developers.arcgis.com/en/flex/api-reference/index.html?com/esri/ags/events/LayerEvent.html#UPDATE_END&com/esri/ags/events/class-list.html com.esri.ags.events.LayerEvent.UPDATE_END
     *
     * @since ArcGISHeatMapLayer 3.4
     */
    public function get featureCount():int
    {
        return _featureCount;
    }

    //--------------------------------------
    //  feature set
    //--------------------------------------

    [Bindable(event="featureSetChange")]
    /**
     * The current set of features being used to generate the heatmap.
     *
     * @since ArcGISHeatMapLayer 3.4
     */
    public function get featureSet():FeatureSet
    {
        return _featureSet;
    }

} //end class
} //end package
