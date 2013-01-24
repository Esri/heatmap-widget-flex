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
package com.esri.ags.samples.utils
{

import mx.collections.ArrayCollection;

/**
 *
 *
 */
public class UIComponentUtil
{
    public static const COMBOBOX_LABEL:String = "--Select a type--";
    public static const COMBOBOX_NO_DATA:String = "-1";

    public static const DELIMITER_COMMA:String = ",";
    public static const DELIMITER_PIPE:String = "|";

    private static var _delimiter:String = DELIMITER_COMMA;


    public function UIComponentUtil()
    {
    }

    /**
     *
     * @param value The delimiter to use. A comma, pipe, or custom delimiter. The default is comma.
     *
     */
    public static function set delimiter(value:String):void
    {
        if (value == "|")
        {
            _delimiter = DELIMITER_PIPE;
        }
        else if (value == ",")
        {
            _delimiter = DELIMITER_COMMA;
        }
        else
        {
            _delimiter = value;
        }

    }

    /**
     * Utility function to an array collection of objects {data:-1, label:"Select a type"} that can be used as the dataProvider for a ComboBox.
     * @param parseLabels The string of labels to use "label1,label2,label3".
     * @param parseData The string of data to use "data1,data2,data3".
     * @param promptString The first label in the combobox that the user will see.  If you don't set the prompt string the first object will be {data:-1, "--Select a type--"}
     * @return An ArrayCollection that can be used as the dataProvider of a ComboBox
     *
     */
    public static function getComboBoxDataProvider(parseLabels:String, parseData:String, promptString:String = null):ArrayCollection
    {
        var configXML_LabelString:String;
        var configXML_LabelStringArr:Array = [];

        var configXML_DataString:String;
        var configXML_DataStringArr:Array = [];

        var configXMLStringAC:ArrayCollection = null;

        if (promptString == null)
        {
            promptString = COMBOBOX_LABEL;
        }
        configXMLStringAC = new ArrayCollection([{ label: promptString, data: COMBOBOX_NO_DATA }]);

        configXML_LabelString = parseLabels;
        configXML_LabelStringArr = configXML_LabelString.split(_delimiter);

        configXML_DataString = parseData;
        configXML_DataStringArr = configXML_DataString.split(_delimiter);


        for (var i:int = 0; i < configXML_LabelStringArr.length; i++)
        {
            configXMLStringAC.addItem({ label: configXML_LabelStringArr[i], data: configXML_DataStringArr[i]});
        }

        return configXMLStringAC;

    }
}
}
