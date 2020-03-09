//
//  MapVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/1/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class MapVisState: VisState {

    var mapUrl: String {
        return mapUrl_l.isEmpty ? Configuration.shared.mapBaseUrl : mapUrl_l
    }
    
    var version: String         = ""

    var transparent: Bool       = true
    
    var styles: String          = ""

    var format: String          = ""

    var defaultLayerName: String          = ""

    /// This field is used in MapTracking Panel (Filtering key)
    var userField: String          = ""

    var mapType: MapType        = .unknown
    
    var mapLayers:  [MapLayer]      =   []

    //MARK:
    private var mapUrl_l: String      =       ""

    //MARK:
    override func mapping(map: Map) {
        super.mapping(map: map)
        mapUrl_l          <- map["params.wms.url"]
        version         <- map["params.wms.options.version"]
        transparent     <- map["params.wms.options.transparent"]
        styles          <- map["params.wms.options.styles"]
        format          <- map["params.wms.options.format"]
        defaultLayerName    <- map["params.wms.options.layers"]
        userField       <- map["params.user_field"]
        mapType         <- (map["params.mapType"],EnumTransform<MapType>())
        
        if let params = map.JSON["params"] as? [String: Any], let layersList = params["quickButtons"] as? [[String: Any]] {
            mapLayers = Mapper<MapLayer>().mapArray(JSONArray: layersList)
        }
    }

}

extension MapVisState {
    
    struct HeatMapServiceConstant {
        static let queryString = "?request=GetCapabilities&Service=WMS"
        static let version = "1.3.0"
        static let epsg =  "3857" //"4326"
        static let format = "image/png"
        static let tileSize = "256"
        static let transparent = true
    }
    
    enum MapType: String {
        case unknown                =   "Unknown"
        case heatMap                =   "Heatmap"
        case scaledCircleMarkers    =   "Scaled Circle Markers"
        case shadedCircleMarkers    =   "Shaded Circle Markers"
        case shadedGeohashGrid      =   "Shaded Geohash Grid"
    }
}

class MapLayer: Mappable {
    
    var layerName: String       =   ""
    var buttonTitle: String     =   ""

    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        buttonTitle         <-  map["label"]
        layerName           <-  map["layers"]
    }
}
