//
//  MapVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/1/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

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
    var locationField: String      = ""
    var timeField: String          = ""
    var faceUrlField: String            = ""

    var mapType: MapVisStateService.MapType        = .unknown
    
    var mapLayers:  [MapLayer]      =   []

    //MARK:
    private var mapUrl_l: String      =       ""

    //MARK:
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let mapVisService = responseModel as? MapVisStateService else { return }
        self.mapUrl_l   =   mapVisService.mapUrl
        self.version    =   mapVisService.version
        self.transparent    =   mapVisService.transparent
        self.styles     =   mapVisService.styles
        self.format     =   mapVisService.format
        self.defaultLayerName   =   mapVisService.defaultLayerName
        self.userField  =   mapVisService.userField
        self.locationField  =  mapVisService.locationField
        self.timeField  =   mapVisService.timeField
        self.faceUrlField    =   mapVisService.faceUrl
        self.mapType    =   mapVisService.mapType
        self.mapLayers  =   mapVisService.mapLayers.compactMap({ MapLayer($0) })
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
}

class MapLayer {
    
    var layerName: String       =   ""
    var buttonTitle: String     =   ""

    //MARK: Functions
    init(_ responseModel: MapLayerService) {
        self.layerName      =   responseModel.layerName
        self.buttonTitle    =   responseModel.buttonTitle
    }
}
