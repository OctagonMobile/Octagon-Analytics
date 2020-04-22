//
//  GaugeVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/9/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import ObjectMapper

class GaugeVisState: VisState {

    enum GaugeType: String {
        case gauge      =   "gauge"
        case goal       =   "goal"
    }
    
    var gaugeType: GaugeType    =   .gauge
    var gauge: Gauge?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        gaugeType       <-  (map["type"],EnumTransform<GaugeType>())
        
        if let params = map.JSON["params"] as? [String: Any],
            let guageContent = params["gauge"] as? [String: Any] {
            gauge           =  Mapper<Gauge>().map(JSONObject: guageContent)
        }
    }
}

class Gauge: Mappable {
    
    enum GaugeSubType: String {
        case arc    =   "Arc"
        case circle =   "Circle"
    }

    var ranges: [GaugeRange] =   []
    
    var subType: GaugeSubType  =   .arc
    
    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        subType     <-  (map["gaugeType"],EnumTransform<GaugeSubType>())
        
        if let colorsRangeList = map.JSON["colorsRange"] as? [[String : Any]] {
            ranges =   Mapper<GaugeRange>().mapArray(JSONArray: colorsRangeList)
        }
    }
}

class GaugeRange: Mappable {
    
    var from: CGFloat   =   0.0
    var to: CGFloat     =   0.0

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        from    <-  map["from"]
        to      <-  map["to"]
    }

}
