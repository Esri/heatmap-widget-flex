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
package com.esri.ags.samples.events
{

import com.esri.ags.FeatureSet;

import flash.events.Event;

/**
 * Represents event objects that are specific to the ArcGISHeatMapLayer.
 *
 * @see com.esri.ags.samples.layers.ArcGISHeatMapLayer
 */
public class HeatMapEvent extends Event
{
    /**
     * The number of features used in generating the heatmap layer.
     */
    public var count:Number;
    /**
     * The featureset returned by the query issued by the ArcGISHeatMapLayer.
     */
    public var featureSet:FeatureSet;

    /**
     * Defines the value of the <code>type</code> property of an refreshStart event object.
     *
     * @eventType refreshStart
     */
    public static const REFRESH_START:String = "refreshStart";
    /**
     * Defines the value of the <code>type</code> property of an refreshEnd event object.
     *
     * @eventType refreshEnd
     */
    public static const REFRESH_END:String = "refreshEnd";

    /**
     * Creates a new HeatMapEvent.
     *
     * @param type The event type; indicates the action that triggered the event.
     */
    public function HeatMapEvent(type:String, count:Number = NaN, featureSet:FeatureSet = null)
    {
        super(type);
        this.count = count;
        this.featureSet = featureSet;
    }

    /**
     * @private
     */
    override public function clone():Event
    {
        return new HeatMapEvent(type, count, featureSet);
    }

    /**
     * @private
     */
    override public function toString():String
    {
        return formatToString("HeatMapEvent", "type", "count", "featureSet");
    }

}
}
