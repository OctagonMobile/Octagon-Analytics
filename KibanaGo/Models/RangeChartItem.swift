//
//  RangeChartItem.swift
//  KibanaGo
//
//  Created by Rameez on 11/9/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper

class RangeChartItem: ChartItem {

    var to              =   0.0
    var from            =   0.0

    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        to          <-  map["to"]
        from        <-  map["from"]

        //Remove the following code once the Format of the data is fixed at server side
        if let toVal = map.JSON["to"] as? String {
            to = Double(toVal) ?? 0.0
        }
        
        if let fromVal = map.JSON["from"] as? String {
            from = Double(fromVal) ?? 0.0
        }
    }
    
    static func ==(lhs: RangeChartItem, rhs: RangeChartItem) -> Bool {
        return lhs.key == rhs.key && lhs.to == rhs.to && lhs.from == rhs.from
    }

}
