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

import com.esri.ags.TimeExtent;
import com.esri.ags.events.DetailsEvent;
import com.esri.ags.events.ExtentEvent;
import com.esri.ags.events.LayerEvent;
import com.esri.ags.events.QueryEvent;
import com.esri.ags.events.TimeExtentEvent;
import com.esri.ags.geometry.Extent;
import com.esri.ags.layers.Layer;
import com.esri.ags.layers.supportClasses.LayerDetails;
import com.esri.ags.samples.events.HeatMapEvent;
import com.esri.ags.samples.geometry.HeatMapPoint;
import com.esri.ags.samples.layers.supportClasses.HeatMapGradientDict;
import com.esri.ags.tasks.DetailsTask;
import com.esri.ags.tasks.QueryTask;
import com.esri.ags.tasks.supportClasses.Query;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.events.FlexEvent;
import mx.rpc.events.FaultEvent;

//--------------------------------------
//  Events
//--------------------------------------

/**
 * Dispatched when the ArcGISHeatMapLayer ends the getDetails process.
 *
 * @eventType DetailsEvent.GET_DETAILS_COMPLETE
 */
[Event(name="getDetailsComplete", type="com.esri.ags.events.DetailsEvent")]
/**
 * Dispatched when the ArcGISHeatMapLayer starts the refresh process.
 *
 * @eventType HeatMapEvent.REFRESH_START
 */
[Event(name="refreshStart", type="com.esri.ags.samples.events.HeatMapEvent")]
/**
 * Dispatched when the ArcGISHeatMapLayer ends the refresh process.
 *
 * @eventType HeatMapEvent.REFRESH_END
 */
[Event(name="refreshEnd", type="com.esri.ags.samples.events.HeatMapEvent")]



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
 *                                    outFields="[*]"
 *                                    url="http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Earthquakes/Since_1970/MapServer/0"/&gt;
 * &lt;/esri:Map&gt;</listing>
 *
 * @see http://resources.arcgis.com/en/help/flex-api/apiref/com/esri/ags/events/DetailsEvent.html com.esri.ags.events.DetailsEvent
 * @see http://resources.arcgis.com/en/help/flex-api/apiref/com/esri/ags/events/ExtentEvent.html com.esri.ags.events.ExtentEvent
 * @see http://resources.arcgis.com/en/help/flex-api/apiref/com/esri/ags/events/LayerEvent.html  com.esri.ags.events.LayerEvent
 * @see http://resources.arcgis.com/en/help/flex-api/apiref/com/esri/ags/events/QueryEvent.html com.esri.ags.events.QueryEvent
 * @see http://resources.arcgis.com/en/help/flex-api/apiref/com/esri/ags/events/TimeExtentEvent.html com.esri.ags.events.TimeExtentEvent
 * @see com.esri.ags.samples.events.HeatMapEvent
 * @see http://resources.arcgis.com/en/help/flex-api/apiref/com/esri/ags/layers/Layer.html com.esri.ags.layers.Layer
 *
 * @inheritDoc
 */
public class ArcGISHeatMapLayer extends Layer
{
    private var _url:String;
    private var _where:String = "1=1";
    private var _useAMF:Boolean = false;
    private var _proxyURL:String;
    private var _token:String;
    private var _outFields:Array;
    private var _timeExtent:TimeExtent;
    private var _urlPartsArray:Array;
    private var _detailsTask:DetailsTask;
    private var _layerDetails:LayerDetails;

    private var _heatMapQueryTask:QueryTask;
    private var _heatMapQuery:Query = new Query();

    private static const POINT:Point = new Point();
    private var _dataProvider:Vector.<HeatMapPoint>;
    private var _gradientDict:Array;
    private var _heatMapTheme:String = HeatMapGradientDict.RAINBOW_TYPE;
    private var _heatRadius:Number = 25;
    private var _bitmapDataLayer:BitmapData;
    private const _blurFilter:BlurFilter = new BlurFilter(4, 4);
    private var _centerValue:Number;
    private const _shape:Shape = new Shape();
    private const _x:Array = [];
    private const _y:Array = [];

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
        mouseEnabled = false;
        mouseChildren = false;
        super();
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true);
        addEventListener(LayerEvent.UPDATE_START, updateStartCompleteHandler, false, 0, true);
        addEventListener(Event.REMOVED, removeCompleteHandler, false, 0, true);
        _url = url;
        _proxyURL = proxyURL;
        _token = token;
        _gradientDict = HeatMapGradientDict.gradientArray(_heatMapTheme);
    }

    /**
     * @private
     */
    protected function getDetailsCompleteHandler(event:DetailsEvent):void
    {
        _detailsTask.removeEventListener(DetailsEvent.GET_DETAILS_COMPLETE, getDetailsCompleteHandler);
        if (event)
        {
            _layerDetails = event.layerDetails;
        }
        invalidateHeatMap();
        dispatchEvent(event);
    }

    /**
     * @private
     */
    protected function getDetailsFaultHandler(event:FaultEvent):void
    {
        _detailsTask.removeEventListener(FaultEvent.FAULT, getDetailsFaultHandler);
        dispatchEvent(new LayerEvent(LayerEvent.LOAD_ERROR, this, event.fault));
    }

    /**
     * @private
     */
    protected function updateStartCompleteHandler(event:LayerEvent):void
    {
        removeEventListener(LayerEvent.UPDATE_START, updateStartCompleteHandler);
        if (map)
        {
            map.addEventListener(ExtentEvent.EXTENT_CHANGE, heatMapExtentChangeHandler);
            map.addEventListener(TimeExtentEvent.TIME_EXTENT_CHANGE, timeExtentChangeHandler);
        }
        _heatMapQueryTask = new QueryTask(_url);
        _heatMapQueryTask.addEventListener(QueryEvent.EXECUTE_COMPLETE, heatMapQueryCompleteHandler, false, 0, true);
        _heatMapQueryTask.addEventListener(FaultEvent.FAULT, heatMapQueryFaultHandler, false, 0, true);
        parseURL(_url);
        if (_urlPartsArray.length == 2)
        {
            _detailsTask = new DetailsTask(_urlPartsArray[0]);
            var layerID:Number = Number(_urlPartsArray[1]);
            _detailsTask.addEventListener(DetailsEvent.GET_DETAILS_COMPLETE, getDetailsCompleteHandler, false, 0, true);
            _detailsTask.addEventListener(FaultEvent.FAULT, getDetailsFaultHandler, false, 0, true);
            _detailsTask.getDetails(layerID);
        }
    }

    /**
     * @private
     */
    protected function removeCompleteHandler(event:Event):void
    {
        if (this.map)
        {
            map.removeEventListener(ExtentEvent.EXTENT_CHANGE, heatMapExtentChangeHandler);
            map.removeEventListener(TimeExtentEvent.TIME_EXTENT_CHANGE, timeExtentChangeHandler);
        }
        removeEventListener(Event.REMOVED, removeCompleteHandler);
        _heatMapQueryTask.removeEventListener(QueryEvent.EXECUTE_COMPLETE, heatMapQueryCompleteHandler);
        _heatMapQueryTask.removeEventListener(FaultEvent.FAULT, heatMapQueryFaultHandler);
    }

    /**
     * @private
     */
    protected function creationCompleteHandler(event:FlexEvent):void
    {
        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        setLoaded(true);
    }

    /**
     * @private
     */
    protected function invalidateHeatMap():void
    {
        if (map && map.extent)
        {
            generateHeatMap(map.extent);
        }
    }

    /**
     * @private
     */
    protected function generateHeatMap(extent:Extent):void
    {
        if (_proxyURL)
        {
            _heatMapQueryTask.proxyURL = _proxyURL;
        }
        if (_token)
        {
            _heatMapQueryTask.token = _token;
        }
        _heatMapQueryTask.useAMF = _useAMF;
        if (_where)
        {
            _heatMapQuery.where = _where;
        }
        _heatMapQuery.geometry = extent;
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

        if (_timeExtent)
        {
            _heatMapQuery.timeExtent = _timeExtent;
        }

        dispatchEvent(new HeatMapEvent(HeatMapEvent.REFRESH_START));
        if (visible)
        {
            _heatMapQueryTask.execute(_heatMapQuery);
        }
    }

    /**
     * @private
     */
    protected function timeExtentChangeHandler(event:TimeExtentEvent):void
    {
        _timeExtent = event.timeExtent;
        invalidateHeatMap();
    }

    /**
     * @private
     */
    protected function heatMapExtentChangeHandler(event:ExtentEvent):void
    {
        // Perform the query, when queryComplete occurs call invalidateLayer()
        generateHeatMap(event.extent);
    }

    /**
     * @private
     */
    protected function heatMapQueryFaultHandler(event:FaultEvent):void
    {
        dispatchEvent(new LayerEvent(LayerEvent.LOAD_ERROR, this, event.fault));
    }

    /**
     * @private
     */
    protected function heatMapQueryCompleteHandler(event:QueryEvent):void
    {
        if (event)
        {
            dispatchEvent(new HeatMapEvent(HeatMapEvent.REFRESH_END, event.featureSet.features.length, event.featureSet));

            var featureArr:Array = event.featureSet.features;
            _dataProvider = new Vector.<HeatMapPoint>();

            for (var i:int = 0; i < featureArr.length; i++)
            {
                if (featureArr[i].geometry)
                {
                    _dataProvider.push(new HeatMapPoint(featureArr[i].geometry.x, featureArr[i].geometry.y));
                }
            }
            setLoaded(true);
            invalidateLayer();
        }
    }

    /**
     * @private
     */
    private function updatePoints():void
    {
        _x.length = 0;
        _y.length = 0;

        var max:Number = 5.0;

        const mapW:Number = map.width;
        const mapH:Number = map.height;
        const extW:Number = map.extent.width;
        const extH:Number = map.extent.height;
        const facX:Number = mapW / extW;
        const facY:Number = mapH / extH;

        const dict:Dictionary = new Dictionary(true);
        for each (var heatMapPoint:HeatMapPoint in _dataProvider)
        {
            if (map.extent.containsXY(heatMapPoint.x, heatMapPoint.y))
            {
                const sx:Number = (heatMapPoint.x - map.extent.xmin) * facX;
                const sy:Number = mapH - (heatMapPoint.y - map.extent.ymin) * facY;

                _x.push(sx);
                _y.push(sy);

                const key:String = Math.round(sx) + "_" + Math.round(sy);
                var val:Number = dict[key] as Number;
                if (isNaN(val))
                {
                    val = heatMapPoint.weight;
                }
                else
                {
                    val += heatMapPoint.weight;
                }
                dict[key] = val;
                max = Math.max(max, val);
            }
        }
        _centerValue = Math.max(19.0, 255.0 / max);
    } //end function

    /**
     * @private
     */
    private function parseURL(value:String):void
    {
        _urlPartsArray = [];
        var parseString:String = value;
        var lastPos:int = parseString.lastIndexOf("/");
        _urlPartsArray[0] = parseString.substr(0, lastPos);
        _urlPartsArray[1] = parseString.substr(lastPos + 1);
    }


    //--------------------------------------
    // overridden methods 
    //--------------------------------------
    /**
     * @private
     */
    override protected function updateLayer():void
    {
        updatePoints();

        const heatDiameter:int = _heatRadius * 2;
        const matrix1:Matrix = new Matrix();
        matrix1.createGradientBox(heatDiameter, heatDiameter, 0, -_heatRadius, -_heatRadius);

        _shape.graphics.clear();
        _shape.graphics.beginGradientFill(GradientType.RADIAL, [ _centerValue, 0 ], [ 1, 1 ], [ 0, 255 ], matrix1);
        _shape.graphics.drawCircle(0, 0, _heatRadius);
        _shape.graphics.endFill();
        _shape.cacheAsBitmap = true;

        const bitmapDataShape:BitmapData = new BitmapData(_shape.width, _shape.height, true, 0x00000000);
        const matrix2:Matrix = new Matrix();
        matrix2.tx = _heatRadius;
        matrix2.ty = _heatRadius;
        bitmapDataShape.draw(_shape, matrix2);

        const clip:Rectangle = new Rectangle(0, 0, map.width, map.height);

        if (_bitmapDataLayer && _bitmapDataLayer.width !== map.width && _bitmapDataLayer.height !== map.height)
        {
            _bitmapDataLayer.dispose();
            _bitmapDataLayer = null;
        }
        if (_bitmapDataLayer === null)
        {
            _bitmapDataLayer = new BitmapData(map.width, map.height, true, 0x00000000);
        }
        _bitmapDataLayer.lock();
        _bitmapDataLayer.fillRect(clip, 0x00000000);
        const len:int = _x.length;
        for (var i:int = 0; i < len; i++)
        {
            matrix2.tx = _x[i] - _heatRadius;
            matrix2.ty = _y[i] - _heatRadius;
            _bitmapDataLayer.draw(bitmapDataShape, matrix2, null, BlendMode.SCREEN);
        }
        bitmapDataShape.dispose();

        // paletteMap leaves some artifacts unless we get rid of the blackest colors 
        _bitmapDataLayer.threshold(_bitmapDataLayer, _bitmapDataLayer.rect, POINT, "<=", 0x00000003, 0x00000000, 0x000000FF, true);

        // Replace the black and blue with the gradient. Blacker pixels will get their new colors from
        // the beginning of the gradientArray and bluer pixels will get their new colors from the end. 
        _bitmapDataLayer.paletteMap(_bitmapDataLayer, _bitmapDataLayer.rect, POINT, null, null, _gradientDict, null);

        // This blur filter makes the heat map looks quite smooth.
        _bitmapDataLayer.applyFilter(_bitmapDataLayer, _bitmapDataLayer.rect, POINT, _blurFilter);
        _bitmapDataLayer.unlock();

        const matrix3:Matrix = new Matrix(1.0, 0.0, 0.0, 1.0, parent.scrollRect.x, parent.scrollRect.y);
        graphics.clear();
        graphics.beginBitmapFill(_bitmapDataLayer, matrix3, false, false);
        graphics.drawRect(parent.scrollRect.x, parent.scrollRect.y, map.width, map.height);
        graphics.endFill();

        dispatchEvent(new LayerEvent(LayerEvent.UPDATE_END, this, null, true));
    }

    //--------------------------------------
    // Getters and setters 
    //--------------------------------------

    //--------------------------------------
    //  url
    //--------------------------------------

    [Bindable(event="urlChanged")]
    /**
     * URL of the point layer in feature or map service that will be used to generate the heatmap.
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
        if (_url != value && value)
        {
            _url = value;
            invalidateHeatMap();
            setLoaded(false);
            dispatchEvent(new Event("urlChanged"));
        }
    }

    //--------------------------------------
    //  proxyURL
    //--------------------------------------

    /**
     * The URL to proxy the request through.
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
     * @default 1=1
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
            invalidateHeatMap();
            dispatchEvent(new Event("whereChanged"));
        }
    }

    //--------------------------------------
    //  outFields
    //--------------------------------------

    [Bindable(event="outFieldsChanged")]
    /**
     * Attribute fields to include in the FeatureSet returned in the HeatMapEvent.
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
     * The time instant or the time extent to query, this is usually set internally through a time extent change event when the map time changes and not set directly.
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
            invalidateHeatMap();
            dispatchEvent(new Event("timeExtentChanged"));
        }
    }

    //--------------------------------------
    //  theme
    //--------------------------------------

    [Bindable(event="heatMapThemeChanged")]
    /**
     * The "named" color scheme used to generate the client-side heatmap layer.  See the
     * @default RAINBOW
     * @see com.esri.ags.samples.layers.supportClasses.HeatMapGradientDict
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
            _gradientDict = HeatMapGradientDict.gradientArray(_heatMapTheme);
            refresh();
            dispatchEvent(new Event("heatMapThemeChanged"));
        }
    }

    /**
     * Gets the detailed information for the ArcGIS layer used to generate the heatmap.
     *
     * @return The <code>LayerDetails</code> of the point layer being queried in the map or feature service.
     *
     */
    public function get layerDetails():LayerDetails
    {
        return _layerDetails;
    }



} //end class
}
